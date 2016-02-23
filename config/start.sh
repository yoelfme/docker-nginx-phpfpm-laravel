#!/bin/bash
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf
exec service php5-fpm start && /usr/sbin/nginx