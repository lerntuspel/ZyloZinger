/*
 * Userspace program that communicates with the aud and vga_vylo device driver
 * through ioctls
 * current amplitude will be represented as the y position of the ball from vga_vylo
 * reads audio and then sends amplituded
 * ayu2126
 * Columbia University
 */

#include <stdio.h>
#include "vga_zylo.h"
#include "aud.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define X_MAX 640 
#define Y_MAX 480

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
	vga_zylo_arg_t vzat;
	
	aud_arg_t aat;
	aud_mem_t amt;

	int i;
	ball ball_obj0 = {.x = 123, .y =  42, .dx = -5, .dy = -5};
	ball ball_obj1 = {.x = 423, .y = 211, .dx = -5, .dy = 5};
	ball ball_obj2 = {.x =  10, .y = 123, .dx = 5,  .dy = -5};
	ball ball_obj3 = {.x = 532, .y = 271, .dx = 5,  .dy = 5};
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

	vga_zylo_data_t vzdt;
 	
	while (1) {	
		vzdt.data[0] = ball_obj0.x + (ball_obj0.y<<12) + (1<<24) + (1<<28);
		vzdt.data[1] = ball_obj1.x + (ball_obj1.y<<12) + (1<<24) + (2<<28);
		vzdt.data[2] = ball_obj2.x + (ball_obj2.y<<12) + (1<<24) + (3<<28);
		vzdt.data[3] = ball_obj3.x + (ball_obj3.y<<12) + (1<<24) + (4<<28);
		printf("%d, %d\n", ball_obj3.x, ball_obj3.y);
		printf("%08x\n", vzdt.data[3]);
		send_sprite_positions(&vzdt);
		updateBall(&ball_obj0);
		updateBall(&ball_obj1);
		updateBall(&ball_obj2);
		updateBall(&ball_obj3);


		usleep(10000);
	}



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
	
	printf("VGA BALL Userspace program terminating\n");
	return 0;
}
