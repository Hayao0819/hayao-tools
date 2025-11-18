import socket
from typing import List, Tuple

host = "192.168.11.2"
port = 50000

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((host, port))
server.listen(50)
cs, addr = server.accept()
clientlist: List[Tuple[socket.socket, tuple[str, int]]] = []

while True:
    data = cs.recv(4096)
    if data.decode() == 'q':
        clientlist.remove((cs, addr))
    else:
        message = data.decode().split(' ', 1)
        if len(message) > 1:
            target_ips = message[0].split(',')
            msg = message[1]
            if not ((cs, addr) in clientlist):
                clientlist.append((cs, addr))
            msg = str(host) + " >"
            msg += data.decode()
            print(msg)
            for c in clientlist:
                if c[0] in target_ips:
                    msg0 = f"{(cs, addr)}> {msg}"
                    c[0].send(msg0.encode())