#!/bin/bash

tmp="/tmp/MDS-tmp"
newTmp="/tmp/MDS-newTmp"

if [ $# != 1 ]
then
  echo "Usage: $0 <containerToSearchFor>"
  exit 1
fi

docker search "$1" | tail -n+2 | awk \
  '{$NF=$(NF-1)=""; $1 = $1"\t"; $2 = "\""$2; $(NF-2) = $(NF-2)"\""; print}' > $tmp 

dialog --stdout --menu "Choose one:" 0 0 0 --file "$tmp" > $newTmp || exit 1

clear

cat $newTmp | cut -d "/" -f2 | ./new.sh
