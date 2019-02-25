#!/bin/bash

conName="nextcloud"
conDB=""

function print() {
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
}

function stop() {
  docker stop $conName > /dev/null && print "Stopping $conName"
}

function start() {
  docker start $conName > /dev/null && print "Starting $conName"

  exit 0
}

function remove() {
  stop
  docker rm $conName > /dev/null && print "Removing $conName"
}

function check() {
  docker container list | grep $conName > /dev/null && print \
    "$conName already exists" && start
}

function run() {
  check

  docker run --name $conName -d -p 8181:80 nextcloud \
    -v /mnt/VMStorage/NextCloud/:/var/www/html
}

# run args
$1
