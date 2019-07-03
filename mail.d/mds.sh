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

# You must specify container name
conName="mail"

# Put the port you want to be made public to the load balancer
exposedPort=8094

# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"

function run() {
  print "$(docker-compose -p mailu up -d 2>&1)"
}

function start() {
  print "$(docker-compose -p mailu up -d 2>&1)"
}

function stop() {
  printYellow "$(docker-compose -p mailu stop 2>&1)"
}

function superRemove() {
  printRed "$(docker-compose -p mailu rm 2>&1)"
}


function deleteUser {
  read -p "Please enter the mail account name to delete (<name>@reaves.dev): "\
    username
  read -p "Are you sure you want to delete this guy? (yes,no) " ans
  read -p "Hey, are you REALLY fricken sure? Because I can't undo this. " anss

  if [[ "${ans}" == "yes" && "${anss}" == "yes" ]]
  then
    print "Well, here goes nothing..."
    docker-compose -p mailu exec admin flask mailu user-delete "${username}@reaves.dev"
    printRed "Done"
  fi
}

function addUser() {
  read -p "Please enter mail account name (<name>@reaves.dev): " username
  read -sp "Please enter mail account password: " password

  echo

  read -p "Is the user an Administrator? [y/n] " admin

  if [[ "$admin" == "y" ]]
  then
    type="admin"
  else
    type="user"
  fi

  read -p "Do you really want to add this person? [y/n] " ans

  if [[ "$ans" == "y" ]]
  then
    if [[ "${type}" == "admin" ]]
    then
      print "Creating ${username}@reaves.dev"
      docker-compose -p mailu exec admin flask mailu "${type}" "${username}" \
        reaves.dev "${password}"
      printRed "Done"
    else
      # TODO: Change domain
      print "Creating ${username}@reaves.dev"
      docker-compose -p mailu exec admin flask mailu "${type}" "${username}" \
        reaves.dev "${password}" 'SHA512-CRYPT'
      printRed "Done"
    fi
  fi
}

# TODO: Add remaining functions from https://mailu.io/1.6/cli.html, and maybe a
# list function

# Run args.  Do not delete this deceptively simple command
$1
