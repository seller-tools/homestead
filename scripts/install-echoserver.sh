#!/usr/bin/env bash

if [ -f /home/vagrant/.echoserver ]
then
	if [ $(cat /home/vagrant/.echoserver) = $(npm -v) ]; then
	    echo "Laravel echo server already installed."
	    exit 0
	fi
fi

npm -v > /home/vagrant/.echoserver

npm remove -g laravel-echo-server

# Install Laravel echo server
npm install -unsafe-perm -g laravel-echo-server
