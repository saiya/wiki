# https://github.com/docker-library/docs/tree/master/php
FROM php:7.3-fpm-stretch

VOLUME [ "/dokuwiki" ]
ENV DOKUWIKI_ROOT "/dokuwiki"
WORKDIR $DOKUWIKI_ROOT

RUN apt-get update && apt-get install -y \
    supervisor nginx \
    tzdata apt-utils \
    wget curl zip unzip rsync jq \
    python-pip python-setuptools \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxml2-dev libldb-dev libldap-dev \
	--no-install-recommends && \
    apt-get clean autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}

# Install packages and PHP extensions

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so
# Note: PHP extensions `curl`, `mbstring` are already installed in base image
RUN docker-php-ext-install -j$(nproc) iconv xml ldap \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd
# https://stackoverflow.com/a/47673183
RUN pecl install mcrypt-1.0.2 && docker-php-ext-enable mcrypt

# Fix timezone
ENV TZ Asia/Tokyo
RUN ln -nf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install AWS CLI
RUN pip install awscli --upgrade

# Configure PHP
ADD php/conf.d/* /usr/local/etc/php/conf.d/
ADD php/php-fpm.d /usr/local/etc/php-fpm.d/
ADD php/php-fpm.conf /usr/local/etc/

# Deploy config
ADD supervisord.conf /
ADD nginx.conf /etc/nginx/nginx.conf

# Deploy scripts
ADD bin/* /usr/local/bin/
ADD entrypoint.sh /

EXPOSE 80
CMD "/entrypoint.sh"
