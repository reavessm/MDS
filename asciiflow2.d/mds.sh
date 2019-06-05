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
conName="asciiflow2"

# You must specify a container image.
conImg="ryodocx/asciiflow2"

exposedPort=8088

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-d"
args+=" -p 8088:80"
args+=" -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
args+=" -e NGINX_VERSION=1.15.3"

# If you need to group things in a network:
#args+=" --net $conNet"

# If you need a specific username and password:
#args+=" -e KEYCLOAK_USER=$username"
#args+=" -e KEYCLOAK_PASSWORD=$password"

# These are the args passed to the `docker run` command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space.
#dbArgs="-d"
#dbArgs+=" --net $conNet"
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

# Uncomment this to run commands before the `docker run` command.  These
# commands will run only on the first run.
#function preconfig() {
#  print "Doing something before run ..."
#  echo Something
#  printRed "Done something for $conName!"
#}

# Uncomment this to run commands after the `docker run` command.  These
# commands will run only on the first run.
#function postconfig() {
#  print "Doing after before run ..."
#  echo Something
#  printRed "Done something for $conName!"

# Ovewrite these methods for vms not managed in MDS.  The proxy will still
# point to the service, but will not create it.  This is normally used with the
# conIp variable to specify that the VM is on a different host.
#function run() {
#  print "$conName is not managed by MDS"
#}
#
#function stop() {
#  print "$conName is not managed by MDS"
#}
#
#function remove() {
#  print "$conName is not managed by MDS"
#}
#
#function start() {
#  print "$conName is not managed by MDS"
#}

# Run args.  Do NOT delete this deceptively simple command.
$1
