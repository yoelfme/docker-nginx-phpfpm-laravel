FROM debian:jessie

MAINTAINER "Yoel Monzon" <yoelfme@hotmail.com>

# Install Nginx, PHP-FPM and popular/laravel required extensions
RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates \
    nginx \
    php5-fpm \
    php5-curl \
    php5-gd \
    php5-geoip \
    php5-imagick \
    php5-imap \
    php5-json \
    php5-ldap \
    php5-mcrypt \
    php5-memcache \
    php5-memcached \
    php5-mongo \
    php5-mssql \
    php5-mysqlnd \
    php5-pgsql \
    php5-redis \
    php5-sqlite \
    php5-xdebug \
    php5-xmlrpc \
    php5-xcache

# Add bundle of CA Root Certificates
ADD certs/ca-bundle.crt /certs/ca-bundle.crt

# Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini && \
    sed -i "s/display_errors = Off/display_errors = stderr/" /etc/php5/fpm/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php5/fpm/php.ini && \
    sed -i "s/;opcache.enable=0/opcache.enable=0/" /etc/php5/fpm/php.ini && \
    sed -i "s/;openssl.cafile=/openssl.cafile=\"\/certs\/ca-bundle.crt\"/" /etc/php5/fpm/php.ini && \
    sed -i "s/;curl.cainfo =/curl.cainfo=\"\/certs\/ca-bundle.crt\"/" /etc/php5/fpm/php.ini && \
    sed -i "/^listen = /clisten = /var/run/php5-fpm.sock" /etc/php5/fpm/pool.d/www.conf && \
    sed -i "/^listen.allowed_clients/c;listen.allowed_clients =" /etc/php5/fpm/pool.d/www.conf && \
    sed -i "/^;catch_workers_output/ccatch_workers_output = yes" /etc/php5/fpm/pool.d/www.conf && \
    sed -i "/clear_env /cclear_env = no" /etc/php5/fpm/pool.d/www.conf

# Apply Nginx configuration
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

RUN mkdir -p /data

VOLUME ["/data"]
VOLUME ["/certs"]

EXPOSE 80
EXPOSE 443

# Start service of PHP FPM and Nginx
CMD php5-fpm -c /etc/php5/fpm && nginx && tail -f /dev/null