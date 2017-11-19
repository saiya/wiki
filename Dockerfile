FROM ubuntu:16.04

VOLUME [ "/dokuwiki" ,"/var/log" ]
ENV DOKUWIKI_ROOT "/dokuwiki"

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
      tzdata apt-utils \
      wget curl zip rsync \
      lighttpd php-cgi php-gd php-ldap php-curl php-mbstring \
      python-pip && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

ENV TZ Asia/Tokyo
RUN ln -nf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD 20-dokuwiki.conf /etc/lighttpd/conf-available/20-dokuwiki.conf

RUN lighty-enable-mod dokuwiki fastcgi accesslog && \
    mkdir /var/run/lighttpd && \
    chown www-data.www-data /var/run/lighttpd && \
    chown -R www-data:www-data /dokuwiki

RUN pip install awscli --upgrade

ADD bin/* /usr/local/bin/

EXPOSE 80
CMD [ "/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf" ]
