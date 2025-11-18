#!/usr/bin/env python3

import socket

# import datetime
import threading

host = "127.0.0.1"
port = 7000
bufsize = 4096


def recv_client(cs, addr):
    data = cs.recv(bufsize)
    print(data.decode(), addr)
    cs.send(b"Hello Client")
    cs.close()


def main():

    ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ss.bind((host, port))
    ss.listen()

    while True:
        cs, addr = ss.accept()
        p = threading.Thread(target=recv_client, args=(cs, addr))
        p.start()
    # ss.close()


if __name__ == "__main__":
    main()
