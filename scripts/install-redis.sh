#!/usr/bin/env bash

if [ -f /home/vagrant/.redis ]
then
    echo "Redis already installed."
    exit 0
fi

touch /home/vagrant/.redis

sudo pecl install redis

sudo echo  "extension = redis.so" > /etc/php/7.1/mods-available/redis.ini
sudo ln -s /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/fpm/conf.d/redis.ini
sudo ln -s /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/cli/conf.d/redis.ini


cat /etc/php/7.1/cli/php.ini | sed '/redis/,+1 d' > /etc/php/7.1/cli/php.ini
cat /etc/php/7.1/fpm/php.ini | sed '/redis/,+1 d' > /etc/php/7.1/fpm/php.ini

sudo service nginx restart

sudo service php5.6-fpm restart
sudo service php7.0-fpm restart
sudo service php7.1-fpm restart
