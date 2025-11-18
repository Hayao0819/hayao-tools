import socket
import datetime

host = "127.0.0.1"
port = 7000
bufsize = 4096

ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ss.bind((host, port))
ss.listen(1)

while True:
    cs, addr = ss.accept()
    msg = str(datetime.datetime.now())
    data = cs.recv(bufsize)
    print(msg, data.decode(), addr)
    cs.send(b"Hello Client")
    cs.close()
