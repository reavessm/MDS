FROM alpine:latest

RUN apk update \
  && apk add zoneminder

COPY entrypoint.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#RUN apk update \
#  && apk add zoneminder mysql mysql-client lighttpd php7-fpm php7-pdo php7-pdo_mysql \
#  && mariadb setup \
#  && /usr/bin/mysqladmin -u root password password \
#  && mysql -u root -p password -e "create database zm; create user zm@localhost identified by 'password1'; grant create, insert, select, delete, update, drop on zm.* to zm@localhost" \
#  && sed 's/^;*user.*$//g; s/^;*group.*$//g' /etc/php7/php-fpm.conf \
#  && echo "user = lighttpd" >> /etc/php7/php-fpm.conf \
#  && echo "group = lighttpd" >> /etc/php7/php-fpm.conf \
#  && vim /etc/lighttpd/lighttpd.conf \
#  && /etc/init.d/php-fpm start \
#  && /etc/init.d/lighttpd start \
#  && vim /etc/zm.conf \
#  && chown lighttpd.lighttpd /etc/zm.conf \
#  && /etc/init.d/zoneminder setup \
#  && /etc/init.d/zoneminder start \
#  && rc-update add {lighttpd,mariadb,php-fpm,zoneminder} default
