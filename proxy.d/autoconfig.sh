#!/bin/bash

if [ "$#" == "1" ]
then
  dom="$1"
else
  dom=`dialog --backtitle "Create proxy config" --inputbox "Enter domain name" \
    0 0 --stdout`
fi

file="nginx.conf"

# Make sure website goes first
subs="website:`awk -F '=' '/exposedPort/ {print $2}' ../website.d/mds.sh` "

for f in ../*/mds.sh
do
  # Don't reinsert website
  if [[ `grep exposedPort $f` && "`echo $f | awk -F '/' '{print $2}'`" != "website.d" ]]
  then
    subs+="`echo $f | awk -F '/' '{print $2}' | sed 's/\.d//g'`:`awk -F '=' \
      '/exposedPort/ {print $2}' $f` "
  fi
done

# Basic stuff
cat > $file <<EOF
worker_processes 5;

events {
    worker_connections 1024;
}

http {
    sendfile on;

EOF

# Upstream servers
# TODO: allow for multiple hosts
for sub in $subs
do
  name="`echo ${sub} | cut -d ':' -f1`"
  ip="`echo ${sub} | cut -d ':' -f2`"
  cat >> $file <<EOF
    upstream ${name}_server {
        server 192.168.0.3:${ip};
    } 

EOF
done

# Location directives
for sub in $subs
do
  name="`echo ${sub} | cut -d ':' -f1`"
  cat >> $file <<EOF
    server {
        listen 80;
        allow  all;
        server_name ${name}.${dom} www.${name}.${dom};

        location / {
            proxy_pass http://${name}_server;
            
            proxy_set_header Host             \$host;
            proxy_set_header X-Real-IP        \$remote_addr;
            proxy_set_header X-Forwarded-For  \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host \$server_name;
        }
    }

EOF
done 

# End http block
echo "}" >> $file
