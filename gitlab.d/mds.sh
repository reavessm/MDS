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
conName="gitlab"

# You must specify a container image
conImg="gitlab/gitlab-ce"

# Allow embedding in iframe for nextcloud
proxySettings="proxy_hide_header X-Frame-Options;"

# Put the port you want to be made public to the load balancer
exposedPort=8084

args="-d"
args+=" -p 8084:80"
args+=" -v /mnt/VMStorage/Git/gitlab-config:/etc/gitlab:Z"
args+=" -v /mnt/VMStorage/Git/gitlab-logs:/var/log/gitlab:Z"
args+=" -v /mnt/VMStorage/Git/gitlab-data:/var/opt/gitlab:Z"


function preconfig() {
  print "Copying config for $conName ..."
  [ -f ./gitlab.rb ] && sudo  cp ./gitlab.rb /mnt/VMStorage/Git/gitlab-config
  printRed "Done copying config for $conName!"
}

# Run args.  Do not delete this deceptively simple command
$1
