/*
 * Userspace program that communicates with the aud and vga_vylo device driver
 * through ioctls
 * current amplitude will be represented as the y position of the ball from vga_vylo
 * reads audio and then sends amplituded
 * ayu2126
 * Columbia University
 */

#include <stdio.h>
#include "interfaces.h"
#include "vga_zylo.h"
#include "aud.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

#define X_MAX 639 
#define Y_MAX 479

int vga_zylo_fd;
int aud_fd;

void updateBall(sprite *obj) {
	obj->x += obj->dx;
	obj->y += obj->dy;
	if (obj->x < 0 || obj->x >= X_MAX) {
		//obj->dx = -obj->dx;
    }
	if (obj->y < 0 || obj->y > Y_MAX) {
		// obj->dy = -obj->dy;
		obj->y = 481;
		obj->id = 0;
		obj->dy = 0;
	}
	// if () {
	// 	obj->dy = -obj->dy;
	// 	obj->id = 0;
	// }
}

void scorecombosetup(sprite *sprites) {
	//index 0 acts strangly
	//'SCORE'
	sprites[1].baseid = 17; //S
	sprites[2].baseid = 12; //C
	sprites[3].baseid = 15; //O
	sprites[4].baseid = 16; //R
	sprites[5].baseid = 13; //E
	for (int i = 1; i < 6; i++) {
		sprites[i].x = 480+32*(i-1); 
		sprites[i].y = 40;
		sprites[i].dx = 0;  
		sprites[i].dy = 0; 
		sprites[i].id = sprites[i].baseid;
		sprites[i].index = i;
	}
	sprites[6].baseid = 10; //0
	sprites[7].baseid = 10; //0
	sprites[8].baseid = 10; //0
	for (int i = 6; i < 9; i++) {
		sprites[i].x = 480+32+32*(i-6); 
		sprites[i].y = 90;
		sprites[i].dx = 0;  
		sprites[i].dy = 0; 
		sprites[i].id = sprites[i].baseid;
		sprites[i].index = i;
	}

	//'COMBO'
	sprites[9].baseid =  12; //C
	sprites[10].baseid = 15; //O
	sprites[11].baseid = 14; //M
	sprites[12].baseid = 11; //B
	sprites[13].baseid = 15; //O
	for (int i = 9; i < 14; i++) {
		sprites[i].x = 480+32*(i-9); 
		sprites[i].y = 140;
		sprites[i].dx = 0;  
		sprites[i].dy = 0; 
		sprites[i].id = sprites[i].baseid;
		sprites[i].index = i;
	}
	sprites[14].baseid = 10; //0
	sprites[15].baseid = 10; //0
	sprites[16].baseid = 10; //0
	for (int i = 14; i < 17; i++) {
		sprites[i].x = 480+32+32*(i-14); 
		sprites[i].y = 190;
		sprites[i].dx = 0;  
		sprites[i].dy = 0; 
		sprites[i].id = sprites[i].baseid;
		sprites[i].index = i;
	}
}

void update_combo(sprite *sprites, const int combo) {
	int huds = (int)combo/100;
	int tens = (int)(combo - huds*100)/10;
	int ones = combo - huds*100 - tens*10;
	if (huds == 0) huds = 10;
	if (tens == 0) tens = 10;
	if (ones == 0) ones = 10;
	sprites[14].id = huds; //100s	
	sprites[15].id = tens; //10s
	sprites[16].id = ones; //1s
	return;
}

void update_score(sprite *sprites, const int score) {
	int huds = (int)score/100;
	int tens = (int)(score - huds*100)/10;
	int ones = score - huds*100 - tens*10;
	if (huds == 0) huds = 10;
	if (tens == 0) tens = 10;
	if (ones == 0) ones = 10;
	sprites[6].id = huds; //100s	
	sprites[7].id = tens; //10s
	sprites[8].id = ones; //1s
	return;
}
// dedicate all sprites below 

