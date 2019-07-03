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
conName="search"

# You must specify a container image
conImg="hoellen/searx"

aliases="search"

# Put the port you want to be made public to the load balancer
exposedPort=8888

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
args+=" -p 8888:8888"
args+=" -e BASE_URL=https://search.reaves.dev"
args+=" -e IMAGE_PROXY=true"

# Run args.  Do not delete this deceptively simple command
$1
