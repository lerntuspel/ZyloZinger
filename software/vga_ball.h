#ifndef _VGA_BALL_H
#define _VGA_BALL_H

#include <linux/ioctl.h>

typedef struct {
	unsigned char red, green, blue;
} vga_ball_color_t;
  
typedef struct {
  	vga_ball_color_t background;
} vga_ball_arg_t;

typedef struct {
    int x, y;
} vga_ball_cords_t;

typedef struct {
    vga_ball_cords_t cords;
} vga_ball_cords_arg_t;

typedef struct {
	int x, y, dx, dy;
} ball;
#define VGA_BALL_MAGIC 'q'

/* ioctls and their arguments */
#define VGA_BALL_WRITE_BACKGROUND _IOW(VGA_BALL_MAGIC, 1, vga_ball_arg_t *)
#define VGA_BALL_READ_BACKGROUND  _IOR(VGA_BALL_MAGIC, 2, vga_ball_arg_t *)
#define VGA_BALL_WRITE_CORDS      _IOW(VGA_BALL_MAGIC, 3, vga_ball_cords_arg_t *)
#define VGA_BALL_READ_CORDS       _IOR(VGA_BALL_MAGIC, 4, vga_ball_cords_arg_t *)

#endif
