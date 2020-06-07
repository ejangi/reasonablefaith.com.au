FROM wordpress:latest

USER root

ENV GOOGLE_APPLICATION_CREDENTIALS=/tmp/service-account.json
ENV WORDPRESS_CLI_GPG_KEY 63AF7AA15067C05616FDDD88A3A2E8F226F0BC06
ENV WORDPRESS_CLI_VERSION 2.4.0
ENV WORDPRESS_CLI_SHA512 4049c7e45e14276a70a41c3b0864be7a6a8cfa8ea65ebac8b184a4f503a91baa1a0d29260d03248bc74aef70729824330fb6b396336172a624332e16f64e37ef

ENV PORT 8080
EXPOSE $PORT

ARG _SERVICE_ACCOUNT_FILE
ARG _CLOUDSQL_INSTANCE
ARG _WP_ENV
ARG _WP_THEMES
ARG _WP_PLUGINS
ARG _WP_DB_NAME
ARG _WP_DB_HOST
ARG _WP_DB_USER
ARG _WP_DB_PASSWORD
ARG _WP_AUTH_KEY
ARG _WP_SECURE_AUTH_KEY
ARG _WP_LOGGED_IN_KEY
ARG _WP_NONCE_KEY
ARG _WP_AUTH_SALT
ARG _WP_SECURE_AUTH_SALT
ARG _WP_LOGGED_IN_SALT
ARG _WP_NONCE_SALT

ENV _SERVICE_ACCOUNT_FILE=$_SERVICE_ACCOUNT_FILE
ENV _CLOUDSQL_INSTANCE=$_CLOUDSQL_INSTANCE
ENV _WP_ENV=$_WP_ENV
ENV _WP_THEMES=$_WP_THEMES
ENV _WP_PLUGINS=$_WP_PLUGINS
ENV _WP_DB_NAME=$_WP_DB_NAME
ENV _WP_DB_HOST=$_WP_DB_HOST
ENV _WP_DB_USER=$_WP_DB_USER
ENV _WP_DB_PASSWORD=$_WP_DB_PASSWORD
ENV _WP_AUTH_KEY=$_WP_AUTH_KEY
ENV _WP_SECURE_AUTH_KEY=$_WP_SECURE_AUTH_KEY
ENV _WP_LOGGED_IN_KEY=$_WP_LOGGED_IN_KEY
ENV _WP_NONCE_KEY=$_WP_NONCE_KEY
ENV _WP_AUTH_SALT=$_WP_AUTH_SALT
ENV _WP_SECURE_AUTH_SALT=$_WP_SECURE_AUTH_SALT
ENV _WP_LOGGED_IN_SALT=$_WP_LOGGED_IN_SALT
ENV _WP_NONCE_SALT=$_WP_NONCE_SALT

RUN set -ex; \
    curl https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o /usr/local/bin/cloud_sql_proxy && \ 
    chmod +x /usr/local/bin/cloud_sql_proxy

RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp-cli.phar && \
    chmod +x /tmp/wp-cli.phar && \
    mv /tmp/wp-cli.phar /usr/local/bin/wp

COPY $_SERVICE_ACCOUNT_FILE /tmp/service-account.json
COPY Docker/upload.ini /usr/local/etc/php/upload.ini
COPY Docker/wp-config.php /root/wp-config.php
COPY Docker/.htaccess /root/.htaccess
COPY Docker/cloud-sql-entrypoint.sh /usr/bin/cloud-sql-entrypoint.sh
COPY Docker/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY Docker/docker-build.sh /root/docker-build.sh

RUN chown -R www-data:www-data /usr/bin/cloud-sql-entrypoint.sh /usr/bin/docker-entrypoint.sh /etc/apache2
RUN /root/docker-build.sh
RUN sed -i "s/html/wordpress/g" /etc/apache2/sites-available/000-default.conf

USER www-data

ENTRYPOINT ["/usr/bin/cloud-sql-entrypoint.sh", "/usr/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]