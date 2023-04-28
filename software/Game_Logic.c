/*
 * Userspace program that communicates with the aud and vga_vylo device driver
 * through ioctls
 * current amplitude will be represented as the y position of the ball from vga_vylo
 * reads audio and then sends amplituded
 * ayu2126
 * Columbia University
 */

#include <stdio.h>
#include "vga_zylo_new.h" 
//#include "vga_zylo.h"
#include "aud.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#define X_MAX 640 
#define Y_MAX 480
#define VALID_MAX 450
#define VALID_MIN 380

int vga_zylo_fd;
int aud_fd;

void send_limit(const aud_mem_t *c) {
	aud_arg_t amt;
	amt.memory = *c;
	if (ioctl(aud_fd, AUD_WRITE_LIMIT, &amt)) {
		perror("ioctl(AUD_WRITE_LIMIT) failed");
		return;
	}
}
void send_address(const aud_mem_t *c) {
	aud_arg_t aat;
	aat.memory = *c;
	if (ioctl(aud_fd, AUD_WRITE_ADDRESS, &aat)) {
		perror("ioctl(AUD_WRITE_ADDRESS) failed");
		return;
	}
}
void send_mode(const aud_mem_t *c) {
	aud_arg_t aat;
	aat.memory = *c;
	if (ioctl(aud_fd, AUD_WRITE_MODE, &aat)) {
		perror("ioctl(AUD_WRITE_ADDRESS) failed");
		return;
	}
}
int get_aud_data() {
	aud_arg_t aat;
	if (ioctl(aud_fd, AUD_READ_DATA, &aat)) {
		perror("ioctl(AUD_READ_DATA) failed");
		return 0;
	}
	return aat.memory.data;
}

void send_sprite_positions(const vga_zylo_data_t *c) {
	vga_zylo_arg_t vzat;
	vzat.packet = *c;
	if (ioctl(vga_zylo_fd, VGA_ZYLO_WRITE_PACKET, &vzat)) {
		perror("ioctl(VGA_ZYLO_WRITE_PACKET) failed");
		return;
	}
}
void send_score(const vga_zylo_data_t *c) {
	vga_zylo_arg_t vzat;
	vzat.packet = *c;
	if (ioctl(vga_zylo_fd, VGA_ZYLO_WRITE_SCORE, &vzat)) {
		perror("ioctl(VGA_ZYLO_WRITE_SCORE) failed");
		return;
	}
}
void send_combo(const vga_zylo_data_t *c) {
	vga_zylo_arg_t vzat;
	vzat.packet = *c;
	if (ioctl(vga_zylo_fd, VGA_ZYLO_WRITE_COMBO, &vzat)) {
		perror("ioctl(VGA_ZYLO_WRITE_COMBO) failed");
		return;
	}
}

//get received note from audio, see which of four notes it is
//get a string in return which we compare with what we get from song.txt
//not sure what parameter to give and how to go about converting audio sample to note_id.
/*char* audio_received() {
    	//example
    	char *note_string = malloc(6);
    	strcopy(note_string,"0001");

    	return note_string;
}

//compare received note with the actual note required
int compare_note(char* actual_note, char* received_note) {
    	int note_same;
    	int i;
    	for (i = 0; i < sizeof(actual_note); i++) {
        	if (actual_note[i] != received_note[i]) {
            		note_same = 0;
            		break;
        	} else {
            		note_same = 1;
        	}
    	}
    	return note_same;
}
*/

void init_sprites(vga_zylo_data_t* sprite_data){
/*
	Initializes the zylo send data with the initial sprite IDs
	and initial sprite locations defined in vga_zylo.h

	Input: sprite_data -> pointer to zylo_send data in main()
*/	
	for(int i = 0; i < 64; i++){

		sprite_data->data[i] = pos_init[i][0] + (pos_init[i][1]<<10) + (pos_init[i][2]<<20) + (i<<26);

	}

}

