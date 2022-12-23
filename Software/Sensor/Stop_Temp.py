"""This module is meant to be called by FIPSTER from MATLAB to trigger the temperature sensor to stop.
However, it can also be used as stand alone python program.
The address (IP, Port) and the local address need to be configured to conform to your devices.
The data transfer will initiate 1 second after all data have been collected. 
The data will be transferred in 1kb chunks by default.
The behavior of data transfer might varies across different OS.

Author: Mingyuan Zhang"""


import socket
import datetime
import time
import sys


# Parameters
RPi_address = ('192.168.30.155', 5555) # pi address
FIPSTER_address = ('192.168.30.1', 5555) # local NIC
if len(sys.argv) <=1 :
    data_filename = f"temperature_{datetime.datetime.now().strftime('%m_%d_%Y')}.csv"
else:
    data_filename = f"{sys.argv[1]}_temperature.csv"
data_file = open(data_filename, 'wb')

# initialize socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(FIPSTER_address)

# send trigger
sock.sendto(b'stop', RPi_address)
sock.close()

# receive the data
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(FIPSTER_address)
sock.listen(1)
data_sock, address = sock.accept()
while True:
    data = data_sock.recv(1024)
    if len(data) > 0:
        data_file.write(data)
    else:
        try:
            data_sock.shutdown(socket.SHUT_RDWR)
        except OSError:
            print('You poor man must be using Mac!')
        break
data_file.close()
data_sock.close()
sock.close()
