INFO:
Program might be fired up with connected USB cable to the computer, which enables debugging mode. You might be able to see the changing data.
However, this is only optional.
You may upload the code to the board and then connect via bluetooth.

BLUETOOTH: 
-Password: none (0000) 
-Baud Rate: 38400 
-Bits: 8 
-Parity: none 
-Stop Bits: 1

Instruction: 
In order to set: px,py,pz you have to write down in any other external application with allows you to connect via Serial Port following commands:
<px=xx.xx> <py=xx.xx> <pz=xx.xx> 	, where xx.xx is a float value

But that’s not enough to see the manipulator moving. After setting coordinates you have to confirm it with a command: <calculate>.

