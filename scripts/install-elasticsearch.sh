#!/usr/bin/env bash

#if [ -f /home/vagrant/.elasticsearch ]
#then
#	echo "Elasticsearch already installed."
#    exit 0
#fi

sudo apt-get -y install openjdk-8-jdk
sudo update-alternatives --config java

wget –q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.2.deb
sudo dpkg -i elasticsearch-5.5.2.deb
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
systemctl status elasticsearch.service
touch /home/vagrant/.elasticsearch
