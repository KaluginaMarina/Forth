clean: 
	rm *.o
	rm interpreter

all:
	nasm -f elf64 -g interpreter.asm
	nasm -f elf64 -g lib.asm
	ld -o interpreter *.o

