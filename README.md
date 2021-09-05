# Matrix-Multiplication-Cache-Friendly-
Multiply two square n × n matrices of single precision floating point numbers, and then optimize the code to exploit a memory cache.

# Description
The code lets you run 3 different tests by changing TestNumber in the .data section at the top of the code.

• Test 0 will help you test the first objectives (matrix subtraction and Frobeneous norm).

• Test 1 will help you checking your matrix multiply-and-add procedure. It allocates mem- ory on the heap for 4 matrices (one being the solution) and loads test matrix data from file names specified in the data segment.

• Test 2 will hep you compare different matrix multiply-and-add procedures.

# Getting Started

## Installing
Software: MARS, download here: https://www.cs.mcgill.ca/~kry/comp273W21/pMARS.jar

## Executing program
1. Open a terminal
2. Go to folder where MARS is located (cd PATH_TO_DIRECTORY)
4. Open MARS by java -jar pMRAS.jar
5. Download cipher.asm and .txt files and place in the same folder as MARS
6. Open matrix_mul.asm inside MARS, hit run

## testing
You can use the attached .bin files to test the program
