#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NBITS 37  //37
#define TOTAL_ROWS 17 //17
#define NAME_SIZE 128
#define SHIFT_AMOUNT 2
#define fa_array_size 1024
#define MAX_LENGTH (SHIFT_AMOUNT*(TOTAL_ROWS-2)+NBITS-2-1)


#define FULL_ADDER_PORT_MAP "FA%d:full_adder port map (A => %s, B => %s, Cin => %s, S => %s, Cout => %s);\n"
#define HALF_ADDER_PORT_MAP "HA%d:half_adder port map (A => %s, B => %s, S => %s, Cout => %s);\n"

#define inputMatrixName "pp_ext"//"partial_product"
#define FIRST_ROW_OUTPUT_ASSIGNMENT "Addend1(%d) <= %s;\n"
#define SECOND_ROW_OUTPUT_ASSIGNMENT "Addend2(%d) <=%s;\n"
#define FIRST_ROW_NULL_OUTPUT_ASSIGNMENT "Addend1(%d) <= '0';\n"
#define SECOND_ROW_NULL_OUTPUT_ASSIGNMENT "Addend2(%d) <= '0';\n"


#define VHDL_FILE_NAME "daddaTree.vhd"
#define resStringFA "resultFA"
#define coutStringFA "carryOutFA"
#define resStringHA "resultHA"
#define coutStringHA "carryOutHA"
#define HASTAGS_SEPARATOR "###################################################################\n"
#define adderIndex faCounter+haCounter
char daddaTree[TOTAL_ROWS][NBITS+SHIFT_AMOUNT*TOTAL_ROWS][NAME_SIZE];
char nextDaddaTree[TOTAL_ROWS][NBITS+SHIFT_AMOUNT*TOTAL_ROWS][NAME_SIZE];

char signalList[fa_array_size*2][NAME_SIZE];	


int counter[128];
int newCounter[128];
int coutCounter[128];
int signalCounter=0;

typedef struct{
	char input1[128];
	char input2[128];
	char cin[128];
	char cout[128];
	char result[128];
	int isFA;
	int ID;
}fullAdderStruct;


int faCounter=0;
int haCounter=0;
fullAdderStruct fullAdderArray[fa_array_size];

int layerSize[] = {2,3,4,6,9,13,19,28,42}; //Max number of operands for each layer


void printAdder(int index){
		if(fullAdderArray[index].isFA){
			printf("FULL ADDER:\t%d\n",fullAdderArray[index].ID);
		}
		else{
			printf("HALF ADDER:\t%d\n",fullAdderArray[index].ID);	
		}
		printf("Input1 name:\t%s\n",fullAdderArray[index].input1);
		printf("Input2 name:\t%s\n",fullAdderArray[index].input2);
		if(fullAdderArray[index].isFA){
			printf("Cin name: \t%s\n",fullAdderArray[index].cin);
		}
		printf("Cout name:\t%s\n",fullAdderArray[index].cout);
		printf("Result name:\t%s\n",fullAdderArray[index].result);
		printf(HASTAGS_SEPARATOR);
}


