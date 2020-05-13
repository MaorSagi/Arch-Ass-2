all: root


root:ass2.o
	gcc -g -Wall -o root ass2.o
 
ass2.o: ass2.s
	nasm -g -f elf64 -w+all -o ass2.o ass2.s
.PHONY: clean

clean:
	rm -f *.o root



