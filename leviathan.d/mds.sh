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
conName="leviathan"

# You must specify a container image.
conImg="leviathan"

# Uncomment this if the container ONLY accepts https requests.  NOTE: Even if
# you leave this commented out, users will still have https to the proxy.
# Normally, it's safe to leave this alone
useHTTPS=true

# Uncomment this if you want this name resolvable ONLY on the LAN
private=true

# Put the port you want to be made public to the load balancer.
exposedPort=7070

# Put the IP of the host of the vm if not managed by MDS.
# Normally, it's safe to ignore this.
conIP=192.168.0.5

# Ovewrite these methods for vms not managed in MDS.  The proxy will still
# point to the service, but will not create it.  This is normally used with the
# conIp variable to specify that the VM is on a different host.
function run() {
  print "$conName is not managed by MDS"
}

function stop() {
  print "$conName is not managed by MDS"
}

function remove() {
  print "$conName is not managed by MDS"
}

function start() {
  print "$conName is not managed by MDS"
}

# Run args.  Do NOT delete this deceptively simple command.
$1
