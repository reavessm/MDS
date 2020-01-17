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

# Enables services to run
function enable() {
#{{{
  [ -d ../$conName ] && printYellow "$(mv -v ../$conName ../$conName.d | sed 's/\.\.\///g')"
  #service=${1%/}
  #service=${service%.d}
  #printYellow "$(mv -v $service $service.d)"
  print "Done!"
#}}}
}

# Disables services from running
function disable() {
#{{{
  [ -d ../$conName.d ] && printYellow "$(mv -v ../$conName.d ../$conName | sed 's/\.\.\///g')"
  #service=${1%/}
  #service=${service%.d}
  #printYellow "$(mv -v $service.d $service)"
  print "Done!"
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

# Finds the highest port in use, then adds one
function getNextPort() {
#{{{
  awk -F '=' 'BEGIN {max=0}
  {
    if ($1 == "exposedPort")
      { 
        max = (max > $2 ? max : $2);
      }
  }
  END {print max+1}' ./*.d/mds.sh
#}}}
}

# This function lists all the aliases currently in use
function checkAliases() {
#{{{
  {
  awk -F '=' '/^aliases/ {print $2}' ./*.d/mds.sh | sort -n | while \
    read -r alias
  do      
    echo -e "$alias -> $(grep "$alias" ./*.d/mds.sh | awk -F '/' '/aliases/ && !/#/ {print $2}')"
  done
  } | column -t
#}}}
}

function stop() {
#{{{
  printYellow "Stopping $conName"
  docker stop "$conName" >/dev/null

  [ -n "$conDB" ] && print "Stopping $conDB"
  [ -n "$conDB" ] && docker stop "$conDB" >/dev/null

  if [[ $(docker container inspect -f '{{.State.Running}}' "$conName") == 'false' ]]
  then
    print "$conName Stopped"
  else
    printRed "X $conName did not stop"
  fi
#}}}
}

function start() {
#{{{
  [ -n "$conDB" ] && print "Starting $conDB"
  [ -n "$conDB" ] && docker start "$conDB" >/dev/null

  printYellow "Starting $conName"
  docker start "$conName" >/dev/null

  if [[ $(docker container inspect -f '{{.State.Running}}' "$conName") == 'true' ]]
  then
    print "$conName Started"
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
  printYellow "Removing $conName"
  docker rm "$conName" >/dev/null

  [ -n "$conDB" ] && printYellow "Removing $conDB"
  [ -n "$conDB" ] && docker rm $conDB >/dev/null 

  [ -n "$conNet" ] && printYellow "Removing $conNet network"
  [ -n "$conNet" ] && docker network rm $conNet >/dev/null
#}}}
}

# Take care not to overwrite this function.  Overwrite 'superRemove' instead
function remove() {
#{{{
  stop

  superRemove

  print "$conName Removed"
#}}}
}

function check() {
#{{{
  docker ps -a | awk '{print $NF}' | grep -x $conName > /dev/null && \
    printYellow "$conName already exists" && start
#}}}
}

function build() {
#{{{
  [ -f ./Dockerfile ] && docker build --no-cache -t $conName . && \
    printYellow "Building $conName"
#}}}
}

# Empty functions to be hooked by contianer mds
# Although they can't be really empty or bash yells at me
function preconfig() { 
#{{{
  printYellow "Nothing to do for preconfig"
#}}}
}
function postconfig() { 
#{{{
  printYellow "Nothing to do for postconfig"
#}}}
}

function superRun() {
#{{{
  [ -n "$conNet" ] && printYellow "Creating $conNet network"
  [ -n "$conNet" ] && docker network create $conNet >/dev/null 

  [ -n "$conDB" ] && printYellow "Starting $conDB"
  [ -n "$conDB" ] && docker run --name "$conDB" $dbArgs "$conDBImg" >/dev/null

  print "Starting $conName"
  docker run --name "$conName" $args "$conImg" &>/dev/null
#}}}
}

# Take care not to overwrite this function.  Overwrite 'superRun' instead
function run() {
#{{{
  check
  build

  preconfig

  superRun

  postconfig

  if [[ $(docker container inspect -f '{{.State.Running}}' $conName) == 'true' ]]
  then
    print "$conName is Running!"
  else
    printRed "X $conName did not start"
  fi
#}}}
}

# Handles creating new services
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

  printYellow "Making directory '$name.d'"
  mkdir -p "$name.d"

  printYellow "Making file '$name.d/mds.sh'"
  conPort=$(getNextPort)
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

# Put the port you want to be made public to the load balancer. This should be
# the next open port, but you can verify this with 'make checkPorts'
exposedPort=$conPort

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
  echo "args+=\" -p $conPort:$port\"" >> "$name".d/mds.sh
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
#  printYellow "Doing something before run ..."
#  echo Something
#  print "Done something for \$conName!"
#}

# Uncomment this to run commands after the \$(docker run\) command.  These
# commands will run only on the first run.
#function postconfig() {
#  printYellow "Doing after before run ..."
#  echo Something
#  print "Done something for \$conName!"
#}

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

  print "Done"
#}}}
}

# Searches for and downloads new containers
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

  rm $tmp $newTmp
#}}}
}

# Creates news services and starts the proxy
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

# Udpates proxy settings
function proxyReset() {
#{{{
  (cd proxy.d && autoconfig.sh)

  make CMD=remove proxy &>/dev/null
  make proxy &>/dev/null
#}}}
}

# Check if service is running
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

# Downloads updated services
function update() {
#{{{
  printYellow "checking updates for $conName ..."
  out="$(docker pull "$conImg")"
  if [[ $out == *"up to date"* ]]
  then
    print "$conName is up to date!"
  else
    printYellow "$conName is updating ..."
    needsUpgrade=1
  fi
#}}}
}

# Removes the container, starts with updated version
function upgrade() {
#{{{
  update
  if (( needsUpgrade == 1))
  then
    remove
    run
    print "$conName was updated"
  fi
#}}}
}

# Show logs
function logs() {
#{{{
  printYellow "Printing logs for $conName ... <++>"
  docker container logs "$conName"
  print "Done printing logs for $conName! <-->"
#}}}
}

# Puts you in a shell of the service
function shell() {
#{{{
  printYellow "Entering $conName shell ($conShell) ..."
  docker container exec -it "$conName" "$conShell"
  print "Exiting $conName shell"
#}}}
}

# A sad attempt at trying to remove and restart a container
function remStart() {
#{{{
  remove
  run
#}}}
}

# Only allow certain options
#{{{
[ "$1" == "new" ] || \
[ "$1" == "init" ] || \
[ "$1" == "clean" ] || \
[ "$1" == "search" ] || \
[ "$1" == "upgrade" ] || \
[ "$1" == "remStart" ] || \
[ "$1" == "checkAliases" ] \
[ "$1" == "proxyReset" ] || \
[ "$1" == "getNextPort" ] || \
[ "$1" == "checkPorts" ] || \
&& $1 || true
