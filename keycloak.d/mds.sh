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
args+=" -e PROXY_ADDRESS_FORWARDING=true"
#args+=" -v /mnt/VMStorage/Keycloak/Data:/"

dbArgs="-d"
dbArgs+=" --net $conNet"
dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
dbArgs+=" -e MYSQL_PASSWORD=password"
dbArgs+=" -e MYSQL_USER=keycloak"
dbArgs+=" -e MYSQL_DATABASE=keycloak"
dbArgs+=" -v /mnt/VMStorage/Keycloak/Mysql:/var/lib/mysql"

# Additional proxy settings, to be copied as-is into proxy
#proxySettings="proxy_set_header X-Firefox-Spdy     h2;"

# run args
$1
