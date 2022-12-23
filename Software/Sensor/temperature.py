"""This module measure and record temperature data using TMP117 sensor via IIC bus.
The recording is triggered by Start_Temp.py or physical button.
Upon the start of recording a TTL pulse is sent to the DAQ, which remains high for the duration of recording.
The addresses, ports, local file path, and pin numbers should be configured manually to conform to your devices. 
This module shall be placed on RPi where the login user has write permission. 

Author: Mingyuan Zhang"""

import RPi.GPIO as GPIO
import board
import adafruit_tmp117 as tmp117
import time
import csv
import datetime
import socket

# Parameters
frequency = 10  # sampling frequency in Hertz
GPIO.setmode(GPIO.BCM)  # set GPIO mode
TTL_Pin = 21  # Pin for DAQ connection
Button_Pin = 20  # Pin for physical button
address = ('192.168.30.155', 5555)  # the network address and port of the Pi
pc = ('192.168.30.1', 5555)  # default pc address and port
data_filename = f"/home/nectow/tmp_117/data/temperature_{datetime.datetime.now().strftime('%m_%d_%Y')}.csv"
data_file = open(data_filename, 'w')  # create data storage file
data_header = ['Time (s)', 'Tunnel Exhaust Temperature (Celsius)', 'Chamber Temperature (Celsius)']
mode = 'UDP'  # 'Button' or 'UDP' # It's called UDP but really means network, lazy me
buffer_size = 1024  # UDP Buffer size, must be smaller than 1500 if using ethernet

# initialization
flag = False
data_logger = csv.writer(data_file)
data_logger.writerow(data_header)
GPIO.setup(TTL_Pin, GPIO.OUT)
GPIO.setup(Button_Pin, GPIO.IN)
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # Using UDP over TCP for temporal performance
sock.bind(address)
sock.setblocking(0)
tick = 0.0001  # 100 microsecond
start_time = -1
I2C = board.I2C()  # Initialize IIC Bus
tunnel_exhaust_sensor = tmp117.TMP117(I2C, address=72)
chamber_sensor = tmp117.TMP117(I2C, address=0x49)

# standing by and waiting for trigger
if mode == 'UDP':
    while True:
        try:
            msg = sock.recvfrom(buffer_size)
            if msg[0] == b'start':
                flag = True
                break
        except BlockingIOError:
            time.sleep(tick)
elif mode == 'button':
    while True:
        if GPIO.input(Button_Pin):
            flag = True
            break
        else:
            time.sleep(tick)

# Recording start time
start_time = time.time()

# recording the data
if mode == 'UDP':  # dirty trick to improve temporal performance by sacrificing OOPiness
    while flag:
        # achor point to calculate time compensation
        time_achor = time.time()
        time_now = time_achor - start_time
        tunnel_exhaust_temp = tunnel_exhaust_sensor.temperature
        chamber_temp = chamber_sensor.temperature
        data_logger.writerow([time_now, tunnel_exhaust_temp, chamber_temp])
        try:
            msg = sock.recvfrom(buffer_size)
            if msg[0] == b'stop':
                pc = msg[1]  # sending the data only back to the host that tells the sensor to stop
                flag = False
        except BlockingIOError:
            # compensate the time used in computation
            time.sleep((1.0 / frequency) + (time_achor - time.time()))
elif mode == 'button':
    while flag:
        time_achor = time.time()
        time_now = time_achor - start_time
        tunnel_exhaust_temp = tunnel_exhaust_sensor.temperature
        chamber_temp = chamber_sensor.temperature
        data_logger.writerow([time_now, tunnel_exhaust_temp, chamber_temp])
        time.sleep(1.0 / frequency)
        if GPIO.input(Button_Pin):
            time.sleep((1.0 / frequency) + (time_achor - time.time()))
        else:
            flag = False

# Write the data file to disk
data_file.close()

# Clean up RPi GPIO Pins
GPIO.cleanup()

# transfer the data back to pc
### deprecated UDP solution
""""
with open(data_filename, 'rb') as data:
    while True:
        packet = data.read(buffer_size)
        if packet == b'':
            break
        else:
            sock.sendto(packet, pc)
    sock.sendto(b'data transfer complete', pc)
"""
### Transfer data via TCP for reliability
sock.close()
time.sleep(1)  # wait a little to make sure the receiving side is ready
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.connect(pc)
with open(data_filename, 'rb') as data:
    while True:
        packet = data.read(buffer_size)
        if packet == b'':
            sock.shutdown(socket.SHUT_RDWR)
            break
        else:
            sock.sendall(packet)

# Free up port
sock.close()
