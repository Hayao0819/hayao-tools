import socket, threading, sys

host = "127.0.0.1"
port = 5000

def server_handler(client):
    while True:
        data = client.recv(4096)
        print(data.decode())
        client.close()

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))

p = threading.Thread(target=server_handler, args=(client,))
p.setDaemon(True)

while True:
    msg = input()
    client.send(msg.encode())
    if msg == "q":
        break
    if not p.is_alive():
        p.start()

client.close()