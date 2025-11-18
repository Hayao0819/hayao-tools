import socket

host = "192.168.11.7"
port = 50000

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind((host,port))

clientlist = []

while True:
    data, client = server.recvfrom(4096)
    if not (client in clientlist):
        clientlist.append(client)
    if data.decode() == 'q':
        clientlist.remove(client)
    else:
        msg = str(client) + " >"
        msg += data.decode()
        print(msg)
        for c in clientlist:
            server.sendto(msg.encode(), c)