//Initialise the matrix
void initMatrix(int nRows, int nColumns){	
	char concatText[128];
	//int max_length=(nColumns+SHIFT_AMOUNT*(nRows-1));
	
	for(int i=0; i< TOTAL_ROWS;i ++){
		for(int j = 0; j < MAX_LENGTH; j++ ){
			strcpy(daddaTree[i][j],"NULL");
			newCounter[j]=0;
			coutCounter[j]=0;
			counter[j]=0;
		}
	}
	for(int i=0;i<nRows;i++){
		int k=1;
		int incremented=1;
		for(int j=0;j<MAX_LENGTH;j++){
			if(i==0){
				if(j<NBITS-1){
					strcpy(daddaTree[i][j],inputMatrixName);
					sprintf(concatText,"(%d)(%d)",i,j);
					strcat(daddaTree[i][j],concatText);
					counter[j]++;
				}/*
				else{
					strcpy(daddaTree[i][j],"NULL");
				}*/
			}
			//Case of second to last row
			else if(i==nRows-2){
				//The second -1 is because we have one less shift
				//In case of printing S
				if(j == SHIFT_AMOUNT*(i-1)){
					strcpy(daddaTree[counter[j]][j],inputMatrixName);
					sprintf(concatText,"(%d)(0)",i);
					strcat(daddaTree[counter[j]][j],concatText);
					counter[j]++;
				}
				else if(j>SHIFT_AMOUNT*(i-1)+1){
					strcpy(daddaTree[counter[j]][j],inputMatrixName);
					sprintf(concatText,"(%d)(%d)",i,j- SHIFT_AMOUNT*(i-1));
					strcat(daddaTree[counter[j]][j],concatText);
					counter[j]++;
				}/*
				else{
					strcpy(daddaTree[i][j],"NULL");
				}*/	
			}
			//Case of last row
			else if(i==nRows-1){
				//We print the first S
				if(j == SHIFT_AMOUNT*(i- 1)){
					strcpy(daddaTree[counter[j]][j],inputMatrixName);
					sprintf(concatText,"(%d)(0)",i);
					strcat(daddaTree[counter[j]][j],concatText);
					counter[j]++;
				}
				else if(j>SHIFT_AMOUNT*(i-1)+1){
					strcpy(daddaTree[counter[j]][j],inputMatrixName);
					sprintf(concatText,"(%d)(%d)",i,j- SHIFT_AMOUNT*(i-1));
					strcat(daddaTree[counter[j]][j],concatText);
					counter[j]++;
				}/*
				else{
					strcpy(daddaTree[i][j],"NULL");
				}*/
			}
			else{
				if((j>=SHIFT_AMOUNT*(i-1)) && (j < (NBITS+SHIFT_AMOUNT*(i-1)))){
					if(j==SHIFT_AMOUNT*(i-1)+1){
						//strcpy(daddaTree[i][j],"NULL");
					}
					else{
						strcpy(daddaTree[counter[j]][j],inputMatrixName);
						sprintf(concatText,"(%d)(%d)",i,j-SHIFT_AMOUNT*(i-1));
						strcat(daddaTree[counter[j]][j],concatText);
						counter[j]++;
					}
				}	
				else{
					//strcpy(daddaTree[i][j],"NULL");
				}
			}
		}
	}
	printf("Matrix Generated!\n");
}	

