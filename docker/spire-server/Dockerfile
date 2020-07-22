FROM gcr.io/spiffe-io/spire-server:0.10.1

# Override spire configurations
COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
COPY conf/agent-cacert.pem /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire
