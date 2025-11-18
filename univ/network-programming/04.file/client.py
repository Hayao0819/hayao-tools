import socket

host = "127.0.0.1"
port = 7001
bufsize = 4096

ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ss.connect((host, port))

f = open('sample.txt', 'r')
senddata = f.read()
f.close()

ss.send(senddata.encode("UTF-8"))

recvdata = ss.recv(bufsize)
print(recvdata.decode("UTF-8"))

ss.close()