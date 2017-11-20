# https://github.com/docker-library/php/tree/master/7.1/jessie/apache
FROM php:7.1-apache   

VOLUME [ "/dokuwiki" ]
ENV DOKUWIKI_ROOT "/dokuwiki"


# Install packages and PHP extensions
RUN apt-get update && apt-get install -y \
        tzdata apt-utils \
        wget curl zip rsync jq \
        python-pip \
	 	libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxml2-dev libldb-dev libldap-dev \
        && \
    apt-get clean autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so
RUN docker-php-ext-install -j$(nproc) iconv mcrypt xml ldap \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd
# Note: PHP extensions `curl`, `mbstring` are already installed in base image


# Change DocumentRoot
RUN sed -ri -e 's!/var/www/html!${DOKUWIKI_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${DOKUWIKI_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


# Install AWS CLI
RUN pip install awscli --upgrade


# Fix timezone
ENV TZ Asia/Tokyo
RUN ln -nf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# Configure PHP
ADD php/conf.d/* /usr/local/etc/php/conf.d/


# Deploy scripts
ADD bin/* /usr/local/bin/
ADD entrypoint.sh /


EXPOSE 80
CMD "/entrypoint.sh"
