#!/bin/bash

# Set configuration file for nginx
echo Set configuration of Nginx;
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf

echo Restart nginx;
/etc/init.d/nginx restart;

# Keep alive
echo Keep alive...;
tail -f /dev/null