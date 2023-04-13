/*
 * Userspace program that communicates with the aud and vga_ball device driver
 * through ioctls
 * current amplitude will be represented as the y position of the ball from vga_ball
 * reads audio and then sends amplituded
 * ayu2126
 * Columbia University
 */

#include <stdio.h>
#include "vga_ball.h"
#include "aud.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define X_MAX 78 
#define Y_MAX 58

int vga_ball_fd;
int aud_fd;

/* Read and print the background color */
void print_background_color() {
	vga_ball_arg_t vla;

	if (ioctl(vga_ball_fd, VGA_BALL_READ_BACKGROUND, &vla)) {
		perror("ioctl(VGA_BALL_READ_BACKGROUND) failed");
		return;
	}
	printf("%02x %02x %02x\n",
			vla.background.red, vla.background.green, vla.background.blue);
}

void print_cords() {
	vga_ball_cords_arg_t vbc;

	if (ioctl(vga_ball_fd, VGA_BALL_READ_CORDS, &vbc)) {
		perror("ioctl(VGA_BALL_READ_CORDS) failed");
		return;
	}
	printf("%02x_%02x\n", vbc.cords.x, vbc.cords.y);
}
/* Set the background color */
void set_background_color(const vga_ball_color_t *c)
{
	vga_ball_arg_t vla;
	vla.background = *c;
	if (ioctl(vga_ball_fd, VGA_BALL_WRITE_BACKGROUND, &vla)) {
		perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
		return;
	}
}

/* Set Cords */
void send_cords(const vga_ball_cords_t *c)
{
	vga_ball_cords_arg_t vbc;
	vbc.cords = *c;
	if (ioctl(vga_ball_fd, VGA_BALL_WRITE_CORDS, &vbc)) {
		perror("ioctl(VGA_BALL_WRITE_CORDS) failed");
		return;
	}
}

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

int get_data() {
	aud_arg_t aat;
	if (ioctl(aud_fd, AUD_READ_DATA, &aat)) {
		perror("ioctl(AUD_READ_DATA) failed");
		return 0;
	}
	return aat.memory.data;
}

/*
int get_amplitude() {
	aud_arg_t vlc;
	if (ioctl(aud_fd, AUD_READ_AMPLITUDE, &vlc)) {
		perror("ioctl(AUD_READ_AMPLITUDE) failed");
		return 0;
	}
	return vlc.audio.amplitude;
}*/

void updateBall(ball *obj) {
	obj->x += obj->dx;
	obj->y += obj->dy;
	
	if (obj->x < 1 || obj->x >= X_MAX)
		obj->dx = -obj->dx;

	if (obj->y < 1 || obj->y >= Y_MAX)
		obj->dy = -obj->dy;
}

int main()
{
	vga_ball_arg_t vla;
	vga_ball_cords_t vbc;
	
	aud_arg_t aat;
	aud_mem_t amt;

	int i;
	ball ball_obj = {.x = 639, .y = 299, .dx = 0, .dy = 0};
	mem mem_obj = {.data = 0, .address = 0, .limit = 48000};

	static const char filename1[] = "/dev/vga_ball";
	static const char filename2[] = "/dev/aud";

	printf("VGA ball Userspace program started\n");
	printf("%d\n", sizeof(int));	
	printf("%d\n", sizeof(short));

	if ((vga_ball_fd = open(filename1, O_RDWR)) == -1) {
		fprintf(stderr, "could not open %s\n", filename1);
		return -1;
	}
	if ((aud_fd = open(filename2, O_RDWR)) == -1) {
		fprintf(stderr, "could not open %s\n", filename2);
		return -1;
	}
 	FILE *fp = fopen("test.txt", "w");
	if (fp == NULL)	return -1;

	vbc.x = ball_obj.x;
	vbc.y = ball_obj.y;
	send_cords(&vbc);

	amt.size = (int) mem_obj.limit;
	
	usleep(1200000);
	send_limit(&amt);
	usleep(1200000);
	int amp = 0;

	for(int counter = 0; counter < amt.size; counter++) {
		
		mem_obj.address = counter;
		amt.address = mem_obj.address;
		//printf("%d: ", amt.address);

		send_address(&amt);	

		amt.data = get_data();
		amp = amt.data;
		//printf("%d\n", amt.data);
		fprintf(fp, "%08x\n", amp);
		
		// amp = (amp >> 8) + 239;
		// printf("%d\n", amp);
		// vbc.y = (int) amp;
		
		// send_cords(&vbc);
	}
	fclose(fp);
	
	printf("VGA BALL Userspace program terminating\n");
	return 0;
}
