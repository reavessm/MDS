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
conName="transmission-openvpn"

# You must specify a container image
conImg="haugene/transmission-openvpn"

# If your container does not need a separate DB or network, leave these
# commented out
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

# Put the port you want to be made public to the load balancer
exposedPort=9091

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName
if [ -z "`docker ps -a | grep $conName`" ]
then
  read -p "Please enter vpn username: " username
  read -s -p "Please enter vpn password: " password \
    && echo
fi

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
args+=" --restart=always"
args+=" -v /etc/localtime:/etc/localtime:ro"
args+=" -e CREATE_TUN_DEVICE=true"
args+=" -e OPENVPN_PROVIDER=NORDVPN"
args+=" -e OPENVPN_USERNAME=$username"
args+=" -e OPENVPN_PASSWORD=$password"
args+=" -e LOCAL_NETWORK=192.168.0.0/24"
args+=" -e HEALTH_CHECK_POST=google.com"
args+=" -e GLOBAL_APPLY_PERMISSIONS=false"
args+=" -e TRANSMISSION_WEB_UI=combustion"
args+=" -e WEBPROXY_ENABLED=false"
args+=" -e PUID=1001"
args+=" -e PGID=1001"
args+=" -e OPENVPN_OPT=--inactive 3600 --ping 10 --pint-exit 60"
args+=" -p 9091:9091"

# Run args.  Do not delete this deceptively simple command
$1
