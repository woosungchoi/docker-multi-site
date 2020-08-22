#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"

cd /home/sammy/gnuboard/

$COMPOSE up --force-recreate --no-deps acme.sh && $COMPOSE kill -s SIGHUP nginx