# asmb
basic starting point for an x86 assembler wrote with nasm that should be able to compile itself after.


Example Input (example.asm)
The assembler will read this file and convert it to machine code.

MOV EAX, 10
ADD EAX, EBX
SUB EAX, 5
Building and Running the Assembler


2. Assemble and Link

nasm -f elf32 -o tinyasm.o tinyasm.asm
ld -m elf_i386 -o tinyasm tinyasm.o
3. Run the Assembler

./tinyasm
4. View the Generated Machine Code

xxd output.bin
Expected output:

00000000: b8 0a 00 00 00 01 c0 29 00 00 00
This represents:

MOV EAX, 10 → B8 0A 00 00 00
ADD EAX, EBX → 01 C0
SUB EAX, 5 → 29 00 00 00

Next Steps
Expand the instruction set to include more operations (MUL, DIV, JMP, etc.).
Add support for labels and branching.
Improve error handling and debugging messages.
Make it more user-friendly by improving file handling and argument parsing.