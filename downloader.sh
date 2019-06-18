#!/bin/bash

var=`dialog --stdout --menu "Choose one:" 0 0 0 --file <(awk -F ',' '{print $1, "\"" $2 "\""}' vmList.csv)` && wget `awk -F ',' '/'$var'/ {print $3}' vmList.csv`
