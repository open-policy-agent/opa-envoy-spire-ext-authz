package envoy.authz

import input.attributes.request.http as http_request
import input.attributes.source.address as source_address

default allow = false

# allow Web service to access Backend service
allow {
    http_request.path == "/good/backend"
    http_request.method == "GET"
    svc_spiffe_id == "spiffe://domain.test/web-server"
}

# allow Backend service access from localhost
allow {
    source_address.Address.SocketAddress.address == "127.0.0.1"
    http_request.path == "/good/db"
    http_request.method == "GET"
}

svc_spiffe_id = client_id {
    [_, _, uri_type_san] := split(http_request.headers["x-forwarded-client-cert"], ";")
    [_, client_id] := split(uri_type_san, "=")
}
