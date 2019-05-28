#!/bin/bash

###############################################################################
# My Docker Script                                                            #
# Written by: Stephen Reaves                                                  #
#                                                                             #
# Every Docker container should have it's own dir with the '.d' suffix.       #
# Inside that dir, there should be mds.sh script that defines variables like  #
# the image.  From there, this script should handle docker builds, runs, etc. #
###############################################################################

declare -a args
declare -a DBArgs
contName=
hostIP="`ip route get 1 | awk '{print $(NF-2);exit}'`"

function print() {
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
}

function printRed() {
  RED='\033[1;31m'
  NC='\033[0m'
  echo -e "${RED}$1${NC}"
}

# This function lists all the exposed ports currently in use
function checkPorts() {
  for port in `awk -F '=' '/^exposedPort/ {print $2}' *.d/mds.sh | sort`
  do      
    echo "$port -> `grep $port *.d/mds.sh | awk -F '/' '/exposedPort/ && !/#/ {print $1}'`"
  done
}

function stop() {
  docker stop $conName >/dev/null && print "Stopping $conName"

  [ -n "$conDB" ] && docker stop $conDB >/dev/null && \
    print "Stopping $conDB"

  printRed "$conName Stopped"
}

function start() {
  [ -n "$conDB" ] && docker start $conDB >/dev/null && \
    print "Starting $conDB"

  docker start $conName >/dev/null && print "Starting $conName"

  printRed "$conName Started"

  exit 0
}

function restart() {
  stop
  start
}

function superRemove() {
  docker rm $conName >/dev/null && print "Removing $conName"

  [ -n "$conDB" ] && docker rm $conDB >/dev/null && \
    print "Removing $conDB"

  [ -n "$conNet" ] && docker network rm $conNet >/dev/null && \
    print "Removing $conNet network"
}

# Take care not to overwrite this function.  Overwrite 'remove' instead
function remove() {
  stop

  superRemove

  printRed "$conName Removed"
}

function check() {
  docker ps -a | awk '{print $NF}' | grep -x $conName > /dev/null && print \
    "$conName already exists" && start
}

function build() {
  [ -f ./Dockerfile ] && docker build --no-cache -t $conName . && \
    print "Building $conName"
}

# Empty functions to be hooked by contianer mds
# Although they can't be really empty or bash yells at me
function preconfig() { 
  print "Nothing to do for preconfig"
}
function postconfig() { 
  print "Nothing to do for postconfig"
}

function superRun() {
  [ -n "$conNet" ] && docker network create $conNet >/dev/null && \
    print "Creating $conNet network"

  [ -n "$conDB" ] && docker run --name $conDB $dbArgs "$conDBImg" >/dev/null && \
    print "Starting $conDB"

  docker run --name $conName $args "$conImg" &>/dev/null && \
    print "Starting $conName"
}

# Take care not to overwrite this function.  Overwrite 'run' instead
function run() {
  check
  build

  preconfig

  superRun

  postconfig

  printRed "$conName is running!"
}

