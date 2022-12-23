"""This module notify the lab_services.py module to start temperature recording services.
The address (IP, Port) and the local address need to be configured to conform to your devices.
The full path to the temperature.py module on Pi must be specified.
The script can take in one integer argument that will be relayed to sensor as auto vent time.

Author: Mingyuan Zhang"""


import pickle
import socket
import sys
import time


# Parameters
address = ('192.168.30.1', 6666) # Local address
pi = ('192.168.30.155', 6666) # Pi listening address and port
service_address = ('192.168.30.155', 5555) # Address and Port on which the temperature service sun
args = ['python', '/home/nectow/tmp_117/temperature.py'] # full path
if len(sys.argv) <=1 :
    vent_str ='600'
else:
    vent_str = sys.argv[1]


sock =socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(address)

msg = pickle.dumps(args)

sock.sendto(msg, pi)
time.sleep(2) # wait in case the Pi jitters
vent_time = (int(vent_str)).to_bytes(16, 'big')
sock.sendto(b'set' + vent_time, service_address)

sock.close()
