ASM_FILE = main
CC = gcc
ASM = nasm
ASM_FLAGS = -f elf32 -g  -F dwarf
LD_FLAGS = -m32

all: multi

multi: multi.o
	gcc -m32 multi.o -o multi

multi.o: multi.s
	nasm -f elf32 multi.s -o multi.o
	
clean:
	rm -f multi multi.o