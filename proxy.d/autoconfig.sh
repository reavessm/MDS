#!/bin/bash

if [ "$#" == "1" ]
then
  dom="$1"
else
  dom=`dialog --backtitle "Create proxy config" --inputbox "Enter domain name" \
    0 0 --stdout`
fi

file="config/nginx/site-confs/default"
rm "$file"

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

# Basic stuff
cat >> $file <<EOF
server {
    listen 80;
    listen [::]:80;
    allow  all;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;

    root /config/www;
    index index.html index.htm index.php;

    server_name _;

    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    ssl_dhparam /config/nginx/dhparams.pem;

    ssl_certificate /config/keys/letsencrypt/fullchain.pem;
    ssl_certificate_key /config/keys/letsencrypt/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';

    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4;

    location / {
        #try_files \$uri \$uri/ /index.html /index.php?\$args =404;
        proxy_pass http://website_server;
          
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host  \$server_name;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

EOF

# Location directives
for sub in $subs
do
  name="`echo ${sub} | cut -d ':' -f1`"
  cat >> $file <<EOF
server {
    listen 443;
    listen [::]:443;
    allow  all;
    server_name ${name}.${dom} www.${name}.${dom} ${name}.*;

    location / {
        proxy_pass http://${name}_server;
          
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host  \$server_name;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

EOF
done 
