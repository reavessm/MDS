#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="unifi"
conDB=""
conNet=""

conImg="$conName"

args="-d"
args+=" -p 3478:3478/udp"
args+=" -p 10001:10001/udp"
args+=" -p 8080:8080"
args+=" -p 8880:8880"
args+=" -p 3478:3478"
args+=" -p 8081:8081"
args+=" -p 8443:8443"
args+=" -p 443:443"
args+=" -p 8843:8843"
args+=" -p 6789:6789"
args+=" -p 27117:27117"
args+=" -p 1900:1900"
args+=" -p 5656-5699:5656-5699"
args+=" -p 8022:22"

# run args
$1
