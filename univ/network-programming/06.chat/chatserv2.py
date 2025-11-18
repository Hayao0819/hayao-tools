import socket
from typing import List, Tuple

host = "192.168.11.7"
port = 50001

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind((host,port))

clientlist = []

while True:
    data, client = server.recvfrom(4096)
    if data.decode() == 'q':
        clientlist.remove(client)
    else:
        message = data.decode().split(' ', 1)
        if len(message) > 1:
            target_ips = message[0].split(',')
            msg = message[1]
            if not (client in clientlist):
                clientlist.append(client)
            msg = str(client) + " >"
            msg += data.decode()
            print(msg)
            for c in clientlist:
                if c[0] in target_ips:
                    msg0 = f"{client}> {msg}"
                    server.sendto(msg0.encode(), c)