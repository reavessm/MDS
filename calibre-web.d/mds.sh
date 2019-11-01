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
conName="calibre-web"

# You must specify a container image.
conImg="linuxserver/calibre-web"

# If your container does not need a separate DB or network, leave these
# commented out.
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

# Uncomment this if the container ONLY accepts https requests.  NOTE: Even if
# you leave this commented out, users will still have https to the proxy.
# Normally, it's safe to leave this alone
#useHTTPS=true

# Uncomment this if you want this name resovable ONLY on the LAN
#private=true

# Put the port you want to be made public to the load balancer.
exposedPort=8099

# Additional proxy settings, to be copied as-is into proxy
proxySettings="proxy_set_header X-Script-Name     /calibre-web;"
#proxySettings="foo;"
#proxySettings="bar;"

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
#conIP=192.168.0.0

# Set this to a comma separated list of alternative subdomains that you like to
# point to this service
aliases="calibre,ebook,kindle,read"

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName.
#if [ -z "`docker ps -a | awk '{print $NF}' | grep -x $conName`" ]
#then
#  read -p "Please enter $conName username: " username
#  read -s -p "Please enter $conName password: " password \
#    && echo
#fi

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-d"
args+=" --restart unless-stopped"
args+=" -p 8099:8083"
args+=" -v /mnt/Media/Books:/books"
args+=" -v /mnt/VMStorage/CalibreWeb:/config"
args+=" -e PUID=1001"
args+=" -e PGID=1001"
args+=" -e TZ=America/NewYork"
# Allows ebook conversion
args+=" -e DOCKER_MODS=linuxserver/calibre-web:calibre" 

function reloadBooks() {
  docker exec calibre-web calibredb add --with-library /books /books
}

# Uncomment this to run commands after the `docker run` command.  These
# commands will run only on the first run.
function postconfig() {
  print "Configuring library for $conName"
  reloadBooks
  printYellow "Finished configuring library for $conName"
}

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