void resetNextMatrix(){
	for(int i=0; i< TOTAL_ROWS;i ++){
		for(int j = 0; j < MAX_LENGTH; j++ ){
			strcpy(nextDaddaTree[i][j],"NULL");
			newCounter[j]=0;
			coutCounter[j]=0;
		}
	}
}
void copyMatrix(){
	for(int i=0; i< TOTAL_ROWS;i ++){
		for(int j = 0; j < MAX_LENGTH; j++ ){
			strcpy(daddaTree[i][j],nextDaddaTree[i][j]);
			counter[j]=newCounter[j];
		}
	}	
}
//Calculate the adders for each layer
void allocateAdd(int n,int length, int nextLayer)
{
	char txtNumber[50];
	resetNextMatrix();
	//for(int i = 0;i < n; i++){
		//printf("\nProcessing row:%d\n",i);
	//for(int j=0; j<(length+SHIFT_AMOUNT*(n-1)); j++){
	for(int j=0; j<MAX_LENGTH; j++){
			//printf("%d\t",j);
		for(int i=0; i < n;i++){
			if((counter[j]+coutCounter[j])>layerSize[nextLayer]){
		 		//If we have one dot too many, we have to implement the HA
		 		//We create the HA or FA by copying the input names, and creating the result name
				strcpy(fullAdderArray[adderIndex].input1,daddaTree[i][j]);
				strcpy(fullAdderArray[adderIndex].input2,daddaTree[i+1][j]);
				//If it's a HA
				if(((counter[j]+coutCounter[j])-layerSize[nextLayer]==1)){
					fullAdderArray[adderIndex].isFA=0;
					strcpy(nextDaddaTree[newCounter[j]][j],resStringHA);
		 		//Generation of the name sequential
					sprintf(txtNumber,"%d",haCounter);
				//We save in the first available position of the new tree
					strcat(nextDaddaTree[newCounter[j]][j],txtNumber);
					strcpy(fullAdderArray[adderIndex].result,nextDaddaTree[newCounter[j]][j]);
					//Save in the signal list
					strcpy(signalList[signalCounter++],fullAdderArray[adderIndex].result);
				//Generation of the carry out name in a sequential manner
				//Carry out is saved on the first i available of the row j+1, because we save as additional bit in the following column
					strcpy(nextDaddaTree[newCounter[j+1]][j+1],coutStringHA);
					sprintf(txtNumber,"%d",haCounter);
					strcat(nextDaddaTree[newCounter[j+1]][j+1],txtNumber);
					strcpy(fullAdderArray[adderIndex].cout,nextDaddaTree[newCounter[j+1]][j+1]);
					//Save in the signal list
					strcpy(signalList[signalCounter++],fullAdderArray[adderIndex].cout);
					fullAdderArray[adderIndex].ID=haCounter;					
		 			//Now we shift the other nodes up of 1, so that we copy the correct ones next time
					for(int k=i+1;k<counter[j]-1;k++){
						strcpy(daddaTree[k][j],daddaTree[k+1][j]);	
					}
					//We increase the number of HA
					haCounter++;
					counter[j]--;
				}
				//IF it's a FA
				else{
					//We also add the Cin
					strcpy(fullAdderArray[adderIndex].cin,daddaTree[i+2][j]);
					fullAdderArray[adderIndex].isFA=1;
					strcpy(nextDaddaTree[newCounter[j]][j],resStringFA);
		 		//Generation of the name sequential
					sprintf(txtNumber,"%d",faCounter);
				//We save in the first available position of the new tree
					strcat(nextDaddaTree[newCounter[j]][j],txtNumber);
					strcpy(fullAdderArray[adderIndex].result,nextDaddaTree[newCounter[j]][j]);
					//Save in the signal list
					strcpy(signalList[signalCounter++],fullAdderArray[adderIndex].result);
				//Generation of the carry out name in a sequential manner
				//Carry out is saved on the first i available of the row j+1, because we save as additional bit in the following column
					strcpy(nextDaddaTree[newCounter[j+1]][j+1],coutStringFA);
					sprintf(txtNumber,"%d",faCounter);
					strcat(nextDaddaTree[newCounter[j+1]][j+1],txtNumber);
					strcpy(fullAdderArray[adderIndex].cout,nextDaddaTree[newCounter[j+1]][j+1]);
		 			//Save in the signal list
					strcpy(signalList[signalCounter++],fullAdderArray[adderIndex].cout);
					fullAdderArray[adderIndex].ID=faCounter;						
		 			//Now we shift the other nodes up of 2, so that if more then on structure is required we can apply to it
					for(int k=i+1;k<counter[j]-2;k++){
						strcpy(daddaTree[k][j],daddaTree[k+2][j]);	
					}

		 			//We used three nodes in input and get one in output
					counter[j]-=2;
					faCounter++;
				}
				//We increase the counter with the result
				newCounter[j]++;
				//We increase the counter with the carry out
				newCounter[j+1]++;
				//We increase the next column counter, because now there is a carry
				coutCounter[j+1]++;
				
				
				printAdder(adderIndex-1);
			}
			else{
				if(i<counter[j]){
					strcpy(nextDaddaTree[newCounter[j]][j],daddaTree[i][j]);
					newCounter[j]++;
				}
			}  	
		}
	}
	//}
	copyMatrix();
}
/*
void print_layer(int length, int n)
{

	int max_length=length*2-1;
	for(int i = 0; i < n; i++)
	{
		for (int j = 0; j < max_length; j++)
		{
			if(j>=2*i && j < (max_length - 2*i)){
				daddaTree[i][j] = 1;
				fprintf(fptr,"*");
				//printf("*");
				counter[j]++;
			}
			else
			{
				daddaTree[i][j] = 0;
				fprintf(fptr," ");
	   			//printf(" ");
			}
		}
		fprintf(fptr,"\n");
	   		//printf("\n"); 		
	}
	for(int i=0;i<max_length;i++){
		fprintf(fptr,"#");
	}
	fprintf(fptr,"\n");
	for(int i=0;i<max_length;i++){
		fprintf(fptr,"%d,",counter[i]);
	}

	printf("Dadda tree[%d][%d]: \n", n, length);
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < max_length; j++)
		{
			printf("%d", daddaTree[i][j]);
		}
		printf("\n");
	}

}
*/
void printMatrix(char * fileName, int layer){
	FILE *fmatrix;
	//int max_length= NBITS+SHIFT_AMOUNT*(TOTAL_ROWS-1);
	fmatrix= fopen(fileName,"w+");
	for(int i=0;i<TOTAL_ROWS;i++){
		
		if(i==layerSize[layer]){
			for(int j=0;j<MAX_LENGTH;j++){
				fprintf(fmatrix,"----\t\t");
			}
			fprintf(fmatrix,"\n");
		}

		for(int j=MAX_LENGTH-1;j>=0;j--){
			fprintf(fmatrix,"%s",daddaTree[i][j]);
			//If they are equal
			if(strcmp(daddaTree[i][j],"NULL")){
				fprintf(fmatrix,"\t");
			}
			//If they are different
			else{
				fprintf(fmatrix,"\t\t\t");
			}
			if(NBITS<10){
				printf("(%d,%d)\t",i,j);
			}
		}
		if(NBITS<10){
			printf("\n");
		}
		fprintf(fmatrix,"\n");
	}
	for(int i=0;i<MAX_LENGTH;i++){
		fprintf(fmatrix,"%d\t\t",counter[i]);
	}
	fprintf(fmatrix,"\n");
	for(int i=0;i<MAX_LENGTH;i++){
		fprintf(fmatrix,"#");
	}
	fprintf(fmatrix,"\n");
	for(int i=0;i<MAX_LENGTH;i++){
		fprintf(fmatrix,"%d,",counter[i]);
	}
	fclose(fmatrix);
	printf("%s is ready!\n",fileName);
}

