#!/usr/bin/env python3

import socket

def main():
    ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ss.connect(('example.com', 80))
    ss.sendall(b'GET / HTTP/1.1\r\nHost: example.com\r\n')
    data = ss.recv(4096)
    print(data.decode())
    ss.close()

if __name__ == '__main__':
    main()
