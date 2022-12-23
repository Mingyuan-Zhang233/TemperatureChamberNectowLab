The package of Python Modules configures and operates the TMP117 IC with a RPi via IIC bus.
The current configurations works with Adafruit TMP117 sensors but with a simple twist it can work with virtually all other IIC sensors. 

Author: Mingyuan Zhang

Config:
Module lab_services.py should placed on RPi and run on boot. 
	The recommended way is to include in /etc/rc.local the following line. 
	su <your_user_name> -c "python <full_path_to_lab_services.py> &"
	Note that the '&' is important and omitting it may prevent your device from booting
Module temperature.py should be placed on RPi somewhere where your login user have write permission.The file path and address (IP, Port) variables should be configured manually to conform with your device configuration. Using of DHCP services is strongly discouraged. Wireless connection is also discouraged.

Operation

Executing module Start_Temp_Service.py signals the sensors to enter the standby stage. 

Executing module Start_Temp.py signals the sensors to start recording immediately. It is recommended to be executed at least 100 milliseconds after the sensors enter standby stage.

Executing module Stop_Temp.py signals the sensors to stop the recording. The data will be sent back to the machine executing this script 1 second after all data have been collected. If an argument is given to Stop_Temp.py, in form of "python Stop_Temp.py <filename>", the argument will be taken as file name and the data will be stored in a file named "<filename>_temperature.csv" under the same directory. If no argument is given the data will be stored in "temperature_<Current_Date>.csv" 

Those modules can be called from MATLAB to cooperates with other data acquisition techniques. 

Dependencies:
	adafruit-circuitpython-TMP117
	RPi.GPIO
