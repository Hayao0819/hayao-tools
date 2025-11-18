#!/usr/bin/env python3

import socket

host = "127.0.0.1"
port = 7000
bufsize = 4096

ss = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
ss.bind((host, port))
while True:
    data, addr = ss.recvfrom(bufsize)
    print(data.decode(), addr)
    ss.sendto(b"Hello UDP Client", addr)
ss.close()
