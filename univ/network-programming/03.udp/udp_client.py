#!/usr/bin/env python3

import socket

host = "127.0.0.1"
port = 7000
bufsize = 4096

ss = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
ss.sendto(b"Hello UDP Server", (host, port))
data = ss.recv(bufsize)
print(data.decode())
ss.close()
