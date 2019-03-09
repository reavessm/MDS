#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="stephenreaves.com"
conDB=""
conNet=""

conImg="nginx:alpine"

# Make sure you put a space at the beginning of every arg EXCEPT the first
args="-d"
args+=" -v /mnt/Websites/stephenreaves.com/www/html/:/usr/share/nginx/html:ro"
args+=" -p 80:80"

#function run () {
  #check

  #docker run --name $conName \
    #-v /mnt/Websites/stephenreaves.com/www/html/:/usr/share/nginx/html:ro -d \
    #-p 80:80 \
    #nginx:alpine >/dev/null && print "Starting $conName"

#}


# run args
$1
