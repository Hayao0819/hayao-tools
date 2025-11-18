#!/usr/bin/env python3

import socket
import time

host = "127.0.0.1"
port = 7000
bufsize = 4096
num = 1000

ts = time.perf_counter()

for i in range(1, num + 1):
    ss = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    ss.sendto(str(i).encode(), (host, port))
    data = ss.recv(bufsize)
    # print(data.decode())

te = time.perf_counter()
print(f"UDP: {num} times took {te - ts} seconds") # UDP: 1000 times took 0.08277980200000457 seconds
ss.close()
