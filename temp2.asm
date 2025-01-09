ASM_FILE = main
CC = gcc
ASM = nasm
ASM_FLAGS = -f elf32 -g  -F dwarf
LD_FLAGS = -m32

all: $(ASM_FILE)

$(ASM_FILE): $(ASM_FILE).o
	$(CC) $(LD_FLAGS) -o $@ $^

$(ASM_FILE).o: $(ASM_FILE).asm
	$(ASM) $(ASM_FLAGS) $< -o $@

clean:
	rm -f $(ASM_FILE) $(ASM_FILE).o