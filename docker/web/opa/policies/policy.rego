package envoy.authz

import input.attributes.request.http as http_request
import input.attributes.source.address as source_address

default allow = false

allowed_paths = {"/hello", "/the/good/path", "/the/bad/path"}
allowed_local_paths = {"/good/backend", "/good/db"}

# allow access to the Web service from the subnet 172.28.0.0/16 for the allowed paths
allow {
    allowed_paths[http_request.path]
    http_request.method == "GET"
    net.cidr_contains("172.28.0.0/16", source_address.Address.SocketAddress.address)
}

# allow Web service access from localhost for locally allowed paths
allow {
    source_address.Address.SocketAddress.address == "127.0.0.1"
    allowed_local_paths[http_request.path]
    http_request.method == "GET"
}
