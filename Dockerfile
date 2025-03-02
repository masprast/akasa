FROM php:7.4-fpm-alpine AS base

RUN apk update --no-cache && \
    apk upgrade --no-cache

FROM base AS build

RUN apk add --no-cache \
    freetype-dev \
    jpeg-dev \
    icu-dev \
    libzip-dev

#####################################
# PHP Extensions
#####################################
# Install PHP shared memory driver
RUN pecl install APCu && \
    docker-php-ext-enable apcu

# Install PHP extension
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif
RUN docker-php-ext-install intl
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip

RUN docker-php-ext-install gd
# Configure PHP extention
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg && \
    docker-php-ext-enable mysqli

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
