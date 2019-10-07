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
conName="openshift"

# Put the port you want to be made public to the load balancer
exposedPort=8443

# Put the IP of the host of the vm if not managed by MDS
# Normally, it's safe to ignore this
conIP=192.168.0.103

useHTTPS=true

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"

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
