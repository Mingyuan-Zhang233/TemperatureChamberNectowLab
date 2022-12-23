"""This module notify the lab_services.py module to start temperature recording services.
The address (IP, Port) and the local address need to be configured to conform to your devices.
The full path to the temperature.py module on Pi must be specified.

Author: Mingyuan Zhang"""


import pickle
import socket


# Parameters
address = ('192.168.30.1', 6666) # Local address
pi = ('192.168.30.155', 6666) # Pi address
args = ['python', '/home/nectow/tmp_117/temperature.py'] # full path


sock =socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(address)

msg = pickle.dumps(args)

sock.sendto(msg, pi)

sock.close()
