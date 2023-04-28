#ifndef _VGA_ZYLO_H
#define _VGA_ZYLO_H

#include <linux/ioctl.h>

//number of supported sprites
#define SIZE 64

/*

	Sprite Indices and IDs:
	Index	Sprite 			ID	Can ID Change?
	0.	Note I 1a			yes
	1.   	Note I 2a			yes
	2.   	Note I 1b		0	yes
	3.   	Note I 2b		0	yes
	4.   	Note I 1c		0	yes
	5.   	Note I 2c		0	yes
	6.  	Note II 1a			yes
	7.   	Note II 2a			yes
	8.   	Note II 1b		0	yes
	9.   	Note II 2b		0	yes
	10.  	Note II 1c		0	yes
	11.  	Note II 2c		0	yes
	12.  	Note III 1a			yes
	13. 	Note III 2a			yes
	14.  	Note III 1b		0	yes
	15.  	Note III 2b		0	yes
	16.  	Note III 1c		0	yes
	17.  	Note III 2c		0	yes
	18.  	Note IV 1a			yes
	19.  	Note IV 2a			yes
	20.  	Note IV 1b		0	yes
	21.  	Note IV 2b		0	yes
	22.  	Note IV 1c		0	yes
	23.  	Note IV 2c		0	yes
	24.  	S				no
	25.  	C				no
	26.  	O				no
	27.  	R				no
	28.  	E				no
	29.  	C				no
	30.  	O				no
	31.  	M				no
	32.  	B				no
	33.  	O				no
	34.  	Score Value 1			yes
	35.  	Score Value 2			yes
	36.  	Score Value 3			yes
	37. 	Combo Value 1			yes
	38.  	Combo Value 2			yes
	39.  	Combo Value 3			yes

 */

typedef struct{
	int len;
	int arr[4];
} queue_t;

typedef struct {
  int data[SIZE];
} vga_zylo_data_t;
  
typedef struct {
  	vga_zylo_data_t packet;
} vga_zylo_arg_t;

typedef struct {
	int x, y, dx, dy, id, index, scored;
} sprite;
#define VGA_ZYLO_MAGIC 'q'

/* ioctls and their arguments */
#define VGA_ZYLO_WRITE_PACKET _IOW(VGA_ZYLO_MAGIC, 5, vga_zylo_arg_t *)
#define VGA_ZYLO_WRITE_SCORE _IOW(VGA_ZYLO_MAGIC, 6, vga_zylo_arg_t *)
#define VGA_ZYLO_WRITE_COMBO _IOW(VGA_ZYLO_MAGIC, 7, vga_zylo_arg_t *)
#define VGA_ZYLO_READ_PACKET _IOR(VGA_ZYLO_MAGIC, 8, vga_zylo_arg_t *)

#endif


/*		Global Variables		*/

// No. of notes supported in the game
int num_notes = 4;

// No. of balls that can fall at once.
int size = 3;

// x coordinates of 4 falling notes.
x_notes = {10, 42, 100, 132, 200, 232, 300, 332};

// Initial Positions of the sprites {x_coordinate, y_coordinate, sprite_id}

int[64][2] pos_init = {

	{10, 10, 0}, // Note I 1a
	{42, 10, 0}, // Note I 2a
	{10, 10, 0}, // Note I 1b
	{42, 10, 0}, // Note I 2b
	{10, 10, 0}, // Note I 1c
	{42, 10, 0}, // Note I 2c

	{100, 10, 0}, // Note II 1a
	{132, 10, 0}, // Note II 2a
	{100, 10, 0}, // Note II 1b
	{132, 10, 0}, // Note II 2b
	{100, 10, 0}, // Note II 1c
	{132, 10, 0}, // Note II 2c

	{200, 10, 0}, // Note III 1a
	{232, 10, 0}, // Note III 2a
	{200, 10, 0}, // Note III 1b
	{232, 10, 0}, // Note III 2b
	{200, 10, 0}, // Note III 1c
	{232, 10, 0}, // Note III 2c

	{300, 10, 0}, // Note IV 1a
	{332, 10, 0}, // Note IV 2a
	{300, 10, 0}, // Note IV 1b
	{332, 10, 0}, // Note IV 2b
	{300, 10, 0}, // Note IV 1c
	{332, 10, 0}, // Note IV 2c

	{350, 100, 0}, // S
	{400, 100, 0}, // C
	{450, 100, 0}, // O
	{500, 100, 0}, // R
	{550, 100, 0}, // E

	{350, 250, 0}, // C
	{400, 250, 0}, // O
	{450, 250, 0}, // M
	{500, 250, 0}, // B
	{550, 250, 0}, // O

	{400, 50, 0}, // Score Value 1
	{450, 50, 0}, // Score Value 2
	{500, 50, 0}, // Score Value 3

	{400, 200, 0}, // Combo Value 1
	{450, 200, 0}, // Combo Value 2
	{500, 200, 0}, // Combo Value 3

	// Unused Indices (Count = 24)
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0}
}

// Relevant sprite ids

int[40] sprite_ids = {

//	Sprite ID	Sprite Name

	0,  		// Note I 1a
	1,  		// Note I 2a
	2,  		// Note I 1b
	3,  		// Note I 2b
	4,  		// Note I 1c
	5,  		// Note I 2c

	6,	  	// Note II 1a
	7, 		// Note II 2a
	8,  		// Note II 1b
	9,  		// Note II 2b
	10, 		// Note II 1c
	11, 		// Note II 2c

	12, 		// Note III 1a
	13, 		// Note III 2a
	14, 		// Note III 1b
	15, 		// Note III 2b
	16, 		// Note III 1c
	17, 		// Note III 2c

	18, 		// Note IV 1a
	19, 		// Note IV 2a
	20, 		// Note IV 1b
	21, 		// Note IV 2b
	22, 		// Note IV 1c
	23, 		// Note IV 2c

	0, 		// unused
	0, 		// unused
	0, 		// unused
	0, 		// unused
	0, 		// unused
	0, 		// unused

	24, 		// 0
	25, 		// 1
	26, 		// 2
	27, 		// 3
	28, 		// 4
	29, 		// 5
	30, 		// 6
	31, 		// 7
	32, 		// 8
	33, 		// 9

}




