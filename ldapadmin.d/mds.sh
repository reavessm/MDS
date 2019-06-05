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
conName="phpldapadmin"

# You must specify a container image.
conImg="osixia/phpldapadmin"

# If your container does not need a separate DB or network, leave these
# commented out.
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

# Uncomment this if the container ONLY accepts https requests.  NOTE: Even if
# you leave this commented out, users will still have https to the proxy.
# Normally, it's safe to leave this alone
#useHTTPS=true

# Put the port you want to be made public to the load balancer.
exposedPort=8091

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
#conIP=192.168.0.0

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
#args+=" -p 443:443"
args+=" -p 8091:80"
args+=" -v /mnt/VMStorage/LDAPAdmin:/var/www/phpldapadmin"
args+=" -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
args+=" -e LANG=en_US.UTF-8"
args+=" -e LANGUAGE=en_US:en"
args+=" -e LC_ALL=en_US.UTF-8"
args+=" -e PHPLDAPADMIN_LDAP_HOSTS=reaves.dev"
args+=" -e PHPLDAPADMIN_HTTPS=false"

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
