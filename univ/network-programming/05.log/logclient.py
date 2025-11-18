#!/usr/bin/env python3
import socket, sys

HOST = "192.168.11.2"
PORT = 50000

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    client.connect(((HOST, PORT)))
except:
    print("Connection Failed")
    import traceback
    traceback.print_exc()
    sys.exit()

while True:
    print("Wait input")
    msg = input()
    if msg == "q":
        break
    client.sendall(msg.encode("UTF-8"))

client.close()