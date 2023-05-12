# ZyloZingers
This device will use a microphone connected to the FPGA through the mic-in port to recognize four distinct tones being played on an external instrument. The incoming audio will be used in a video game simulation on the VGA display to earn “points” for the user if the correct notes are played at the correct time. Similar in spirit to guitar hero, trombone champ, or even DDR.

A microphone feeds analog signal into the onboard audio codec. The audio codec converts the analog signal into a 24 bit Pulse Code Modulated digital signal. Four Goertzel algorithm modules take this digital audio data and identify if 4 specific tnoes are present and relay their relative energies to each other to a detector module which identifies the strongest or if there is silence. A audio device driver sends a read request to the fpga and sends that data to software through the avalon bus. On hps side, the rythem game compares the recieved audio id signal and determines if it was the correct note the palyer should have played. It then sends all sprite position and id data to the FPGA again where our custom sprite display dirver decodes sprite id and position and displays them apporpriately on the screen.


In /software/ the game is written in test2.c
The FPGA we used was a Education Edition De1-SOC Altera Cyclone.
Programs used to design custom hardware were Intel Platform Designer and Quartus Prime.
VGA display is 640x480. 
Kernel environment headers can be found here http://www1.cs.columbia.edu/~sedwards/classes/2023/4840-spring/index.html
We extend a huge thank you to Prof Stephen Edwards and his Embedded system class for without, this project would not have been possible.
If any files do not work for whatever reason, that reason is probably you do not have the base lab3 soc_system files from http://www1.cs.columbia.edu/~sedwards/classes/2023/4840-spring/index.html
