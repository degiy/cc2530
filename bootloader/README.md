# Simple serial bootloader for CC2530

Assemble with SDCC (GAS of SDCC) through Makefile. Is basicaly a monitor program for your CC2530. You can upload the hex file with TI SmartRFProg.exe. Once loaded into the flash memory it will run a server on UART0 (115200N8). Several commands are availlable :
- B : to reboot (soft reboot)
- R : reset to user program (if any)
- D : dump xdata (including data located at 0x1f00). Each call increment address to dump (starting at 0)
- 0 : reset dump address to 0
- d : dump data (0 to 0xff, including SFR registers)
- U : upload user program into xdata (RAM) and run it
  - size (2bytes starting with LSB) of binary code to upload to CC2530
  - code (size bytes)

The monitor uses interrupt on UART0 (cannot take it back in user prog, need to use UART1) and forward all others ones to user program.
It also use bank of registers 1 of 8051 (you still have 0,2 and 3 for your prog). If you use bank 1, the uart0 rx interrupt could fail (asking for upload...). You could need to restart (hardware reset, through cc-debug for instance or by unplugging / replugging power)
Location of user program in 0x9000 in code space (0x1000 in xdata ram). You can change it in config.inc file. By default it will keep 4k for RAM and 4k for your program code (including the interrupt vector you plan to use who will be at 0x9000 and not 0x0000).
Probably you will need more code space and less RAM, but it depends on your workload.

As the program runs into RAM, you won't wear the flash memory by uploading thousands of try/fail/try again steps. Once you are sure, you can flash it. You can also add to bootloader common stuff (libs, tools) you can call from user prog.
Also the 115200 bauds upload speed allow to send 8KB in half a second. Customise your Makefile to assemble and send your program to SOC ('U'+size ad a short+ program data). No parity check is done (like with .hex uploads).

The bootloader copy a default program to ram. So if you reboot, you will need to upload again to overwrite the dummy prog.

TODO : blocks all interrupts while begining uploading except UART0 RX.
TODO : jump to specific location.
