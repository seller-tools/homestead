#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.rabbitmq ]
then
    echo "RabbitMQ already installed."
    exit 0
fi

touch /home/vagrant/.rabbitmq

# Update
apt-get install -f
dpkg --configure -a

# Install RabbitMQ
apt install -y -f rabbitmq-server

exit 0
