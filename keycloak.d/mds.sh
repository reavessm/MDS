#!/bin/bash

conName="keycloak"
conDB="mariadb"

function print() {
  GREEN='\033[1;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
}

function stop() {
  docker stop $conName > /dev/null && print "Stopping $conName"
  docker stop $conDB > /dev/null && print "Stopping $conDB"
}

function start() {
  docker start $conDB > /dev/null && print "Starting $conDB"
  docker start $conName > /dev/null && print "Starting $conName"

  exit 0
}

function remove() {
  stop
  docker rm $conName > /dev/null && print "Removing $conName"
  docker rm $conDB > /dev/null && print "Removing $conDB"
  docker network rm $conName-network > /dev/null && print "Removing network"
}

function check() {
  docker container list | grep $conName >/dev/null && print \
    "$conName already exists" && start
}

function run() {
  check

  read -p "Please enter keycloak username: " username
  read -s -p "Please enter keycloak password: " kPassword
  echo

  docker network create $conName-network > /dev/null && print \
    "Creating $conName network"
  docker run -d --name $conDB --net $conName-network -e MYSQL_ROOT_PASSWORD=password \
    -e MYSQL_DATABASE=keycloak -e MYSQL_USER=keycloak -e \
    MYSQL_PASSWORD=password mariadb > /dev/null && print "Starting mariadb"
 
  nohup docker run --name $conName --net $conName-network -e KEYCLOAK_USER=$username \
    -e KEYCLOAK_PASSWORD=$kPassword -p 8080:8080 jboss/keycloak & &> /dev/null \
    && print "Starting $conName"

  disown
}

# run args
$1
