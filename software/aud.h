#ifndef _AUD_H
#define _AUD_H

#include <linux/ioctl.h>

// recieve
typedef struct {
	int amplitude;
} aud_amp_t;

typedef struct {
	aud_amp_t audio;
	aud_amp_t mem_limit;
} aud_arg_t;

typedef struct {
	int limit;
} mem;

#define AUD_MAGIC 'q'

/* ioctls and their arguments */
#define AUD_READ_AMPLITUDE  _IOR(AUD_MAGIC, 5, aud_arg_t *)
#define AUD_WRITE_LIMIT     _IOW(AUD_MAGIC, 6, aud_arg_t *)
#endif
