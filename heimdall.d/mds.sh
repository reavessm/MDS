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
conName="heimdall"

# You must specify a container image
conImg="linuxserver/heimdall"

# Put the port you want to be made public to the load balancer
#exposedPort=8082

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName
#if [ -z "`docker ps -a | awk '{print $NF}' | grep -x $conName`" ]
#then
#  read -p "Please enter keycloak username: " username
#  read -s -p "Please enter keycloak password: " password \
#    && echo
#fi

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
args+=" -e PUID=1001"
args+=" -e GUID=1001"
args+=" -e TZ=America/New_York"
args+=" -p 8088:443"
args+=" -v /mnt/VMStorage/Heimdall:/config"

# Run args.  Do not delete this deceptively simple command
$1
