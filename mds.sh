#!/bin/bash

###############################################################################
# MDS                                                                         #
# Written by: Stephen Reaves                                                  #
#                                                                             #
# Every service should have it's own dir with the '.d' suffix.                #
# Inside that dir, there should be mds.sh script that defines variables like  #
# the image.  From there, this script should handle docker builds, runs, etc. #
###############################################################################

# Default variables
#{{{
conDB=""
conNet=""
conImg=""
conName=""
conDBImg=""
needsUpgrade=0
conShell="/bin/bash"
declare -a args
declare -a dbArgs
hostIP="$(ip route get 1 | awk '{print $(NF-2);exit}')"
#}}}

function print() {
#{{{
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
#}}}
}

function printRed() {
#{{{
  RED='\033[1;31m'
  NC='\033[0m'
  echo -e "${RED}$1${NC}"
#}}}
}

function printYellow() {
#{{{
  YELLOW='\033[1;33m'
  NC='\033[0m'
  echo -e "${YELLOW}$1${NC}"
#}}}
}

# This function lists all the exposed ports currently in use
function checkPorts() {
#{{{
  {
  awk -F '=' '/^exposedPort/ {print $2}' ./*.d/mds.sh | sort -n | while \
    read -r port
  do      
    echo -e "$port -> $(grep "$port" ./*.d/mds.sh | awk -F '/' '/exposedPort/ && !/#/ {print $2}')"
  done
  } | column -t
#}}}
}
# This function lists all the aliases currently in use
function checkAliases() {
#{{{
  printRed "This feature is not yet implemented..."
#  {
#  awk -F '=' '/^exposedPort/ {print $2}' ./*.d/mds.sh | sort -n | while \
#    read -r port
#  do      
#    echo -e "$port -> $(grep "$port" ./*.d/mds.sh | awk -F '/' '/exposedPort/ && !/#/ {print $2}')"
#  done
#  } | column -t
#}}}
}

function stop() {
#{{{
  print "Stopping $conName"
  docker stop "$conName" >/dev/null

  [ -n "$conDB" ] && print "Stopping $conDB"
  [ -n "$conDB" ] && docker stop "$conDB" >/dev/null

  if [[ $(docker container inspect -f '{{.State.Running}}' "$conName") == 'false' ]]
  then
    printYellow "$conName Stopped"
  else
    printRed "X $conName did not stop"
  fi
#}}}
}

function start() {
#{{{
  [ -n "$conDB" ] && print "Starting $conDB"
  [ -n "$conDB" ] && docker start "$conDB" >/dev/null

  print "Starting $conName"
  docker start "$conName" >/dev/null

  if [[ $(docker container inspect -f '{{.State.Running}}' "$conName") == 'true' ]]
  then
    printYellow "$conName Started"
  else
    printRed "X $conName did not start"
  fi

  exit 0
#}}}
}

function restart() {
#{{{
  stop
  start
#}}}
}

function superRemove() {
#{{{
  print "Removing $conName"
  docker rm "$conName" >/dev/null

  [ -n "$conDB" ] && print "Removing $conDB"
  [ -n "$conDB" ] && docker rm $conDB >/dev/null 

  [ -n "$conNet" ] && print "Removing $conNet network"
  [ -n "$conNet" ] && docker network rm $conNet >/dev/null
#}}}
}

# Take care not to overwrite this function.  Overwrite 'superRemove' instead
function remove() {
#{{{
  stop

  superRemove

  printYellow "$conName Removed"
#}}}
}

function check() {
#{{{
  docker ps -a | awk '{print $NF}' | grep -x $conName > /dev/null && print \
    "$conName already exists" && start
#}}}
}

function build() {
#{{{
  [ -f ./Dockerfile ] && docker build --no-cache -t $conName . && \
    print "Building $conName"
#}}}
}

# Empty functions to be hooked by contianer mds
# Although they can't be really empty or bash yells at me
function preconfig() { 
#{{{
  print "Nothing to do for preconfig"
#}}}
}
function postconfig() { 
#{{{
  print "Nothing to do for postconfig"
#}}}
}

function superRun() {
#{{{
  [ -n "$conNet" ] && print "Creating $conNet network"
  [ -n "$conNet" ] && docker network create $conNet >/dev/null 

  [ -n "$conDB" ] && print "Starting $conDB"
  [ -n "$conDB" ] && docker run --name "$conDB" $dbArgs "$conDBImg" >/dev/null

  print "Starting $conName"
  docker run --name "$conName" $args "$conImg" &>/dev/null
#}}}
}

# Take care not to overwrite this function.  Overwrite 'run' instead
function run() {
#{{{
  check
  build

  preconfig

  superRun

  postconfig

  if [[ $(docker container inspect -f '{{.State.Running}}' $conName) == 'true' ]]
  then
    printYellow "$conName is Running!"
  else
    printRed "X $conName did not start"
  fi
#}}}
}

function new() {
#{{{
  if [ $# != 2 ] 
  then
    read -rp "Please enter the name of the service: " name
    img="$name"
  else
    name="$1"
    img="$2"
  fi

  if [ -d "$name.d" ]
  then
    printRed "ERROR: Name already exists"
    exit 1
  fi

  print "Making directory '$name.d'"
  mkdir -p "$name.d"

  print "Making file '$name.d/mds.sh'"
  cat > "$name".d/mds.sh << EOF
#!/bin/bash

###############################################################################
# MDS                                                                         #
# Written by: Stephen Reaves                                                  #
#                                                                             #
# Every service should have it's own dir with the '.d' suffix.                #
# Inside that dir, there should be mds.sh script that defines variables like  #
# the image.  From there, this script should handle docker builds, runs, etc. #
#                                                                             #
# This files defines variables used by the parent mds.sh                      #
# You can also override functions from the parent mds.sh, but do so with      #
# caution.                                                                    #
###############################################################################

# Source the parent mds.sh
[ -f ../mds.sh ] && source ../mds.sh || exit 1

# You must specify container name.
conName="$name"

# You must specify a container image.
conImg="$img"

# If your container does not need a separate DB or network, leave these
# commented out.
#conDB="\$conName-DB"
#conDBImg="mariadb"
#conNet="\$conName-net"

# Uncomment this if the container ONLY accepts https requests.  NOTE: Even if
# you leave this commented out, users will still have https to the proxy.
# Normally, it's safe to leave this alone
#useHTTPS=true

# Uncomment this if you want this name resolvable ONLY on the LAN
#private=true

# Put the port you want to be made public to the load balancer.
#exposedPort=8082

# Additional proxy settings, to be copied as-is into proxy
#proxySettings="proxy_set_header X-Script-Name     /calibre-web;"
#proxySettings+="foo;"
#proxySettings+="bar;"

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
#conIP=192.168.0.0

# Set this to a comma separated list of alternative subdomains that you like to
# point to this service
#aliases="foo,bar"

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName.
#if [ -z "\$(docker ps -a | awk '{print \$NF}' | grep -x \$conName\)" ]
#then
#  read -p "Please enter \$conName username: " username
#  read -s -p "Please enter \$conName password: " password \\
#    && echo
#fi

# These are the args passed to the \$(docker run\) command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-d"
args+=" --restart unless-stopped"
EOF

dialog --prgbox "Pulling Image" "docker pull $img" 50 80

for port in $(docker image inspect -f '{{.Config.ExposedPorts}}' "$img" \
  | sed 's/[^[:digit:][:space:]]//g')
do
  echo "args+=\" -p $port:$port\"" >> "$name".d/mds.sh
done

for vol in $(docker image inspect -f '{{.Config.Volumes}}' "$img" \
  | sed 's/map\[\|\]//g' | awk -F ':' '{print $1}')
do
  echo "args+=\" -v $vol:$vol\"" >> "$name".d/mds.sh
done

# Most of these are completely unnecessary, but I'll leave that up to the user
# to decide.
for env in $(docker image inspect -f '{{.Config.Env}}' "$img" \
  | sed 's/\[\|\]//g')
do
  echo "args+=\" -e $env\"" >> "$name".d/mds.sh
done

cat >> "$name".d/mds.sh << EOF

# If you need to group things in a network:
#args+=" --net \$conNet"

# If you need a specific username and password:
#args+=" -e KEYCLOAK_USER=\$username"
#args+=" -e KEYCLOAK_PASSWORD=\$password"

# These are the args passed to the \$(docker run\) command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space.
#dbArgs="-d"
#dbArgs+=" --net \$conNet"
#dbArgs+=" --restart unless-stopped
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

# Uncomment this to run commands before the \$(docker run\) command.  These
# commands will run only on the first run.
#function preconfig() {
#  print "Doing something before run ..."
#  echo Something
#  printYellow "Done something for \$conName!"
#}

# Uncomment this to run commands after the \$(docker run\) command.  These
# commands will run only on the first run.
#function postconfig() {
#  print "Doing after before run ..."
#  echo Something
#  printYellow "Done something for \$conName!"

# Ovewrite these methods for vms not managed in MDS.  The proxy will still
# point to the service, but will not create it.  This is normally used with the
# conIp variable to specify that the VM is on a different host.
#function run() {
#  print "\$conName is not managed by MDS"
#}
#
#function stop() {
#  print "\$conName is not managed by MDS"
#}
#
#function remove() {
#  print "\$conName is not managed by MDS"
#}
#
#function start() {
#  print "\$conName is not managed by MDS"
#}

# Run args.  Do NOT delete this deceptively simple command.
\$1
EOF

  # Make executable
  chmod +x "$name".d/mds.sh

  # Open in editor
  ${EDITOR:-vim} "$name".d/mds.sh

  printYellow "Done"
#}}}
}

function search() {
#{{{
  tmp="/tmp/MDS-tmp"
  newTmp="/tmp/MDS-newTmp"

  if [ $# != 1 ]
  then
    name="$(dialog --stdout --inputbox \
      'Please enter the name of the container to search for' 0 0)"
  else
    name=$1
  fi

  docker search --format "{{.Name}} \"{{.Description}}\"" "$name" | sed \
    's/\"\"/\"N\/A\"/g' > $tmp

  dialog --stdout --menu "Choose one:" 0 0 0 --file "$tmp" > $newTmp || exit 1

  clear

  # Pass name and conImg to 'new' script
  # Official images don't have a '/' ...
  if [[ $(grep "/" $newTmp) ]]
  then
    new $(awk -F "/" '{print $2,$0}' $newTmp) 2>/dev/null
  else
    new $(awk '{print $0,$0}' $newTmp) 2>/dev/null
  fi
#}}}
}

function init() {
#{{{
  dialog --stdout --yesno 'Would you like to add containers now?' 0 0
  ans="$?"

  if [[ "$ans" == "0" ]]
  then
	  while [[ "$ans" == "0" ]]
	  do
	    search
	    dialog --stdout --yesno 'Would you like to add another container?' 0 0
	    ans="$?"
	  done
	
	  (cd proxy.d/ && ./autoconfig.sh)
	
	  # I know this makes proxy twice, but deal with it
	  make proxy && make all
  fi
#}}}
}

function proxyReset() {
#{{{
  (cd proxy.d && autoconfig.sh)

  make CMD=remove proxy &>/dev/null
  make proxy &>/dev/null
#}}}
}

function status() {
#{{{
  text="$(docker ps | awk "{found = 0; up = 0}
  /$conName/ {found = 1}
  /Up/ {up = 1}
  {
    if (found)
    {
      if (up)
      {
        print \"$conName is running\"
        exit
      }
      else
      {
        print \"$conName is starting\"
        exit
      }
    }
  }
  END {
    if (!found)
    {
      print \"$conName is down\"
    }
  }")"
  case "$(echo "$text" | awk '{print $3}')" in
    "running")
      print "$text"
      ;;
    "starting")
      printYellow "$text"
      ;;
    *)
      printRed "$text"
      ;;
  esac
#}}}
}

function update() {
#{{{
  printYellow "$conName is updating ..."
  out="$(docker pull "$conImg")"
  if [[ $out == *"up to date"* ]]
  then
    print "$conName is up to date!"
  else
    printYellow "$conName was  updated"
    needsUpgrade=1
  fi
#}}}
}

function upgrade() {
#{{{
  update
  if (( needsUpgrade == 1))
  then
    remove
    run
  fi
#}}}
}

function logs() {
#{{{
  printYellow "Printing logs for $conName ... <++>"
  docker container logs "$conName"
  print "Done printing logs for $conName! <-->"
#}}}
}

function shell() {
#{{{
  printYellow "Entering $conName shell ($conShell) ..."
  docker container exec -it "$conName" "$conShell"
  print "Exiting $conName shell"
#}}}
}

# Only allow certain options
#{{{
[ "$1" == "new" ] && new || true
[ "$1" == "init" ] && init || true
[ "$1" == "search" ] && search || true
[ "$1" == "checkPorts" ] && checkPorts || true
[ "$1" == "proxyReset" ] && proxyReset || true
#}}}
