#!/usr/bin/env python3

import socket
import time

host = "127.0.0.1"
port = 7000
bufsize = 4096
num = 1000

ts = time.perf_counter()

for i in range(1, num + 1):
    ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ss.connect((host, port))
    ss.send(str(i).encode())
    data = ss.recv(bufsize)
    # print(data.decode())
    ss.close()
te = time.perf_counter()
print(f"TCP: {num} times took {te - ts} seconds") # TCP: 1000 times took 0.25178540400156635 seconds
