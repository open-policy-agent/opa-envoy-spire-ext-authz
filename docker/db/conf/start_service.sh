#!/bin/sh
db-server -log /tmp/db-server.log &
/usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log
