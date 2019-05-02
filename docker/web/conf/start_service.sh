#!/bin/sh
web-server -log /tmp/web-server.log &
/usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log
