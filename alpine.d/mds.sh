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
conName="alpinelinux3.8"

# These are the args passed to the `virt-install` command.  Make sure all args
# EXCEPT for the first one start with a space.
args="-n $conName"
args+=" --os-type=Linux"
args+=" --os-variant=alpinelinux3.8"
args+=" --check all=off"
args+=" --noreboot"
args+=" --ram=512"
args+=" --vcpu=2"
args+=" --disk path=/var/lib/libvirt/images/$conName.img,bus=virtio,size=10"
args+=" --graphics none"
args+=" --cdrom /mnt/ISOs/alpine-virt-3.8.2-x86_64.iso"
args+=" --network type=direct,source=enp37s0"

function run() {
  connect && return
  print "Installing $conName"
  sudo virt-install -q $args
  printYellow "Done"
}

function check() {
  print "Checking to see if $conName is running"
  sudo virsh list | grep $conName >/dev/null \
    && printYellow "$conName is already running" 
}

# TODO: Make variables for drivers and hostnames
function connect() {
  start || return 
  print "Connecting to $conName (Escape character it ^])"
  sudo virsh -q --connect qemu:///system console $conName
}

function start() {
  check && return
  print "Starting $conName"
  sudo virsh --connect qemu:///system start $conName &>/dev/null
}

function stop() {
  print "Stopping $conName"
  sudo virsh shutdown $conName &>/dev/null
  printYellow "Done"
}

function remove() {
  stop

  print "Removing $conName"
  sudo virsh destroy $conName &>/dev/null
  sudo virsh undefine $conName &>/dev/null
  printYellow "Done"
}

# Run args.  Do NOT delete this deceptively simple command.
$1
