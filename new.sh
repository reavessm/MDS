#!/bin/bash

if [ $# != 1 ] 
then
  read -p "Please enter the name of the service: " name
else
  name=$1
fi

function printError() {
  ERROR='\033[1;31m'
  NC='\033[0m'
  echo -e "${ERROR}$1${NC}"
}

function print() {
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
}

if [ -d $name.d ]
then
  printError "ERROR: Name already exists"
  exit 1
fi

print "Making directory '$name.d'"
mkdir -p $name.d

print "Making file '$name.d/mds.sh'"
cat > $name.d/mds.sh << EOF
#!/bin/bash

conName="$name"
conDB="\$conName-DB"

function print() {
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "\${GREEN}\$1\${NC}"
}

function stop() {
  docker stop \$conName > /dev/null && print "Stopping \$conName"
}

function start() {
  docker start \$conName > /dev/null && print "Starting \$conName"

  exit 0
}

function remove() {
  stop
  docker rm \$conName > /dev/null && print "Removing \$conName"
}

function check() {
  docker ps -a | grep \$conName > /dev/null && print \\
    "\$conName already exists" && start
}

function run() {
  check

  #docker run --name \$conName -v \\
  #  /mnt/Websites/stephenreaves.com/www/html/:/usr/share/nginx/html:ro -d \\
  #  -p 80:80 nginx:alpine > /dev/null && print "Starting \$conName"
}

# run args
\$1
EOF

chmod +x $name.d/mds.sh

print "Done"
