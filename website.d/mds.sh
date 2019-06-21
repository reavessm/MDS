#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="reaves.dev"

conImg="nginx:alpine"

exposedPort=8083

# Make sure you put a space at the beginning of every arg EXCEPT the first
args="-d"
args+=" -v /mnt/Websites/stephenreaves.com/www/html/:/usr/share/nginx/html:ro"
args+=" -p 8083:80"

# run args
$1
