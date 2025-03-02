FROM php:7.4-fpm-alpine AS base

RUN apk update --no-cache && \
    apk upgrade --no-cache

FROM base AS build

RUN apk add --no-cache \
    .build-dependencies \
    $PHPIZE_DEPS \
    freetype-dev \
    jpeg-dev \
    icu-dev \
    libzip-dev

#####################################
# PHP Extensions
#####################################
# Install PHP shared memory driver
RUN ls /usr/local/bin
RUN pecl install apcu && \
    docker-php-ext-enable apcu

# Install PHP extension
RUN extensions="bcmath exif intl mysqli opcache pcntl pdo_mysql zip gd" && \
    for ext in $extensions; do \
        docker-php-ext-install $ext; \
    done

# Configure PHP extention
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg && \
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
