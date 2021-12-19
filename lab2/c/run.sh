rm -r run
mkdir run
gcc daddaTreeGen.c -o run/GenerateTree -std=c99
cp daddaTreeBegin.vhd run/daddaTree.vhd
cd run/
./GenerateTree
cd ..
