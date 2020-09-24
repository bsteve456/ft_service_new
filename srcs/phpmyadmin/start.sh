#! /bin/sh

#rc-service php-fpm7 start
php-fpm7
nginx -g 'daemon off;'
#tail -f /dev/null
