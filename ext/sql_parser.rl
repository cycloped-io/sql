#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

//#define BUFFER_SIZE 32576
long BUFFER_SIZE = 1024;
//#define DEBUG
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

%%{
  machine wikiparser;

  action store_text { text_end_position = (long)(p - start) - 6; 
    // print offset and text length
    printf("%li,%li\n",text_start_position,text_end_position-text_start_position); 
    id_seen = 0;
    count += 1;
    if(count % 1000 == 0){
      fprintf(stderr,"%li\n",count);
    }
  }

  action store_name_start { name_start = p + 2; }
  action print_name { printf("%.*s\n", (int)((long) p - (long) name_start), name_start ); }

  action reset_tuple    { element_start = p + 1; field_counter = 0;}
  action store_start    { element_start = p + 1; }
  action print_number   { 
    if((1 << field_counter) & field_mask && values_flag == 1) {
      printf("%.*s\t", (int)((long) p - (long) element_start + 1), element_start - 1 ); 
    }
    field_counter += 1; 
  } 
  action print_string   { 
    if((1 << field_counter) & field_mask && values_flag == 1) {
      printf("%.*s\t", (int)((long) p - (long) element_start - 2), element_start + 1 ); 
    }
    field_counter += 1; 
  } 

  action print_null     { 
    if((1 << field_counter) & field_mask && values_flag == 1) {
      printf("\t"); 
    }
    field_counter += 1; 
  }
  action print_newline  { 
    if(values_flag == 1) {
      printf("\n"); 
    }
  }
  action values_observed { values_flag = 1; }

  insert_into = 'INSERT INTO';
  table_name = /`[^`]*`/;
  values = 'VALUES';
  open_par = '(';
  close_par = ')';
  comma = ',';
  quote = '\'';
  float = digit + ('.' digit +) ? ;
  string =  quote (/[^']/ | "\\'")* quote;
  null_key = 'NULL';

  field = float %print_number | string %print_string | null_key %print_null;

  main := (
    insert_into  space table_name @values_observed values  @store_name_start | 
    open_par %reset_tuple ( field comma @store_start ) * field close_par @print_newline |
    any ) *;

}%%

%% write data;

int main( int argc, char **argv )
{
  int cs, res = 0;
  long id_start_position, id_len, text_start_position, text_end_position, count = 0;
  int page_size = sysconf(_SC_PAGE_SIZE);
  int file;
  char * p;
  struct stat file_info;
  long file_size,pages_count;
  int id_seen = 0;
  char * name_start;
  char * element_start;
  int field_counter = 0;
  int field_mask = 0;
  int values_flag = 0;
  char buffer[BUFFER_SIZE];

  if ( argc >= 2 ) {
    if(strlen(argv[1]) > 5){
      // assume the first arg is a file path
      char *file_name = argv[1];

      for(int i =0; i < argc - 2; i++){
        int field_id = atoi(argv[i+2]);
        field_mask |= (1 << field_id);
      }
      file = open(file_name,O_RDONLY);
      if(file == -1){
        printf("File error %i\n",file);
        return file;
      }
      fstat(file,&file_info);
      file_size = file_info.st_size;
      pages_count = file_size / page_size + (file_size % page_size == 0 ? 0 : 1);
      p = (char*)mmap(NULL,pages_count * page_size,PROT_READ,MAP_SHARED,file,0);
      if(p == MAP_FAILED){
        printf("Mapping failed\n");
        return -1;
      }
      char *start = p;
      char *pe = p + file_size + 1;
      //%% write exec;
      munmap(p,pages_count * page_size);
      close(file);
    } else {

      for(int i =0; i < argc - 1; i++){
        int field_id = atoi(argv[i+1]);
        field_mask |= (1 << field_id);
      }
      // assume readin from stdin
      long bytes_read;
      long remainder = 0;

      while (1) {
        p = buffer;
        bytes_read = fread(p + remainder, 1,  BUFFER_SIZE - remainder, stdin);
        if(bytes_read == 0)
          break;
#ifdef DEBUG
        printf("\nBuffer %lu %lu\n", remainder, bytes_read);
#endif
        char *start = p;
        bytes_read += remainder;
        char *pe = p + bytes_read;
#ifdef DEBUG
        printf("================= START ==========\n");
        for (long i = 0; i < bytes_read; i++) {
          putchar(p[i]);
        }
        printf("================= END ==========\n");
#endif

        // Process the data in the buffer

        int state = 0;
        remainder = 0;

        long j;
        for (j = bytes_read-1; j > 0; j--) {
            //putchar(p[i]);
            //printf("%d\n", i);
            if (p[j] == ',') {
              state = 1;
            } else if (p[j] == ')' && state == 1) {
              pe = p + j + 1;
              remainder = bytes_read - j - 1;
              break;
            } else {
              state = 0;
            }
        }

        if(remainder >= BUFFER_SIZE){
          printf("Remainder larger than buffer!!!%lu\n", remainder);
        }
        %% write init;
        %% write exec;

        memcpy(buffer, pe, remainder);
        //free(p);
      }
    }
  } else {
    printf("sql_parser wiki-{categories|pagelinks}.gz 0 1 (ids of columns to print)\nProduces TSV with the selected columns.\n");
  }
  //free(p);
  return 0;
}