void printFA(){
	FILE *flistFA;
	flistFA= fopen("AddersList.txt","w+");
	for(int i=0;i<adderIndex;i++){
		if(fullAdderArray[i].isFA){
			fprintf(flistFA, "FULL ADDER:\t%d\n",fullAdderArray[i].ID);
		}
		else{
			fprintf(flistFA, "HALF ADDER:\t%d\n",fullAdderArray[i].ID);	
		}
		fprintf(flistFA,"Input1 name:\t%s\n",fullAdderArray[i].input1);
		fprintf(flistFA,"Input2 name:\t%s\n",fullAdderArray[i].input2);
		if(fullAdderArray[i].isFA){
			fprintf(flistFA, "Cin name: \t%s\n",fullAdderArray[i].cin);
		}
		fprintf(flistFA,"Cout name:\t%s\n",fullAdderArray[i].cout);
		fprintf(flistFA,"Result name:\t%s\n",fullAdderArray[i].result);
		fprintf(flistFA,HASTAGS_SEPARATOR);
	}
	fprintf(flistFA,"Total Number of FA:\t%d\n",faCounter);
	fprintf(flistFA,"Total Number of HA:\t%d\n",haCounter);
	fclose(flistFA);
	printf("AddersList.txt is ready!\n");
	printf("Total Number of FA:\t%d\n",faCounter);
	printf("Total Number of HA:\t%d\n",haCounter);
}

void generateVHDL();

