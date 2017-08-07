#!/usr/bin/env bash

# Create user
influx --execute "CREATE USER homestead WITH PASSWORD 'secret' WITH ALL PRIVILEGES"

# Add dtatabase
influx --execute "CREATE DATABASE $1"

