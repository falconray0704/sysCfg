#!/bin/bash

# refer to:


#set -o nounset
#set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


VOLUME_VERSION="$(php -r 'require('"'"'/var/www/html/wp-includes/version.php'"'"'); echo $wp_version;')"
echo "Volume version : "$VOLUME_VERSION
echo "WordPress version : "$WORDPRESS_VERSION

if [ $VOLUME_VERSION != $WORDPRESS_VERSION ]; then
    echo "Forcing WordPress code update..."
    rm -f /var/www/html/index.php
    rm -f /var/www/html/wp-includes/version.php
fi

docker-entrypoint.sh php-fpm


