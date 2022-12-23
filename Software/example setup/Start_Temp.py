"""This module is meant to be called by FIPSTER from MATLAB to trigger the temperature sensor to start.
However, it can also be used as stand alone python program.
The address (IP, Port) and the local address need to be configured to conform to your devices.

Author: Mingyuan Zhang"""


import socket


# Parameters
RPi_address = ('192.168.30.155', 5555) # Address of the Pi
FIPSTER_address = ('192.168.30.1', 5555) # Address of the local NIC that connects to the Pi

# initialize socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(FIPSTER_address)
sock.setblocking(0)

# send trigger
sock.sendto(b'start', RPi_address)
sock.close()
