# TemperatureChamberNectowLab
This is the archive of codes and models of the animal chamber used in Nectow Lab.  
The previous repo for sensors alone has been deprecated and aggregated into this repo.

The codes necessary to run the sensors are under Software/Sensor directory.
 Sensor driving codes are native to RPi under linux environment but can be modified to be deployed on other microcontroller.
 The data aquired where send via LAN whose address are hardcoded, beware of this when setting up hardware and environment.
 
The aquired data can be sychronized by DAQ measurement with codes under Software/DataSychronization directory
  It'll automatically seek the TTL pulse and will ignore the manual input if it finds one. 
  
The physical models of the chamber can be found in the Hardware directory 
