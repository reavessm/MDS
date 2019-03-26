#!/bin/bash

# Get variables
#args=`dialog --backtitle "Create proxy config" \
  #--begin $(( $row - 20 )) $(( $col - 35 )) --inputbox "Enter domain name" 10 70 --stdout \
  #--and-widget --begin $(( $row - 5 )) $(( $col - 35 )) --inputbox \
  #"Enter subdomains and ports seperated by a colon ':'" 10 70 "one:80 two:443"` || exit

col=`echo $(( $(tput cols) / 2 ))`
row=`echo $(( $(tput lines) / 2 ))`

args=`dialog --backtitle "Create proxy config" \
  --begin $(( $row - 20 )) $(( $col - 35 )) --inputbox "Enter domain name" 10 70 --stdout \
  --and-widget --begin $(( $row - 5 )) $(( $col - 35 )) --inputbox \
  "Enter subdomains and ports seperated by a colon ':'" 10 70 "one:80 two:443"` || exit

dom=`echo $args | awk '{print $1}'`
subs=`echo $args | awk '{$1=""; print}'`
#file="nginx.conf"
file="file"

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
