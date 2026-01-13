import socket, base64

host = "127.0.0.1"
port = 7000

id = "hogehoge"
pw = "fugafuga"

idpw = f"{id}:{pw}"

ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ss.connect((host, port))
ss.send(idpw.encode())

res = ss.recv(4096).decode()
print(res)

if "Successful" in res:
    i = input(">")
    ss.send(i.encode())
    data = ss.recv(4096)
    print(data.decode())

ss.close()
