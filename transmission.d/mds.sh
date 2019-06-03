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
conName="transmission-openvpn"

# You must specify a container image.
conImg="haugene/transmission-openvpn"

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
exposedPort=9091

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
#conIP=192.168.0.0

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName.
if [ -z "`docker ps -a | awk '{print $NF}' | grep -x $conName`" ]
then
  read -p "Please enter $conName username: " username
  read -s -p "Please enter $conName password: " password \
    && echo
fi

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-d"
#args+=" -p 8888:8888"
args+=" -p 9091:9091"
args+=" -p CREATE_TUN_DEVICE=true"
#args+=" -v /mnt/VMStorage/Transmission:/etc/openvpn/nordvpn"
args+=" -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
args+=" -e OPENVPN_USERNAME=$username"
args+=" -e OPENVPN_PASSWORD=$password"
#args+=" -e LOCAL_NETWORK=192.168.0.0/24"
#args+=" -e NORDVPN_COUNTRY=Netherlands"
args+=" -e OPENVPN_CONFIG=nl150.nordvpn.com.udp"
args+=" -e OPENVPN_PROVIDER=NORDVPN"
args+=" -e GLOBAL_APPLY_PERMISSIONS=true"
args+=" -e TRANSMISSION_ALT_SPEED_DOWN=50"
args+=" -e TRANSMISSION_ALT_SPEED_ENABLED=false"
args+=" -e TRANSMISSION_ALT_SPEED_TIME_BEGIN=540"
args+=" -e TRANSMISSION_ALT_SPEED_TIME_DAY=127"
args+=" -e TRANSMISSION_ALT_SPEED_TIME_ENABLED=false"
args+=" -e TRANSMISSION_ALT_SPEED_TIME_END=1020"
args+=" -e TRANSMISSION_ALT_SPEED_UP=50"
args+=" -e TRANSMISSION_BIND_ADDRESS_IPV4=0.0.0.0"
args+=" -e TRANSMISSION_BIND_ADDRESS_IPV6=::"
args+=" -e TRANSMISSION_BLOCKLIST_ENABLED=false"
#args+=" -e TRANSMISSION_BLOCKLIST_URL=http://www.example.com/blocklist"
args+=" -e TRANSMISSION_CACHE_SIZE_MB=4"
args+=" -e TRANSMISSION_DHT_ENABLED=true"
#args+=" -e TRANSMISSION_DOWNLOAD_DIR=/data/completed"
args+=" -e TRANSMISSION_DOWNLOAD_LIMIT=100"
args+=" -e TRANSMISSION_DOWNLOAD_LIMIT_ENABLED=0"
args+=" -e TRANSMISSION_DOWNLOAD_QUEUE_ENABLED=true"
args+=" -e TRANSMISSION_DOWNLOAD_QUEUE_SIZE=5"
args+=" -e TRANSMISSION_ENCRYPTION=1"
args+=" -e TRANSMISSION_IDLE_SEEDING_LIMIT=30"
args+=" -e TRANSMISSION_IDLE_SEEDING_LIMIT_ENABLED=false"
#args+=" -e TRANSMISSION_INCOMPLETE_DIR=/data/incomplete"
args+=" -e TRANSMISSION_INCOMPLETE_DIR_ENABLED=true"
args+=" -e TRANSMISSION_LPD_ENABLED=false"
args+=" -e TRANSMISSION_MAX_PEERS_GLOBAL=200"
args+=" -e TRANSMISSION_MESSAGE_LEVEL=2"
#args+=" -e TRANSMISSION_PEER_CONGESTION_ALGORITHM="
args+=" -e TRANSMISSION_PEER_ID_TTL_HOURS=6"
args+=" -e TRANSMISSION_PEER_LIMIT_GLOBAL=200"
args+=" -e TRANSMISSION_PEER_LIMIT_PER_TORRENT=50"
args+=" -e TRANSMISSION_PEER_PORT=51413"
args+=" -e TRANSMISSION_PEER_PORT_RANDOM_HIGH=65535"
args+=" -e TRANSMISSION_PEER_PORT_RANDOM_LOW=49152"
args+=" -e TRANSMISSION_PEER_PORT_RANDOM_ON_START=false"
args+=" -e TRANSMISSION_PEER_SOCKET_TOS=default"
args+=" -e TRANSMISSION_PEX_ENABLED=true"
args+=" -e TRANSMISSION_PORT_FORWARDING_ENABLED=false"
args+=" -e TRANSMISSION_PREALLOCATION=1"
args+=" -e TRANSMISSION_PREFETCH_ENABLED=1"
args+=" -e TRANSMISSION_QUEUE_STALLED_ENABLED=true"
args+=" -e TRANSMISSION_QUEUE_STALLED_MINUTES=30"
args+=" -e TRANSMISSION_RATIO_LIMIT=2"
args+=" -e TRANSMISSION_RATIO_LIMIT_ENABLED=false"
args+=" -e TRANSMISSION_RENAME_PARTIAL_FILES=true"
args+=" -e TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=false"
args+=" -e TRANSMISSION_RPC_BIND_ADDRESS=0.0.0.0"
args+=" -e TRANSMISSION_RPC_ENABLED=true"
#args+=" -e TRANSMISSION_RPC_HOST_WHITELIST="
args+=" -e TRANSMISSION_RPC_HOST_WHITELIST_ENABLED=false"
args+=" -e TRANSMISSION_RPC_PASSWORD=$password"
args+=" -e TRANSMISSION_RPC_PORT=9091"
#args+=" -e TRANSMISSION_RPC_URL=/transmission/"
args+=" -e TRANSMISSION_RPC_USERNAME=$username"
#args+=" -e TRANSMISSION_RPC_WHITELIST=127.0.0.1"
#args+=" -e TRANSMISSION_RPC_WHITELIST_ENABLED=false"
args+=" -e TRANSMISSION_SCRAPE_PAUSED_TORRENTS_ENABLED=true"
args+=" -e TRANSMISSION_SCRIPT_TORRENT_DONE_ENABLED=false"
#args+=" -e TRANSMISSION_SCRIPT_TORRENT_DONE_FILENAME="
args+=" -e TRANSMISSION_SEED_QUEUE_ENABLED=false"
args+=" -e TRANSMISSION_SEED_QUEUE_SIZE=10"
args+=" -e TRANSMISSION_SPEED_LIMIT_DOWN=100"
args+=" -e TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED=false"
args+=" -e TRANSMISSION_SPEED_LIMIT_UP=100"
args+=" -e TRANSMISSION_SPEED_LIMIT_UP_ENABLED=false"
args+=" -e TRANSMISSION_START_ADDED_TORRENTS=true"
args+=" -e TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES=false"
args+=" -e TRANSMISSION_UMASK=2"
args+=" -e TRANSMISSION_UPLOAD_LIMIT=100"
args+=" -e TRANSMISSION_UPLOAD_LIMIT_ENABLED=0"
args+=" -e TRANSMISSION_UPLOAD_SLOTS_PER_TORRENT=14"
args+=" -e TRANSMISSION_UTP_ENABLED=true"
args+=" -e TRANSMISSION_WATCH_DIR=/data/watch"
args+=" -e TRANSMISSION_WATCH_DIR_ENABLED=true"
args+=" -e TRANSMISSION_HOME=/data/transmission-home"
args+=" -e TRANSMISSION_WATCH_DIR_FORCE_GENERIC=false"
args+=" -e ENABLE_UFW=false"
args+=" -e UFW_ALLOW_GW_NET=false"
args+=" -e UFW_EXTRA_PORTS="
args+=" -e UFW_DISABLE_IPTABLES_REJECT=false"
args+=" -e TRANSMISSION_WEB_UI="
args+=" -e PUID=1001"
args+=" -e PGID=1001"
args+=" -e TRANSMISSION_WEB_HOME="
args+=" -e DROP_DEFAULT_ROUTE="
args+=" -e WEBPROXY_ENABLED=false"
args+=" -e WEBPROXY_PORT=8888"
args+=" -e HEALTH_CHECK_HOST=google.com"
args+=" --entrypoint=/bin/bash"

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
