// tool for spatially identifying changes between two segments

#include <stdio.h>

// lseek
#include <sys/types.h>
#include <unistd.h>

// open
#include <sys/stat.h>
#include <fcntl.h>

// malloc
#include <stdlib.h>

typedef unsigned long long ulong;
typedef unsigned int uint;

ulong roundUpDiv(ulong a, ulong b){
  return (a/b) + ((a%b)?1:0);
}

int main(int argc, char** argv){
  if(argc < 3){
    printf("Usage: %s <old file> <new file>\n", argv[0]);
    return 1;
  }

  int fd_old, fd_new;
  fd_old = open(argv[1], O_RDONLY);
  fd_new = open(argv[2], O_RDONLY);

  int blocksize = 128;

  if(fd_old < 0 || fd_new < 0){
    fprintf(stderr, "couldn't open input file \'%s\'\n", fd_old<0?argv[1]:argv[2]);
    return 1;
  }
  
  off_t len_old = lseek(fd_old, 0, SEEK_END);
  off_t len_new = lseek(fd_new, 0, SEEK_END);
  off_t bound1 = len_old;
  off_t bound2 = len_new;

  if(len_old > len_new){
    bound1 = len_new;
    bound2 = len_old;
  }

  // rewind offset
  lseek(fd_old, 0, SEEK_SET);
  lseek(fd_new, 0, SEEK_SET);

  ulong* buf_old = malloc(blocksize);
  ulong* buf_new = malloc(blocksize);

  for(ulong i = 0; i < roundUpDiv(bound1, blocksize); i++){
    // read bufs
    ssize_t err = read(fd_old, buf_old, blocksize);
    if(err != blocksize){fprintf(stderr, "Didn't read fully\n");return 1;}

    err = read(fd_new, buf_new, blocksize);
    if(err != blocksize){fprintf(stderr, "Didn't read fully\n");return 1;}

    // xor
    for(uint j = 0; j < (blocksize / sizeof(ulong)); j++){
      ulong old = buf_old[j], new = buf_new[j];

      if(old ^ new){
	printf("%llu\n", i);
	break;
      }
    }	  
  }

  // count size mismatch as edits too
  for(ulong i = roundUpDiv(bound1, blocksize); i < roundUpDiv(bound2, blocksize); i++){
    printf("%llu\n", i);
  }
  
  return 0;
}
