FROM ubuntu:16.04

VOLUME [ "/dokuwiki" ]
ENV DOKUWIKI_ROOT "/dokuwiki"

RUN DEBIAN_FRONTEND=noninteractive sh -c '\
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
      tzdata apt-utils \
      wget curl zip rsync jq \
      lighttpd php-cgi php-gd php-ldap php-curl php-mbstring php-xml \
      python-pip && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log} \
    '
RUN pip install awscli --upgrade

# Fix timezone
ENV TZ Asia/Tokyo
RUN ln -nf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD bin/* /usr/local/bin/
ADD entrypoint.sh /entrypoint.sh
# Must be after lighttpd installation
ADD lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf 
ADD lighttpd/conf-available/*.conf /etc/lighttpd/conf-available/

# Must be after lighttpd config file ADD
RUN lighty-enable-mod dokuwiki fastcgi accesslog && \
    mkdir /var/run/lighttpd && \
    gpasswd -a www-data tty && \
    chown www-data.www-data /var/run/lighttpd && \
    chown -R www-data:www-data ${DOKUWIKI_ROOT}

EXPOSE 80
CMD "/entrypoint.sh"