// spawns a block with sprite.id depending on note
void spawnnote(sprite* sprites, int note) {
	//scans sprite array for empty sprite
	if (note == 0) return;
	int i, j;
	for (i = 17; i < SIZE; i++) {
	    if (sprites[i].id == 0) break;
	}
	for (j = i+1; j < SIZE; j++) {
	    if (sprites[j].id == 0) break;
	}
	// change sprite information to match note
	sprites[i].x = 28 + 120*(note-1); 
	sprites[i].y = 0;
	sprites[i].dx = 0;  
	sprites[i].dy = 1; 
	sprites[i].id = note*2 + 16;
	sprites[i].index = i;
	sprites[j].x = 60 + 120*(note-1); 
	sprites[j].y = 0;
	sprites[j].dx = 0;  
	sprites[j].dy = 1; 
	sprites[j].id = note*2 + 17;
	sprites[j].index = j;
	return;
}


// return sprite id in region, -1 if none
int check_valid_region(sprite* sprites, int start) {
    int i;
    //int cf = *combo_flag;
    for (i = start; i < SIZE; i++) {
	    if (sprites[i].y > 380 && sprites[i].y < 481) {
	        //if (sprites[i].y == 480) cf = 0;
	        return i;
	    }
	}
	return -1;
}

// simple game of hitting random falling notes when they reach the green zone
int main()
{
	vga_zylo_arg_t vzat;

	aud_arg_t aat;
	aud_mem_t amt;

	srand(time(NULL));

	static const char filename1[] = "/dev/vga_zylo";
	static const char filename2[] = "/dev/aud";

	printf("VGA zylo test Userspace program started\n");
	printf("%d\n", sizeof(int));	
	printf("%d\n", sizeof(short));

	if ((vga_zylo_fd = open(filename1, O_RDWR)) == -1) {
		fprintf(stderr, "could not open %s\n", filename1);
		return -1;
	}
	if ((aud_fd = open(filename2, O_RDWR)) == -1) {
		fprintf(stderr, "could not open %s\n", filename2);
		return -1;
	}
 	FILE *fp = fopen("test.txt", "w");
	if (fp == NULL)	return -1;
	
	sprite *sprites = NULL;	
	sprites = calloc(SIZE, sizeof(*sprites));
	
	int score = 0;
	int combo = 0;
	scorecombosetup(sprites);
	
	//packet of sprite data to send
	vga_zylo_data_t vzdt;
	
	// int *combo_flag; 
	//*combo_flag = 1;
	int counter = 0; 	
	int gamecounter = 0;
    int validleft, validright;
    
	while (gamecounter <= 1000) {
		if ((counter%10)==0) gamecounter++;
		
		if ((counter%132)==0) {
		    spawnnote(sprites, (rand() % 5));
		}
		
		validleft = check_valid_region(sprites, 17);
		validright = check_valid_region(sprites, validleft+1);
		amt.data = get_aud_data(aud_fd);
		if (amt.data == (1+(sprites[validleft].id-17)>>1)) {
		    sprites[validleft].y = 481;
		    sprites[validright].y = 481;
		    score++;
		    if (1) combo++;
 		}
		update_combo(sprites, 1+(sprites[validleft].id-17)>>1);
		update_score(sprites, score);
			
		//package the sprites together
		for (int i = 0; i < SIZE; i++) {
			vzdt.data[i] = (sprites[i].index<<26) + (sprites[i].id<<20) + (sprites[i].y<<10) + (sprites[i].x<<0);
		}
		//send package to hardware
		send_sprite_positions(&vzdt, vga_zylo_fd);
		//update spirtes on software side
		for (int i = 0; i < SIZE; i++) {
			updateBall(&sprites[i]);
		}
		//pause to let hardware catch up
		counter++;
		usleep(10000);
	}
	free (sprites);

	// amt.size = (int) mem_obj.limit;
	// amt.mode = (int) mem_obj.mode;
	// usleep(1200000);
	// send_mode(&amt);
	// send_limit(&amt);
	// usleep(12000000);
	// int amp = 0;
	// amt.size = 0;
	// // send_limit(&amt);
	// for(int counter = 0; counter < amt.size; counter++) {
	// 		mem_obj.address = counter;
	// 		amt.address = mem_obj.address;
	// 	//printf("%d: ", amt.address);
	// 		send_address(&amt);	
	// 		amt.data = get_data();
	// 		amp = amt.data;
	// 	//printf("%d\n", amt.data);
	// 		fprintf(fp, "%08x\n", amp);
	// }
	// fclose(fp);
	

	return 0;
}