function new() {
  if [ $# != 2 ] 
  then
    read -p "Please enter the name of the service: " name
    img=$name
  else
    name="$1"
    img="$2"
  fi

  if [ -d $name.d ]
  then
    printRed "ERROR: Name already exists"
    exit 1
  fi

  print "Making directory '$name.d'"
  mkdir -p $name.d

  print "Making file '$name.d/mds.sh'"
  cat > $name.d/mds.sh << EOF
#!/bin/bash

###############################################################################
# My Docker Script                                                            #
# Written by: Stephen Reaves                                                  #
#                                                                             #
# Every Docker container should have it's own dir with the '.d' suffix.       #
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

# Put the port you want to be made public to the load balancer.
#exposedPort=8082

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
#conIP=192.168.0.0

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName.
#if [ -z "\`docker ps -a | awk '{print \$NF}' | grep -x \$conName\`" ]
#then
#  read -p "Please enter \$conName username: " username
#  read -s -p "Please enter \$conName password: " password \\
#    && echo
#fi

# These are the args passed to the \`docker run\` command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-d"
EOF

docker pull $img

for port in `docker image inspect -f '{{.Config.ExposedPorts}}' $img \
  | sed 's/[^[:digit:][:space:]]//g'`
do
  echo "args+=\" -p $port:$port\"" >> $name.d/mds.sh
done

for vol in `docker image inspect -f '{{.Config.Volumes}}' $img \
  | sed 's/map\[\|\]//g' | awk -F ':' '{print $1}'`
do
  echo "args+=\" -v $vol:$vol\"" >> $name.d/mds.sh
done

# Most of these are completely unnecessary, but I'll leave that up to the user
# to decide.
for env in `docker image inspect -f '{{.Config.Env}}' $img \
  | sed 's/\[\|\]//g'`
do
  echo "args+=\" -e $env\"" >> $name.d/mds.sh
done

cat >> $name.d/mds.sh << EOF

# If you need to group things in a network:
#args+=" --net \$conNet"

# If you need a specific username and password:
#args+=" -e KEYCLOAK_USER=\$username"
#args+=" -e KEYCLOAK_PASSWORD=\$password"

# These are the args passed to the \`docker run\` command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space.
#dbArgs="-d"
#dbArgs+=" --net \$conNet"
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

# Uncomment this to run commands before the \`docker run\` command.  These
# commands will run only on the first run.
#function preconfig() {
#  print "Doing something before run ..."
#  echo Something
#  printRed "Done something for \$conName!"
#}

# Uncomment this to run commands after the \`docker run\` command.  These
# commands will run only on the first run.
#function postconfig() {
#  print "Doing after before run ..."
#  echo Something
#  printRed "Done something for \$conName!"

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
  chmod +x $name.d/mds.sh

  ${EDITOR:-vim} $name.d/mds.sh

  printRed "Done"
}

function search() {
  tmp="/tmp/MDS-tmp"
  newTmp="/tmp/MDS-newTmp"

  if [ $# != 1 ]
  then
    #read -p "Please enter the name of the container to search for: " name
    name="`dialog --stdout --inputbox \
      'Please enter the name of the container to search for' 0 0`"
        else
          name=$1
        fi

        docker search --format "{{.Name}} \"{{.Description}}\"" "$name" | sed \
          's/\"\"/\"N\/A\"/g' > $tmp

        dialog --stdout --menu "Choose one:" 0 0 0 --file "$tmp" > $newTmp || exit 1

        clear

  # Set contName for init script and pass name and conImg to new script
  # Official images don't have a '/' ...
  if [[ `grep "/" $newTmp` ]]
  then
    contName="`awk -F "/" '{print $2}' $newTmp`"
    new `awk -F "/" '{print $2,$0}' $newTmp` 2>/dev/null
  else
    contName="`cat $newTmp`"
    new `awk '{print $0,$0}' $newTmp` 2>/dev/null
  fi
}

function init() {
  dialog --stdout --yesno 'Would you like to add containers now?' 0 0
  ans="$?"

  while [[ "$ans" == "0" ]]
  do
    search
    #${EDITOR:-vim} "$contName.d/mds.sh" # Handled by new
    dialog --stdout --yesno 'Would you like to add another container?' 0 0
    ans="$?"
  done

  (cd proxy.d/ && ./autoconfig.sh)

  # I know this makes proxy twice, but deal with it
  make proxy && make all
}

function proxyReset() {
  (cd proxy.d && autoconfig.sh)

  make CMD=remove proxy &>/dev/null
  make proxy &>/dev/null
}

# Only allow certain options
[ "$1" == "new" ] && new || true
[ "$1" == "init" ] && init || true
[ "$1" == "search" ] && search || true
[ "$1" == "checkPorts" ] && checkPorts || true
[ "$1" == "proxyReset" ] && proxyReset || true
