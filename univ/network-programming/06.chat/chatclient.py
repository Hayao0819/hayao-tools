import socket, threading, time

host = "192.168.11.7"
port = 50001

def server_handler(client):
    while True:
        data = client.recv(4096)
        print(data.decode())

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# client.connect((host, port))

p = threading.Thread(target=server_handler, args=(client,),daemon=True)
# p.setDaemon(True)

while True:
    msg = input("> ")
    # msg = "Hello from j2300023"
    client.sendto(msg.encode(), (host, port))
    if msg == "q":
        break
    if not p.is_alive():
        p.start()
    time.sleep(0.5)


client.close()