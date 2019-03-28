#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="nextcloud"
conDB="$conName-DB"
conNet="$conName-net"

conImg="nextcloud"
conDBImg="mariadb"

exposedPort=8081

if [ -z "`docker ps -a | grep $conName`" ]
then
  read -p "Please enter $conName username: " username
  read -sp "Please enter $conName password: " password \
    && echo
fi

args="-d"
args+=" --net $conNet"
args+=" -e NEXTCLOUD_ADMIN_USER=$username"
args+=" -e NEXTCLOUD_ADMIN_PASSWORD=$password"
args+=" -p 8081:80"
args+=" -v /mnt/VMStorage/NextCloud/:/data"

dbArgs="-d"
dbArgs+=" --net $conNet"
dbArgs+=" -e MYSQL_DATABASE=$conDB"
dbArgs+=" -e MYSQL_ROOT_PASSWORD=$password"
dbArgs+=" -e MYSQL_USER=$username"

# run args
$1