void init_balls(sprite** balls){
/*
	Initializes the falling ball objects with the initial sprite IDs
	and initial sprite locations defined in vga_zylo.h

	Input: balls -> list of the falling sprites
*/
	for(int note = 0; note < num_notes; note++){
		for(int i = 0; i < size; i++){
			//separate to . notation for each element
			//balls[note][2*i] = {.x = x_notes[2*note], .y =  10, .dx = 0, .dy = 0, .id = 0, .scored = 0};
			//balls[note][2*i + 1] = {.x = x_notes[2*note + 1], .y =  10, .dx = 0, .dy = 0, .id = 0, .scored = 0};
		}
	}
}

void init_queue(queue_t* available_queue){
/*
	Initializes the a queue containing available note objects

	Input: available_queue -> list of a availabilty queue for 
				   each note
*/
    for(int i = 0; i < num_notes; i++){
        available_queue[i].len = size;
        for(int j = 0; j < size; j++)
		    available_queue[i].arr[j] = j;
    }
}

int enqueue(queue_t *available_queue, int ball_number, int note){
/*
	Adding a new element to the availability of a particular note

	Inputs: available_queue -> list of a availabilty queue for 
				   each note
	       ball_number -> a ball number {0, 1, 2}
	       note -> value from 0 to num_notes
*/
	if(available_queue[note].len != size){
		available_queue[note].arr[available_queue[note].len] = ball_number;
		available_queue[note].len++; 
	}
	else
		return -1;

	return 0;

}

int dequeue(queue_t *available_queue, int note){
/*
	Removing an element from the availability
	queue of a particular note

	Inputs: available_queue -> list of a availabilty queue for 
				   each note
	        note -> value from 0 to num_notes - 1
*/	int out;
	if(available_queue[note].len != 0){
		out = available_queue[note].arr[0];
		for(int i = 0; i < available_queue[note].len - 1; i++)
			available_queue[note].arr[i] = available_queue[note].arr[i + 1];
		
		available_queue[note].len--;		
	}
	else
		return -1;

	return out;

}

void print_q(queue_t *available_queue){

	for(int i = 0; i < num_notes; i++){
		for(int j = 0; j < available_queue[i].len; j++){
			printf("%d, ", available_queue[i].arr[j]);
		}
		printf("\n");
	}
	printf("\n");

}

void update(sprite** balls, queue_t* available_queues, int* score, int* combo){
/*
	This function performs the following tasks
	  1. updates availibility queue 
	  2. resets ball position and sprite id of the unavailable balls
	  3. updates score
	  4. updates combo
*/

	int combo_flag = 0;
	int in_valid_region = 0;

	for(int note = 0; note < num_notes; note++){
		
		for(int j = 0; j < size; j++){
			
			int detected_note = 0; // get_note(); // Need to implement this logic
			
			// Update ball y coordinate
			balls[note][j].y += balls[note][j].dy;

			/* Scoring and Comboing Logic */

			// Checking if note is in valid region
			in_valid_region = (balls[note][2*j].y > VALID_MIN) && (balls[note][2*j].y < VALID_MAX);			
			
			// Checking detected note and if the note has already been scored
			if(in_valid_region && balls[note][2*j].scored == 0 && detected_note == note){
				if(combo_flag)
					*combo++;
				*score++;
				combo_flag = 1;
				balls[note][2*j].scored = 1;
				balls[note][2*j + 1].scored = 1;
			}

			// Resetting falling balls if out of range
			if(balls[note][j].y > Y_MAX){
				
				// Check if an unscored ball gets reset
				if(balls[note][j].scored == 0){

					combo_flag = 0;
					*combo = 0;

				}
				
				// reset balls
				enqueue(available_queues, j, note);
				/*
				balls[note][2*j] = {.x = , .y =  10, .dx = 0, .dy = 0, .id = 0, .scored = 0};
				balls[note][2*j].x = x_notes[2*note];
				
				balls[note][2*j + 1] = {.x = x_notes[2*note + 1], .y =  10, .dx = 0, .dy = 0, .id = 0, .scored = 0};
				*/
			}

		}
	}	

}

