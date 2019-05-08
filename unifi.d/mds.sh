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
#conName="unifi-controller"

# You must specify a container image
#conImg="linuxserver/unifi-controller"

# Put the port you want to be made public to the load balancer
exposedPort=8443

useHTTPS=true

conIP=192.168.0.99

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
#args="-d"
#args+=" -e PUID=1001"
#args+=" -e GUID=1000"
#args+=" -p 3478:3478/udp"
#args+=" -p 10001:10001/udp"
#args+=" -p 8080:8080"
#args+=" -p 8581:8081"
#args+=" -p 8443:8443"
#args+=" -p 8843:8843"
#args+=" -p 8880:8880"
#args+=" -p 6789:6789"
#args+=" -v <path to data>:/config"

# Run args.  Do not delete this deceptively simple command
$1
