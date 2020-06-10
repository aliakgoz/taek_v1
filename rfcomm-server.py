# file: rfcomm-server.py
# auth: Albert Huang <albert@csail.mit.edu>
# desc: simple demonstration of a server application that uses RFCOMM sockets
#
# $Id: rfcomm-server.py 518 2007-08-10 07:20:07Z albert $

from bluetooth import *
import time

server_sock=BluetoothSocket( RFCOMM )
server_sock.bind(("",PORT_ANY))
server_sock.listen(1)

port = server_sock.getsockname()[1]

uuid = "94f39d29-7d6d-437d-973b-fba39e49d4ee"

advertise_service( server_sock, "SampleServer",
                   service_id = uuid,
                   service_classes = [ uuid, SERIAL_PORT_CLASS ],
                   profiles = [ SERIAL_PORT_PROFILE ], 
#                   protocols = [ OBEX_UUID ] 
                    )
                   
print("Waiting for connection on RFCOMM channel", port)

# client_sock, client_info = server_sock.accept()
# print("Accepted connection from", client_info)

# try:
#     while True:
#         client_sock.send("Echo =>")
#         #server_sock.send(b'deneme')
#         # if not data:
#         #     break
#         # print("Received", data)
# except OSError:
#     pass

# print("Disconnected.")

# client_sock.close()
# server_sock.close()
# print("All done.")


client_sock, address = server_sock.accept()
print("Accepted connection from", address)

#data = client_sock.recv(1024)
#print("Data received:", str(data))
i = 0
while True:
    i = i + 1
    time.sleep(0.5)
    client_sock.send(bytes(str(i) +",25.3,"+str(i*10)+",\r\n", 'utf-8'))
    #data = client_sock.recv(1024)
    #print("Data received:", str(data))

client_sock.close()
server_sock.close()