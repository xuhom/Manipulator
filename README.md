# Manipulator
Robot with the real-time simulation

# Project
This project consists of 3 part:
- graphical application (simulation’s behavior is controlled via Bluetooth, connected to the real robotic-arm)
- robot contoller (Arduino board with connected Bluetooth module)
- 3D model of robotic-arm (imported to graphical application)

#Graphical application
 In order to gain ability to run the Xcode project you have to install one pod.
 Follow the steps:
  - change directory to the directory where downloaded Xcode project is stored
  - write command: `pod init`
  - in newly created podfile add line: `'ORSSerialPort', '~> 2.0.1'` or newest version if exists
  - open up file `.workspace` 
  That's it. 
 To find more information about serial communication go to: [ORSSerialPort]
[ORSSerialPort]:https://cocoapods.org/pods/ORSSerialPort


#Arduino 
 Program was tested on `Arduino Leonard board`, but I hope there will be no problem to run it on any other board. 
 Except Arduino device you also should have `SPP Bluetooth Module` (for example HC-05), some cables and servos
