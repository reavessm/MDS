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
conName="firefly-iii"

# You must specify a container image.
conImg="jc5x/firefly-iii"

# If your container does not need a separate DB or network, leave these
# commented out.
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

useHTTPS=true

# Put the port you want to be made public to the load balancer.
exposedPort=8088

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
args+=" -p 8088:80"
args+=" -v /var/www/firefly-iii/storage/export:/var/www/firefly-iii/storage/export"
args+=" -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
args+=" -e PHPIZE_DEPS=autoconf"
args+=" -e dpkg-dev"
args+=" -e file"
args+=" -e g++"
args+=" -e gcc"
args+=" -e libc-dev"
args+=" -e make"
args+=" -e pkg-config"
args+=" -e re2c"
args+=" -e PHP_INI_DIR=/usr/local/etc/php"
args+=" -e APACHE_CONFDIR=/etc/apache2"
args+=" -e APACHE_ENVVARS=/etc/apache2/envvars"
args+=" -e PHP_EXTRA_BUILD_DEPS=apache2-dev"
args+=" -e PHP_EXTRA_CONFIGURE_ARGS=--with-apxs2"
args+=" -e --disable-cgi"
args+=" -e PHP_CFLAGS=-fstack-protector-strong"
args+=" -e -fpic"
args+=" -e -fpie"
args+=" -e -O2"
args+=" -e PHP_CPPFLAGS=-fstack-protector-strong"
args+=" -e -fpic"
args+=" -e -fpie"
args+=" -e -O2"
args+=" -e PHP_LDFLAGS=-Wl,-O1"
args+=" -e -Wl,--hash-style=both"
args+=" -e -pie"
args+=" -e GPG_KEYS=1729F83938DA44E27BA0F4D3DBDB397470D12172"
args+=" -e B1B44D8F021E4E2D6021E995DC9FF8D3EE5AF27F"
args+=" -e PHP_VERSION=7.2.16"
args+=" -e PHP_URL=https://secure.php.net/get/php-7.2.16.tar.xz/from/this/mirror"
args+=" -e PHP_ASC_URL=https://secure.php.net/get/php-7.2.16.tar.xz.asc/from/this/mirror"
args+=" -e PHP_SHA256=7d91ed3c1447c6358a3d53f84599ef854aca4c3622de7435e2df115bf196e482"
args+=" -e PHP_MD5="
args+=" -e FIREFLY_PATH=/var/www/firefly-iii"
args+=" -e COMPOSER_ALLOW_SUPERUSER=1"

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
