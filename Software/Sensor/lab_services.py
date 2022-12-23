"""This module is a listening service to launch the corresponding scripts requested by recording.
This module is meant to run continuously as a backgrond process on boot up.

Author: Mingyuan Zhang"""


import time
import socket
import pickle
import subprocess

# wait for 5 seconds to ensure network interfaces are properly initialized.
time.sleep(5) 

# Parameters
address = ('192.168.30.155', 6666)
log_file = '/home/nectow/service_log.txt'


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(address)

# listen for requests from FIPSTER
while True:
    msg, source = sock.recvfrom(4096)
    args = pickle.loads(msg)
    return_code = subprocess.call(args=args)
    with open(log_file, 'a+') as log:
        if return_code == 0:
            log.write('Successfully executed: ')
            for s in args:
                log.write(s+' ')
            log.write('\n')
        else:
            log.write('Failed to executed: ')
            for s in args:
                log.write(s+' ')
            log.write('\n')
