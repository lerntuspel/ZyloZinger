#ifndef _AUD_H
#define _AUD_H

#include <linux/ioctl.h>

// recieve
// typedef struct {
// 	int data;
// } aud_amp_t;

typedef struct {
	int data;
	int address;
	int size;
} aud_mem_t;

typedef struct {
//	aud_amp_t audio;
	aud_mem_t memory;
} aud_arg_t;

typedef struct {
	int limit;
	int address;
	int data;
} mem;

#define AUD_MAGIC 'q'

/* ioctls and their arguments */
#define AUD_READ_DATA  		_IOR(AUD_MAGIC, 5, aud_arg_t *)
#define AUD_WRITE_LIMIT     _IOW(AUD_MAGIC, 6, aud_arg_t *)
#define AUD_WRITE_ADDRESS   _IOW(AUD_MAGIC, 7, aud_arg_t *)
#endif