int main(int argc, char *argv[])
{


	// use appropriate location if you are using MacOS or Linux
	char fileName[128];
	initMatrix(TOTAL_ROWS,NBITS);
	printMatrix("Layer6.txt",6);
	printf("Calcuting FA:\n");
	//We start the Calculation of the FA and HA
	printf("Generating Layer: 6");
	//allocateAdd(TOTAL_ROWS,NBITS,1);
	//allocateAdd(TOTAL_ROWS,NBITS,5);
	//printMatrix("Layer5.txt",5);
	for(int i=5;i>=0;i--){
		sprintf(fileName,"Layer%d.txt",i);
		printf("\nGenerating Layer: %d\n",i);
		allocateAdd(TOTAL_ROWS,NBITS,i);
		printMatrix(fileName,i);
	}
	printf("Allocated Adders!\n");
	printFA();
	generateVHDL();
	return 0;
}



void generateVHDL(){
	FILE * vhdlFile;
	vhdlFile = fopen(VHDL_FILE_NAME,"a");
	printf("Signal Number:%d\n",signalCounter);

	//We print the signals
	fprintf(vhdlFile,"\nsignal ");
	for(int i=0; i< signalCounter-1;i++){
		fprintf(vhdlFile,"%s, ",signalList[i]);
	}
	fprintf(vhdlFile,"%s: std_logic;\n",signalList[signalCounter-1]);
	//begin
	fprintf(vhdlFile,"begin\n");
	//print the port maps
	for(int i = 0;i < adderIndex;i++){
		//"FA%d:%s port map (In1 => %s, In2 => %s, Cin => %s, Out => %s, Cout => %s);"
		if(fullAdderArray[i].isFA){
			fprintf(vhdlFile,FULL_ADDER_PORT_MAP, fullAdderArray[i].ID, fullAdderArray[i].input1,fullAdderArray[i].input2,fullAdderArray[i].cin, fullAdderArray[i].result, fullAdderArray[i].cout);
		}
		//"HA%d:%s port map (In1 => %s, In2 => %s, Out => %s, Cout => %s);"
		else{
			fprintf(vhdlFile,HALF_ADDER_PORT_MAP, fullAdderArray[i].ID, fullAdderArray[i].input1,fullAdderArray[i].input2, fullAdderArray[i].result, fullAdderArray[i].cout);
		}
	}
	for(int i=0; i< MAX_LENGTH; i++){
		if(strcmp(daddaTree[0][i],"NULL")){
			fprintf(vhdlFile,FIRST_ROW_OUTPUT_ASSIGNMENT,i,daddaTree[0][i]);
		}
		else{
			fprintf(vhdlFile,FIRST_ROW_NULL_OUTPUT_ASSIGNMENT,i);	
		}
	}
	/*
	for(int i=0; i< 2; i++){
		fprintf(vhdlFile,SECOND_ROW_OUTPUT_ASSIGNMENT,i,"'0'");
	}
	//DOUBLE CHECK: the last shift amount of bits doesn't have a value
	for(int i=SHIFT_AMOUNT; i< MAX_LENGTH; i++){
		fprintf(vhdlFile,SECOND_ROW_OUTPUT_ASSIGNMENT,i,daddaTree[1][i]);
	}*/
	for(int i=0; i< MAX_LENGTH; i++){
		if(strcmp(daddaTree[1][i],"NULL")){
			fprintf(vhdlFile,SECOND_ROW_OUTPUT_ASSIGNMENT,i,daddaTree[1][i]);
		}
		else{
			fprintf(vhdlFile,SECOND_ROW_NULL_OUTPUT_ASSIGNMENT,i);	
		}
	}
	/*
	for(int i=NBITS + SHIFT_AMOUNT*(TOTAL_ROWS - 1)-1;i <NBITS + SHIFT_AMOUNT*(TOTAL_ROWS - 1);i++){
		fprintf(vhdlFile,SECOND_ROW_OUTPUT_ASSIGNMENT,i,"'0'");
	}*/

	
	fprintf(vhdlFile,"end architecture;");
	fclose(vhdlFile);

}


 
