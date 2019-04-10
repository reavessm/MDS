#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="rev-proxy"

#conImg="proxy"

## Make sure you put a space at the beginning of every arg EXCEPT the first
#args="-d"
#args+=" -p 80:80"

conImg="linuxserver/letsencrypt"
#conImg="proxy"

args="-d"
args+=" -e PUID=1001"
args+=" -e PGID=1001"
args+=" -e TZ=America/New_York"
args+=" -e URL=reaves.dev"
args+=" -e SUBDOMAINS=www,`ls .. | awk -F '.' \
  'BEGIN{ORS=","} /\.d/ {print $1}' | sed 's/,$//'`"
args+=" -e EMAIL=reaves735@gmail.com"
args+=" -e DHLEVEL=1024"
args+=" -e VALIDATION=http"
#args+=" -e VALIDATION=dns"
#args+=" -e DNSPLUGIN=cloudflare"
args+=" -p 443:443"
args+=" -p 80:80"
args+=" -v `pwd`/config:/config:rw"
#args+=" -v nginx.conf:/config/nginx/site-confs/default"


# run args
$1
