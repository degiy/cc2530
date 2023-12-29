# CC2530 related doc :
- datasheet (for pinout, signal levels, ram / flash size, features,...) : https://www.ti.com/lit/ds/symlink/cc2530.pdf
- user guide (for registers, specific 8051 features, dma, timers, radio, uart,...) : https://www.waveshare.com/w/upload/b/b5/Swru191c.pdf
- software exemple (if you have IAR licence) : https://www.ti.com/lit/ug/swru214a/swru214a.pdf
- paquet sniffer (if you want to dump frame on air to see what you send indeed) : https://www.waveshare.com/w/upload/7/79/Swru187f.pdf

# Intel 8051 processor/SOC features :
- instruction set : 
	- https://www.win.tue.nl/~aeb/comp/8051/set8051.html
	- https://ww1.microchip.com/downloads/en/DeviceDoc/doc4316.pdf
- architecture / design of the SOC :
	- https://www.silabs.com/documents/public/presentations/8051_Instruction_Set.pdf
	- https://www.brainkart.com/article/Basic-8051-Architecture_7908/ (for bit adressable SFR register, duality RAM/SFR,...)

# Assembler for 8051
- http://plit.de/asem-51/ (freeware, but not opensource)
- IAR assembler (work without licence) : https://www.iar.com/products/architectures/iar-embedded-workbench-for-8051/
- SDCC asm (sdas) : https://sdcc.sourceforge.net/ (this one is opensource)
You will certainly find older assemblers / simulator from the dos era who won't work anymore on nowadays OS

# Disassembler for 8051 (to check what you compile, or reverse) :
- https://github.com/OlekMazur/disasm51
- https://github.com/msrst/interactive-8051-disassembler

# tooling to load your program in the CC2530
- flash programmer (ti) : https://www.ti.com/tool/FLASH-PROGRAMMER (you need a CC-Debugger device, for a few dollars)
- or https://www.zigbee2mqtt.io/guide/adapters/flashing/alternative_flashing_methods.html
- especialy https://github.com/jmichault/flash_cc2531 if you're using a raspberry pi as your main linux

# other tools
- hex2bin (to convert your .hex file to .bin) : https://github.com/algodesigner/hex2bin (you will need to patch some vars / funcs declarations who are not done as extern, for the code to compile)

# some code exemple
- a C program to load your program using UART (written in C, and who compiles with SDCC) : https://github.com/ekawahyu/ccboot-CC2530 (great job, had to eat the doc too... i know the feeling). Maybe the best place to start in you plan to use C and a free toolchain on cc2530


