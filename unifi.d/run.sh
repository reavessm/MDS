#!/bin/ash

for i in "/config/*"
do
  ln -s $i "/srv/lib/UniFi/data`basename $i`" "/srv/UniFi/lib/data"
done

/usr/bin/java -Xmx1024M -jar /srv/UniFi/lib/ace.jar start


#while :
#do
  #/usr/bin/java -Xmx1024M -jar /srv/UniFi/lib/ace.jar start
#done
