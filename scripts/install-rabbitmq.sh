#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

if [ ! -f /home/vagrant/.rabbitmq ]
then
    touch /home/vagrant/.rabbitmq

    # Update
    apt-get install -f
    dpkg --configure -a

    # Install RabbitMQ
    apt install -y -f rabbitmq-server
fi

if [ ! -f /home/vagrant/.rabbitmq_delayed_message_exchange ]
then
    wget "https://dl.bintray.com/rabbitmq/community-plugins/rabbitmq_delayed_message_exchange-0.0.1.ez"

    # TODO: change destination folder based on installed rabbitmq version
    sudo mv rabbitmq_delayed_message_exchange-0.0.1.ez /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.10/plugins/

    sudo rabbitmq-plugins enable rabbitmq_delayed_message_exchange

    touch /home/vagrant/.rabbitmq_delayed_message_exchange

    exit 0
fi

echo "RabbitMQ already installed."
exit 0

