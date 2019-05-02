#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(cd src/web-server && GOOS=linux go build -v -o $DIR/docker/web/web-server)
(cd src/backend-server && GOOS=linux go build -v -o $DIR/docker/backend/backend-server)
(cd src/db-server && GOOS=linux go build -v -o $DIR/docker/db/db-server)
