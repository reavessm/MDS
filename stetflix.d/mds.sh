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
conName="emby"

# You must specify a container image
#conImg="emby"

# If your container does not need a separate DB or network, leave these
# commented out
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

# Put the port you want to be made public to the load balancer
exposedPort=8096

# Put the IP of the host of the vm if not managed by MDS
# Normally, it's safe to ignore this
conIP=192.168.0.14

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName
#if [ -z "`docker ps -a | grep $conName`" ]
#then
#  read -p "Please enter keycloak username: " username
#  read -s -p "Please enter keycloak password: " password \
#    && echo
#fi

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
#args+=" --net $conNet"
#args+=" -e KEYCLOAK_USER=$username"
#args+=" -e KEYCLOAK_PASSWORD=$password"
#args+=" -p 8082:8080"

# These are the args passed to the `docker run` command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space
#dbArgs="-d"
#dbArgs+=" --net $conNet"
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

# Ovewrite these methods for vms not managed in MDS
function run() {
  print "$conName is not managed by MDS"
}

function stop() {
  print "$conName is not managed by MDS"
}

function remove() {
  print "$conName is not managed by MDS"
}

function start() {
  print "$conName is not managed by MDS"
}

# Run args.  Do not delete this deceptively simple command
$1
