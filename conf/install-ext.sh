#!/bin/bash

extensoins="bcmath exif intl mysqli opcache pcntl pdo_mysql zip apcu memcached"
for ext in $extensoins; do
        docker-php-ext-install $ext;
    done