#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="keycloak"
conDB="$conName-DB"
conNet="$conName-net"

conImg="jboss/keycloak"
conDBImg="mariadb"

exposedPort=8082

if [ -z "`docker ps -a | grep $conName`" ]
then
  read -p "Please enter keycloak username: " username
  read -s -p "Please enter keycloak password: " password \
    && echo
fi

args="-d"
args+=" --net $conNet"
args+=" -e KEYCLOAK_USER=$username"
args+=" -e KEYCLOAK_PASSWORD=$password"
args+=" -p 8082:8080"

dbArgs="-d"
dbArgs+=" --net $conNet"
dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
dbArgs+=" -e MYSQL_PASSWORD=password"
dbArgs+=" -e MYSQL_USER=keycloak"
dbArgs+=" -e MYSQL_DATABASE=keycloak"

# run args
$1
