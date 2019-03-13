#!/bin/bash

[ -f ../mds.sh ] && source ../mds.sh || exit 1

conName="proxy"

conImg="proxy"

# Make sure you put a space at the beginning of every arg EXCEPT the first
args="-d"
args+=" -p 80:80"

# run args
$1
