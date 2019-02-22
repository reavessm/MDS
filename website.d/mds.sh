#!/bin/bash

conName="stephenreaves.com"
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
    "$conName already exists" || return 1
}

function run() {
  check && start

  docker run --name $conName -v \
    /mnt/Websites/stephenreaves.com/www/html/:/usr/share/nginx/html:ro -d \
    -p 80:80 nginx:alpine > /dev/null && print "Starting $conName"
}

# run args
$1
