#!/bin/bash

DOCKER="/usr/bin/docker"

$DOCKER start acme.sh && $DOCKER exec nginx nginx -s reload
