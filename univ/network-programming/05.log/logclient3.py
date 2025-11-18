#!/usr/bin/env python3

import socket, sys, os, time

PORT = 50000
SLEEPTIME = 10

host = input("接続先サーバー: ")

while True:
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        client.connect(((host, PORT)))
    except:
        print("Connection Failed")
        sys.exit()

    loadave = os.getloadavg()
    print(loadave)
    client.sendall(str(loadave).encode("UTF-8"))
    client.close()
    time.sleep(SLEEPTIME)