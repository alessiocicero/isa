@echo off
del /f /s /q run 1>nul
rmdir run
mkdir run
gcc daddaTreeGen.c -o run/GenerateTree.exe
copy daddaTree.vhd run
cd run
GenerateTree.exe
cd ..