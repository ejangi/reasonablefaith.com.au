#!/usr/bin/env bash

# Connect to the database:
echo "Instance: ${_CLOUDSQL_INSTANCE}"
/usr/bin/cloud-sql-entrypoint.sh
sleep 3

mkdir -p /var/www/wordpress
cp -R /usr/src/wordpress /var/www/
cd /var/www/wordpress

mv /root/wp-config.php wp-config.php
mv /root/.htaccess .htaccess

echo "Themes: $_WP_THEMES"
if [ "$_WP_THEMES" ]; then
    wp theme install --allow-root --force $_WP_THEMES || true
fi

echo "Plugins: $_WP_PLUGINS"
if [ "$_WP_PLUGINS" ]; then
    wp plugin install --allow-root --force $_WP_PLUGINS || true
fi

chown -R www-data:www-data .