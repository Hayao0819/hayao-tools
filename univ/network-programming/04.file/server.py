import socket
import threading
import datetime

host = "127.0.0.1"
port = 7001
bufsize = 4096

ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ss.bind((host, port))
ss.listen(30)

def recv_client(cs, addr):
    d = datetime.datetime.now()
    fname = d.strftime("%m%d%H%M%S")
    f = open(fname + ".txt", "w", encoding="UTF-8")
    data = cs.recv(bufsize)
    f.write(data.decode())
    f.close()
    cs.send(b'OK')
    cs.close()

while True:
    cs, addr = ss.accept()
    p = threading.Thread(target=recv_client, args=(cs, addr))
    p.start()