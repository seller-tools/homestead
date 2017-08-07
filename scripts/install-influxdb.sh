#!/usr/bin/env bash

if [ -f /home/vagrant/.influxdb ]
then
    echo "InfluxDB already installed."
    exit 0
fi

touch /home/vagrant/.influxdb

# Add repository
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

# Install influxdb
sudo apt-get update && sudo apt-get install influxdb

# Start influx services
sudo systemctl start influxdb.service
sudo systemctl enable influxdb.service
sudo systemctl start influxd.service
sudo systemctl enable influxd.service

exit 0
