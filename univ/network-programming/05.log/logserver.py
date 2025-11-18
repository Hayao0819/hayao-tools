import socket, datetime

PORT = 50000
BUFSIZE = 4096

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(("", PORT))

server.listen()

while True:
    client, addr = server.accept()
    d = datetime.datetime.now()
    fname = d.strftime("%m%d%H%M%S%f")
    print(fname, "接続要求あり")
    print(client)
    fout = open(fname + ".txt", "wt")
    try:
        while True:
            data = client.recv(BUFSIZE)
            if not data:
                break
            print(data.decode("UTF-8"))
            print(data.decode("UTF-8"), file=fout)
    except:
        print("Error (Terminated)")

    client.close()
    fout.close()