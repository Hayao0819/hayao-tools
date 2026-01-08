#!/usr/bin/env python3

import http.server
import ssl

# サーバのアドレスとポートを設定
server_address = ("0.0.0.0", 4443)
handler = http.server.SimpleHTTPRequestHandler
httpd = http.server.HTTPServer(server_address, handler)

# SSLを設定
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain("certificate.pem", "private_key.pem")
httpd.socket = context.wrap_socket(
    httpd.socket,
    server_side=True,
)

# 起動
print("HTTPS Server running on https://0.0.0.0:4443")
httpd.serve_forever()
