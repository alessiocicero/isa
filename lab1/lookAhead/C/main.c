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
  static int sw1[N], sw2[N], sw4[N]; /// w shift register
  static int sw5[N], sw6[N], sw7[N], sw8[N], sw9[N]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int y; /// output sample
  
  //a^2 parameter ev.
  int a2 = ((a[0]>>1)*(a[0]>>1)) >> (NB);
  
  if (a2 > 127)
  { 
  	a2 = 127;
  }
  if (a2 < -128)
  {
  	a2 = -128;
  }

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N; i++)
      sw1[i] = 0;
      sw2[i] = 0;
      //sw3[i] = 0;
      sw4[i] = 0;
      sw5[i] = 0;
      sw6[i] = 0;
      sw7[i] = 0;
      sw8[i] = 0;
      sw9[i] = 0;
  }
  
  /// input shift reg (8bits)
    x = x>>1;
    
  /// compute intermediate value and output sample

    sw9[0] = ((b[0]>>1)*sw7[0]) >> (NB-2);
    
    if (sw9[0] > 127)
    {
    	sw9[0] = 127;
    }
    if (sw9[0] < -128)
    {
    	sw9[0] = -128;
    }
    
    sw8[0] = ((b0>>1)*sw6[0]) >> (NB-2);
    
    if (sw8[0] > 127)
    {
    	sw8[0] = 127;
    }
    if (sw8[0] < -128)
    {
    	sw8[0] = -128;
    }
    
    /// output evaluationì
    y = sw8[0] + sw9[0];
    
    if (y > 127)
    {
    	y = 127;
    }
    if (y < -128)
    {
    	y = -128;
    }
    
    sw7[0] = sw4[0];
    
    sw6[0] = sw2[0] + sw5[0];
    
    if (sw6[0] > 127)
    {
    	sw6[0] = 127;
    }
    if (sw6[0] < -128)
    {
    	sw6[0] = -128;
    }
    
    sw5[0] = (a2*sw4[0]) >> (NB-2);
    
    if (sw5[0] > 127)
    {
    	sw5[0] = 127;
    }
    if (sw5[0] < -128)
    {
    	sw5[0] = -128;
    }
    
    sw4[0] = sw6[0];
    
    sw2[0] = -sw1[0] + x;
    
    if (sw2[0] > 127)
    {
    	sw2[0] = 127;
    }
    if (sw2[0] < -128)
    {
    	sw2[0] = -128;
    }
    
    sw1[0] = ((a[0]>>1)*x) >> (NB-2);
    
    if (sw1[0] > 127)
    {
    	sw1[0] = 127;
    }
    if (sw1[0] < -128)
    {
    	sw1[0] = -128;
    }
    
    /// update the shift register
  for (i=N-1; i>0; i--)
  {
      sw1[i] = sw1[i-1];
      sw2[i] = sw2[i-1];
      //sw3[i] = sw3[i-1];
      sw4[i] = sw4[i-1];
      sw5[i] = sw5[i-1];
      sw6[i] = sw6[i-1];
      sw7[i] = sw7[i-1];
      sw8[i] = sw8[i-1];
      sw9[i] = sw9[i-1];
  }

  return y<<1;
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
