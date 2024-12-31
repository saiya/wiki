# https://github.com/docker-library/docs/tree/master/php
FROM php:8.3.15-fpm-bookworm

VOLUME [ "/dokuwiki" ]
ENV DOKUWIKI_ROOT=/dokuwiki
WORKDIR $DOKUWIKI_ROOT

RUN apt-get update && apt-get install -y \
    supervisor nginx \
    tzdata apt-utils \
    wget curl zip unzip rsync jq \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxml2-dev libldb-dev libldap-dev \
	--no-install-recommends && \
    apt-get clean autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}
RUN pear upgrade --force PEAR

# Install packages and PHP extensions

# RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
#     && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

# Note: PHP extensions `curl`, `mbstring` are already installed in base image
RUN docker-php-ext-install -j$(nproc) iconv xml ldap \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd
# https://stackoverflow.com/a/47673183
RUN pecl install mcrypt-1.0.7 && docker-php-ext-enable mcrypt

# Fix timezone
ENV TZ=Asia/Tokyo
RUN ln -nf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp/awscliv2 && \
    /tmp/awscliv2/aws/install

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
CMD [ "/entrypoint.sh" ]
