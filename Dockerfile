FROM debian:jessie

MAINTAINER "Yoel Monzon" <yoelfme@hotmail.com>

WORKDIR /tmp

# Install Nginx, PHP-FPM and popular/laravel required extensions
RUN apt-get update -y && \
    apt-get -y install nginx php5-fpm php5-mysql php5-imagick php5-imap php5-mcrypt php5-curl php5-cli php5-gd php5-pgsql php5-sqlite php5-common php-pear curl php5-json php5-redis redis-server memcached php5-memcache php5-geoip php5-ldap php5-xdebug php5-xmlrpc php5-xcache; 

# Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini && \
    sed -i "s/display_errors = Off/display_errors = stderr/" /etc/php5/fpm/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php5/fpm/php.ini && \
    sed -i "s/;opcache.enable=0/opcache.enable=0/" /etc/php5/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
    sed -i '/^listen = /clisten = 9000' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /etc/php5/fpm/pool.d/www.conf

# Set clear_env equals to no for not clear environment in FPM workers
RUN sed -i '/clear_env /c \
  clear_env = no' /etc/php5/fpm/pool.d/www.conf

# Apply Nginx configuration
ADD config/nginx.conf /opt/etc/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

# Nginx startup script
ADD config/start.sh /opt/bin/start.sh
RUN chmod u=rwx /opt/bin/start.sh

RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 80
EXPOSE 443

# Start PHP-FPM and Nginx
ENTRYPOINT ["/opt/bin/start.sh"]