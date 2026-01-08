#!/usr/bin/env python3

import socket

host = "127.0.0.1"
port = 7000

validid = "hogehoge"
validpw = "fugafuga"


def idpwauth(idpw):
    id, pw = idpw.split(":")
    if id != validid or pw != validpw:
        return False
    else:
        return True


ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ss.bind((host, port))
ss.listen(1)
print(f"Server listening on {host}:{port}")

while True:
    cs, addr = ss.accept()
    print(f"Connection from {addr}")
    idpw = cs.recv(4096).decode()
    if idpwauth(idpw):
        cs.send(b"Authentication Successful\n")
        data = cs.recv(4096)
        print(f"Received: {data.decode()}")
        cs.send(b"Hello, Client!\n")
    else:
        cs.send(b"Authentication Failed\n")
    cs.close()
