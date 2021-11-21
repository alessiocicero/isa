#include<stdio.h>
#include<stdlib.h>

#define N 1 /// order of the filter
#define NB 9  /// number of bits

const int b0 = 107; /// coefficient b0
const int b[N]={107}; /// b array
const int a[N]={-41}; /// a array
//const int a[N]={256, -41}; /// a array

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{
  static int sw[N]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N; i++)
      sw[i] = 0;
  }

  /// compute feed-back and feed-forward
  fb = 0;
  ff = 0;
  for (i=0; i<N; i++)
  {
    fb -= (sw[i]*(a[i]>>1)) >> (NB-2);
    
    if (fb > 127)
    {
    	fb = 127;
    }
    if (fb < -128)
    {
    	fb = -128;
    }
    
    ff += (sw[i]*(b[i]>>1)) >> (NB-2);
    
   if (ff > 127)
    {
    	ff = 127;
    }
    if (ff < -128)
    {
    	ff = -128;
    }
    
  }

  /// compute intermediate value (w) and output sample
  x = x >> 1;
  w = x + fb;
  
  if (w > 127)
    {
    	w = 127;
    }
    if (w < -128)
    {
    	w = -128;
    }
    
  y = (w*(b0>>1)) >> (NB-2);
  
  if (y > 127)
    {
    	y = 127;
    }
    if (y < -128)
    {
    	y = -128;
    }
    
  y += ff;
  
    if (y > 127)
    {
    	y = 127;
    }
    if (y < -128)
    {
    	y = -128;
    }

  /// update the shift register
  for (i=N-1; i>0; i--)
    sw[i] = sw[i-1];
  sw[0] = w;

  return y << 1;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;

  /// check the command line
  if (argc != 3)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n");
    exit(2);
  }
  fp_out = fopen(argv[2], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do{
    y = myfilter(x);
    fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);

  return 0;

}
