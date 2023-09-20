all: ./ttest.asm
	nasm -f elf64 ./ttest.asm -i ./common
	gcc -no-pie ttest.o -e _start	
	./a.out
	rm -rf ./ttest.o ./a.out 


