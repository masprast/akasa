FROM php:7.4-fpm-alpine AS base

RUN apk update --no-cache && \
    apk upgrade --no-cache

FROM base AS build

RUN chmod +x /usr/local/bin/*
RUN apk add --no-cache \
    freetype-dev \
    jpeg-dev \
    icu-dev \
    libzip-dev

#####################################
# PHP Extensions
#####################################
RUN pecl --help
# RUN pecl install apcu memcached && \
#     docker-php-ext-enable apcu memcached

# Install PHP extension
COPY ./conf/install-ext.sh /usr/local/bin/install-ext.sh
RUN chmod +x /usr/local/bin/install-ext.sh
RUN /usr/local/bin/install-ext.sh

# Configure PHP extention
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-enable mysqli
RUN docker-php-ext-configure opcache --enable-opcache
RUN docker-php-ext-configure intl

FROM base as target

#####################################
# Install libraries
#####################################
RUN apk add --no-cache \
    freetype \
    jpeg \
    icu \
    libzip

#####################################
# Copy extensions from build
#####################################
COPY --from=build /usr/local/lib/php/extensions/* /usr/local/lib/php/extensions/
COPY --from=build /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d

ADD restaurant /var/www/html
WORKDIR /
#RUN ls /usr/local/bin
#10 0.052 docker-php-entrypoint
#10 0.052 docker-php-ext-configure
#10 0.052 docker-php-ext-enable
#10 0.052 docker-php-ext-install
#10 0.052 docker-php-source
#10 0.052 pear
#10 0.052 peardev
#10 0.052 pecl
#10 0.052 phar
#10 0.052 phar.phar
#10 0.052 php
#10 0.052 php-config
#10 0.052 phpize