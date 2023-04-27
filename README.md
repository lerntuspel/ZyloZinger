# ZyloZingers
This device will use a microphone connected to the FPGA through the mic-in port to recognize four distinct tones being played on an external instrument. The incoming audio will be used in a video game simulation on the VGA display to earn “points” for the user if the correct notes are played at the correct time. Similar in spirit to guitar hero, trombone champ, or even DDR.

On the hardware side: The block diagram shows that on the hardware side, a microphone feeds analog signal into the onboard audio codec. The audio codec converts the analog signal into a 16-24 bit Pulse Code Modulated digital signal. These bits are then sent into our FFT accelerator and filtered to then only send to software a hotcoded digital signal representing the specific note played for software to interpret. 
Software does some magic in the game and then sends sprite and game state information to the PPU or picture processing unit called vga_zylo which takes the sprite data and sends the correct raster line signal to the vga display. 

