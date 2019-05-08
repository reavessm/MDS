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
conName="gitlab"

# You must specify a container image
conImg="gitlab/gitlab-ce"

# If your container does not need a separate DB or network, leave these
# commented out
#conDB="$conName-DB"
#conDBImg="mariadb"
#conNet="$conName-net"

# Put the port you want to be made public to the load balancer
exposedPort=8084

# Use this block to prompt for usernames and passwords, but only if there is
# no container named conName
#if [ -z "`docker ps -a | grep $conName`" ]
#then
#  read -p "Please enter keycloak username: " username
#  read -s -p "Please enter keycloak password: " password \
#    && echo
#fi
# These are the args passed to the `docker run` command.  Make sure all args
# EXCEPT for the first one start with a space
args="-d"
#args+=" --net $conNet"
#args+=" -e KEYCLOAK_USER=$username"
#args+=" -e KEYCLOAK_PASSWORD=$password"
args+=" -p 8084:80"
args+=" -v /mnt/VMStorage/Git/gitlab-config:/etc/gitlab:Z"
args+=" -v /mnt/VMStorage/Git/gitlab-logs:/var/log/gitlab:Z"
args+=" -v /mnt/VMStorage/Git/gitlab-data:/var/opt/gitlab:Z"
#args+=" -e GITLAB_OMNIBUS_CONFIG='`cat gitlab.rb`'"

# These are the args passed to the `docker run` command for the DB, if conDB is
# not blank.  Make sure all args EXCEPT for the first one start with a space
#dbArgs="-d"
#dbArgs+=" --net $conNet"
#dbArgs+=" -e MYSQL_ROOT_PASSWORD=password"
#dbArgs+=" -e MYSQL_PASSWORD=password"
#dbArgs+=" -e MYSQL_USER=keycloak"
#dbArgs+=" -e MYSQL_DATABASE=keycloak"

function preconfig() {
  print "Copying config for $conName ..."
  sudo  cp ./gitlab.rb /mnt/VMStorage/Git/gitlab-config
  printRed "Done copying config for $conName!"
}

#function postconfig() {
  #if [ `docker container list | grep $conName` ]
  #then
    #docker container list | grep $conName | grep starting &>/dev/null
    #while [[ "$?" != "0" ]]
    #do
      #sleep 5
      #date
      #docker container list | grep $conName | grep starting &>/dev/null
    #done

    #cat gitlab.rb | docker exec -d $conName /bin/bash -c \
     #'cat > /etc/gitlab.rb && gitlab-ctl reconfigure && gitlabctl-ctl restart'
  #fi
#}

# Run args.  Do not delete this deceptively simple command
$1
