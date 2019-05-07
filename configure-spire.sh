#/bin/bash
# This script starts the spire agent in the web, backend and db servers
# and creates the workload registration entries for them.

set -e

bb=$(tput bold)
nn=$(tput sgr0)

fingerprint() {
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

WEB_AGENT_FINGERPRINT=$(fingerprint docker/web/conf/agent.crt.pem)
BACKEND_AGENT_FINGERPRINT=$(fingerprint docker/backend/conf/agent.crt.pem)
DB_AGENT_FINGERPRINT=$(fingerprint docker/db/conf/agent.crt.pem)


# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamCA under
# https://github.com/spiffe/spire/blob/master/doc/spire_server.md#plugin-types)
echo "${bb}Bootstrapping trust between SPIRE agents and SPIRE server...${nn}"
docker-compose exec -T spire-server bin/spire-server bundle show |
	docker-compose exec -T web tee conf/agent/bootstrap.crt > /dev/null
docker-compose exec -T spire-server bin/spire-server bundle show |
	docker-compose exec -T backend tee conf/agent/bootstrap.crt > /dev/null
docker-compose exec -T spire-server bin/spire-server bundle show |
	docker-compose exec -T db tee conf/agent/bootstrap.crt > /dev/null

# Start up the web server SPIRE agent.
echo "${bb}Starting web server SPIRE agent...${nn}"
docker-compose exec -d web bin/spire-agent run

# Start up the backend server SPIRE agent.
echo "${bb}Starting backend server SPIRE agent...${nn}"
docker-compose exec -d backend bin/spire-agent run

# Start up the db server SPIRE agent.
echo "${bb}Starting db server SPIRE agent...${nn}"
docker-compose exec -d db bin/spire-agent run

echo "${nn}"

echo "${bb}Creating registration entry for the web server...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://domain.test/web-server \
	-parentID spiffe://domain.test/spire/agent/x509pop/${WEB_AGENT_FINGERPRINT}

echo "${bb}Creating registration entry for the backend server...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://domain.test/backend-server \
	-parentID spiffe://domain.test/spire/agent/x509pop/${BACKEND_AGENT_FINGERPRINT}

echo "${bb}Creating registration entry for the db server...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://domain.test/db-server \
	-parentID spiffe://domain.test/spire/agent/x509pop/${DB_AGENT_FINGERPRINT}