void update_send_data(sprite **balls, int* score, int* combo, vga_zylo_data_t* zylo_send_data){
/*
	this function performs the following tasks
	  1. Updates the x,y positions and sprite id's of the moving balls 
	     in zylo_send_data
	  2. Updates the sprite id of score and combo in the zylo_send_data
*/

	// Updating Ball parameters in zylo_send_data
	for(int note = 0; note < num_notes; note++){
		for(int j = 0; j < size; j++){
			zylo_send_data->data[6*note + 2*j] = balls[note][2*j].x + (balls[note][2*j].y<<10) + (balls[note][2*j].id<<20) + ((6*note + 2*j)<<26);
			zylo_send_data->data[6*note + 2*j + 1] = balls[note][2*j + 1].x + (balls[note][2*j + 1].y<<10) + (balls[note][2*j + 1].id<<20) + ((6*note + 2*j + 1)<<26);
		}
	}

	// Updating Score parameters in zylo_send_data
	zylo_send_data->data[34] += ((*score % 10 + 30)<<20) - (((zylo_send_data->data[34]>>20)<<26)>>6);
	zylo_send_data->data[35] += ((*score % 100 + 30)<<20) - (((zylo_send_data->data[35]>>20)<<26)>>6);
	zylo_send_data->data[36] += ((*score % 1000 + 30)<<20) - (((zylo_send_data->data[36]>>20)<<26)>>6);
	
	// Updating Combo parameters in zylo_send_data
	zylo_send_data->data[34] += ((*combo % 10 + 30)<<20) - (((zylo_send_data->data[34]>>20)<<26)>>6);
	zylo_send_data->data[35] += ((*combo % 100 + 30)<<20) - (((zylo_send_data->data[35]>>20)<<26)>>6);
	zylo_send_data->data[36] += ((*combo % 1000 + 30)<<20) - (((zylo_send_data->data[36]>>20)<<26)>>6);

}

int main(){

	vga_zylo_arg_t vzat;
	vga_zylo_data_t zylo_send_data;
	
	aud_arg_t aat;
	aud_mem_t amt;

	mem mem_obj = {.data = 0, .address = 0, .limit = 48000, .mode = 1};

	static const char filename1[] = "/dev/vga_zylo";
	static const char filename2[] = "/dev/aud";

	printf("VGA ball Userspace program started\n");
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
/*
	FILE *fp_r = fopen('GameLogic.txt',"r");
	if (fp_r == NULL)	return -1;	
*/

	/* Initialize the positions of sprites and send them to hardware */
	init_sprites(&zylo_send_data);	
	// send_sprite_positions(&zylo_send_data);

	/* Controlling the Falling Notes */

	// char[50] buffer;
	// int game_counter = 0;

	// fscanf(fp_r, "%s", buffer);
	// int iters = atoi(buffer)
	// int available = 0; 
	// int dy_new = -1; 
	// int score = 0; 
	// int combo = 0;
/*
	// Creating and initializing a ball array for each note
	sprite[num_notes][2*size] balls;
	init_balls(balls);

	// Availability queue
	queue_t[num_notes] available_queue;
	init_queue(available_queue);

	for(int i = 0; i < atoi(iters); i++){

		for(int note = 0; note < num_notes; note++){

			// Reading the speed of the tone if it starts falling 
			fscanf(fp_r, "%s", buffer);
			dy_new = atoi(buffer);

			// Assign a new ball if present
			if(dy_new != -1){
				available = dequeue(available_queue, 0);
				if available != -1:
					balls[note][2*available].dy = dy_new;
					balls[note][2*available].scored = 0;
					balls[note][2*available].id = sprite_ids[6*note + 2*available];
					balls[note][2*available + 1].dy = dy_new;
					balls[note][2*available + 1].scored = 0;
					balls[note][2*available].id = sprite_ids[6*note + 2*available + 1];
			}

		}

		// Updating the score and positions of the falling balls
		update(balls, available_queue, &score, &combo);

		// Reflecting the updated changes from balls and score on zylo_send_data
		update_send_data(balls, &score, &combo, &zylo_send_data);

		// Send the updated locations and ids to the hardware
		send_sprite_positions(&zylo_send_data);

		game_counter++;
	}
*/
		
	printf("VGA BALL Userspace program terminating\n");
	return 0;
}







