#!/usr/bin/env bash

block="# Defaults to rabbit. This can be useful if you want to run more than one node
# per machine - RABBITMQ_NODENAME should be unique per erlang-node-and-machine
# combination. See the clustering on a single machine guide for details:
# http://www.rabbitmq.com/clustering.html#single-machine
#NODENAME=rabbit

# By default RabbitMQ will bind to all interfaces, on IPv4 and IPv6 if
# available. Set this if you only want to bind to one network interface or#
# address family.
#NODE_IP_ADDRESS=127.0.0.1
NODE_IP_ADDRESS=$1

# Defaults to 5672.
#NODE_PORT=5672
NODE_PORT=$2"

echo "$block" > /etc/rabbitmq/rabbitmq-env.conf

# Delete all users
for usr in $(rabbitmqctl list_users | tail -n +2 | cut -f1);
do
	rabbitmqctl delete_user $usr
done

# Reset rabbitmq
rabbitmqctl reset

# Set up admin user
rabbitmqctl add_user $3 $4
rabbitmqctl set_user_tags $3 administrator
rabbitmqctl set_permissions -p / $3 ".*" ".*" ".*"

# Set up rabbitmq console
rabbitmq-plugins enable rabbitmq_management

# Start rabbitmq server
sudo systemctl restart rabbitmq-server
