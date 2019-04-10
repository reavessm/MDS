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

function remove() {
  stop

  docker rm $conName >/dev/null && print "Removing $conName"

  [ -n "$conDB" ] && docker rm $conDB >/dev/null && \
    print "Removing $conDB"

  [ -n "$conNet" ] && docker network rm $conNet >/dev/null && \
    print "Removing $conNet network"

  printRed "$conName Removed"
}

function check() {
  docker ps -a | grep $conName > /dev/null && print \
    "$conName already exists" && start
}

function build() {
  [ -f ./Dockerfile ] && docker build --no-cache -t $conName . && \
    print "Building $conName"
}

function run() {
  check
  build

  [ -n "$conNet" ] && docker network create $conNet >/dev/null && \
    print "Creating $conNet network"

  [ -n "$conDB" ] && docker run --name $conDB $dbArgs "$conDBImg" >/dev/null && \
    print "Starting $conDB"

  docker run --name $conName $args "$conImg" &>/dev/null && \
    print "Starting $conName"

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

# You must specify container name
conName="$name"

# You must specify a container image
conImg="$img"

# If your container does not need a separate DB or network, leave these
# commented out
#conDB="\$conName-DB"
#conDBImg="mariadb"
#conNet="\$conName-net"

# Put the port you want to be made public to the load balancer
#exposedPort=8082

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName
#if [ -z "\`docker ps -a | grep \$conName\`" ]
#then
#  read -p "Please enter keycloak username: " username
#  read -s -p "Please enter keycloak password: " password \\
#    && echo
#fi

# These are the args passed to the \`docker run\` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
#args+=" --net \$conNet"
#args+=" -e KEYCLOAK_USER=\$username"
#args+=" -e KEYCLOAK_PASSWORD=\$password"
#args+=" -p 8082:8080"

# These are the args passed to the \`docker run\` command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space
#dbArgs="-d"
#dbArgs+=" --net \$conNet"
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

# Run args.  Do not delete this deceptively simple command
\$1
EOF
	
	# Make executable
	chmod +x $name.d/mds.sh
	
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

  contName="`awk -F "/" '{print $2}' $newTmp`"

	
  # Fucking magic, don't touch this
  new `awk -F "/" '{print $2,$0}' $newTmp` 2>/dev/null
}

function init() {
  dialog --stdout --yesno 'Would you like to add containers now?' 0 0
  ans="$?"

  while [[ "$ans" == "0" ]]
  do
    search
    ${EDITOR:-vim} "$contName.d/mds.sh"
    dialog --stdout --yesno 'Would you like to add another container?' 0 0
    ans="$?"
  done
  
  (cd proxy.d/ && ./autoconfig.sh)
}

# Only allow certain options
[ "$1" == "new" ] && new || true
[ "$1" == "init" ] && init || true
[ "$1" == "search" ] && search || true
