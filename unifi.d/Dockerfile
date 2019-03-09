FROM alpine

RUN mkdir -p /etc/UniFi/log \
 && mkdir -p /etc/init.d \
 && mkdir /config \
 && touch /etc/init.d/UniFi \
 && touch /etc/UniFi/run

COPY etc/ /etc/
COPY run.sh /run.sh

RUN apk update \
  && apk add --no-cache openjdk8-jre mongodb s6 \
  && adduser -D -h /srv/unifi unifi \
  && cd /srv \
  && wget http://www.ubnt.com/downloads/unifi/5.10.17/UniFi.unix.zip \
  && unzip UniFi.unix.zip \
  && chown unifi:unifi UniFi \
  && chmod o-rwx UniFi \
  && mkdir -p /srv/UniFi/bin \
  && cd /srv/UniFi/bin \
  && rm -f mongod \
  && ln -s /usr/bin/mongod \
  && mkdir -p /etc/UniFi/log \
  && chmod 755 /etc/UniFi/run \
  && adduser -D -h /var/log log \
  && mkdir -p /var/log/UniFi \
  && chown log:log /var/log/UniFi \
  && chmod 750 /var/log/UniFi \
  && chmod 755 /etc/init.d/UniFi \
  && chmod +x /run.sh
  
EXPOSE 8443/tcp 8080/tcp 8081/tcp 8843/tcp 8880/tcp 3478/udp 6789/tcp 27117/tcp \
  5656-5699/udp 10001/udp 1900/udp 22/tcp

CMD ["/run.sh"]
#CMD ["/usr/bin/java -Xmx1024M -jar /srv/UniFi/lib/ace.jar start"]
