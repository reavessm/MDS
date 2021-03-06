#!/bin/bash

hostIP="$(ip route get 1 | awk '{print $(NF-2);exit}')"

if [ -f "domain.txt" ]
then
  dom="$(cat domain.txt)"
else
	if [ "$#" == "1" ]
	then
	  dom="$1"
	else
	  dom="$(dialog --backtitle "Create proxy config" --inputbox "Enter domain name" \
      0 0 --stdout)"
	fi
fi

file="config/nginx/site-confs/default"
rm -f "$file"

# Make sure website goes first
subs="website:$(awk -F '=' '/^exposedPort/ {print $2}' ../website.d/mds.sh) "

for f in ../*.d/mds.sh
do
  # Don't reinsert website
  if [[ "$(grep -E ^exposedPort "$f")" && "$(echo "$f" | awk -F '/' '{print $2}')" != "website.d" ]]
  then
    subs+="$(echo "$f" | awk -F '/' '{print $2}' | sed 's/\.d//g'):$(awk -F '=' \
      '/^exposedPort/ {print $2}' "$f") "
  fi
done

# Upstream servers
# TODO: allow for multiple hosts
for sub in $subs
do
  name="$(echo "${sub}" | cut -d ':' -f1)"
  port="$(echo "${sub}" | cut -d ':' -f2)"
  #if [[ -f ../"${name}".d/mds.sh && "$(grep -e '^conIP' ../"${name}".d/mds.sh \
  #  | grep -qv '#')" ]]
  if [[ -f ../"${name}".d/mds.sh && "$(awk '/^conIP/' ../"${name}".d/mds.sh)" ]]
  then
    cat >> "$file" <<EOF
upstream ${name}_server {
  server $(awk -F '=' '/conIP/ {print $2}' ../"${name}".d/mds.sh):${port};
}

EOF
  else
  cat >> "$file" <<EOF
upstream ${name}_server {
    server ${hostIP}:${port};
} 

EOF
  fi
done

# Basic stuff
cat >> "$file" <<EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

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
  name="$(echo "${sub}" | cut -d ':' -f1)"
  cat >> "$file" <<EOF

server {
    listen 443;
    listen [::]:443;
EOF

  # Check if 'private' is set to 'true'
  if [ "$(awk -F '=' '/^private/ {print $2}' ../"${name}".d/mds.sh)" == "true" ]
  then
    # Block all connections except LAN
    # TODO: Find a better way to define LAN
    cat >> "$file" <<EOF
    allow 192.168.0.0/24;
    allow 172.17.0.0/16;
    deny all;
EOF
  else
    # Else allow all
    cat >> "$file" <<EOF
    allow all;
EOF
  fi

  aliases="$(awk -F '"' '/^aliases/ {gsub(/,/, " "); print $2}' ../"${name}".d/mds.sh)"

  cat >> "$file" <<EOF
    server_name ${name}.${dom} ${name}.*;
EOF
  for a in ${aliases}
  do
    cat >> "$file" <<EOF
    server_name ${a}.${dom};
EOF
  done

  cat >> "$file" <<EOF

    location / {
EOF

  # Check if 'useHTTPS' is set to 'true'
  if [ "$(awk -F '=' '/^useHTTPS/ {print $2}' ../"${name}".d/mds.sh)" == "true" ]
  then
    # Tell the proxy to use HTTPS to connect to container
    cat >> "$file" <<EOF
        proxy_pass https://${name}_server;
EOF
  else
    # Tell the proxy to use HTTP to connect to container
    cat >> "$file" <<EOF
        proxy_pass http://${name}_server;
EOF
  fi

  cat >> "$file" <<EOF
         
        proxy_set_header Referer           "";
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host  \$server_name;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade           \$http_upgrade;
        proxy_set_header Connection        \$connection_upgrade;
EOF
  #for s in $(awk -F '"' '/^proxySettings/ {print $2}' ../"${name}".d/mds.sh)
  awk -F '"' '/^proxySettings/ {print $2}' ../"${name}".d/mds.sh | while \
    read -r setting
  do
    # Must have 8 spaces for alignment
    echo "        $setting" >> $file
  done

  cat >> "$file" <<EOF
    }
}
EOF
done 
