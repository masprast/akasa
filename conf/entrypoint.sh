#!/bin/bash

# start service
a2ensite restaurant.conf && a2dissite 000-default.conf
rc-service apache2 start
rc-update add apache2
rc.service php-fpm7 reload && rc-service apache2 reload