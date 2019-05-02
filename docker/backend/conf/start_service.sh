#!/bin/sh
backend-server -log /tmp/backend-server.log &
/usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log
