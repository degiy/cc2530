To be able to disassemble easily your 8051 processor binary for cc2530, you need few things :
- a good disassembler : I suggest disasm51, it is written in python and easy to modify
- a good MCU file for the specific instanciation of 8051 that is inside the cc2530 SOC (this one I provide)
- some pratical comments to know which XREG register you use (here also, at least a basic set)

# DISASM51
here it is : https://github.com/OlekMazur/disasm51
how to use it :
``` shell
disasm51.py --entry 0x0 --entry 0x03 ... --include cc.mcu <my_bin> > my_source.s
```
It is important to know the list of interruption vectors used to be able to follow code branches and make a differentiation between code and data constants in your code bloc. Doc on disasm51 is great to understand the logic used.

# to generate a MCU file proper for the CC2530 (CODE, BIT and DATA lines)
ASEM51 does not provide one for the CC253X family, that's too bad.

- convert SFR info to MCU file, based on page 31 (§2.2.3, table 2.1) : SFR entries in RAM

``` shell
./sfr_to_mcu.pl sfr_cc2530.txt > cc_data.mcu
```

- convert interruptions vectors (@ in CODE) to MCU file (page 44, §2.5.1, table 2.5)

``` shell
./int_to_mcu.pl int_vectors_cc2530.txt > cc_int.mcu
```

- bits used by special bit instruction of 8051 (e.g. to clear interruptions)

``` shell
# cc_bits.mcu : enter by hand (from §2.5)
```
For information only SFR registers with an address in 0X0H or 0X8H can be accessible using bit ops
The rule for bit address is : 0XYH for the bit Y at address 0X0H and 0XZH for the bit Y at address 0X8H (with Z=8+Y)
Thanks at disasm51 and its python code for that, I wouldn't have guess it otherwise (doc on 8051 is so so)

- then concatenate the 3 files to form the final MCU file to provide to disasm51
``` shell
cat cc_data.mcu cc_int.mcu cc_bits.mcu > cc.mcu
```
The cc.mcu file is in the directory, so you don't have to rebuild it.

# XREG registers
Now you have the material to use disasm51 to disassemble your 8051 binary code, but it won't be enough because you will need to comment the mov DPTR, #dptr_XXYY instruction lines to know which XREG is accessed (radio, adc, timer, uart, ...)

The CC2530 user manual is full of such references, so I opt for several ways to collect them :
- first : export pdf as txt and grep (0x6...) blocs, this is the 6xxx_from_pdf.txt file. Some precisions :
  - I had to remove few chapters to avoid doublons in addresses (because the user guide cover more than just CC2530. CC2531 is fine (ok for USB), but CC24xx are for BLE radio). Namely :
    - §24 about CC2540/CC2541 Bluetooth low energy Radio
    - §25 about CC2541 Proprietary Mode Radio
  - As I need massive query/replace operations on long files, I use scripts to place the mapping in a perl hashmap (%ht) that I serialize on a file. Then I can merge all the hashmaps to make the search/add comment phase. I have a specific script for each source... Here it's parse_pdf.pl
  - I used this line to filter the content of pdf converted info text file : 

``` shell
  grep '0x[0-9A-F][0-9A-F][0-9A-F][0-9A-F]' cc253x_user_guide_Swru191c_cut.txt | sort -u | grep '^[A-Z0-9_]* (0x' | awk '{print $2,$1}' | sed -e 's/^...//' -e 's/)//' -e 's/ *$//' | sort -u > 6xxx_from_pdf.txt
```
    I still have some doulons, but they seem okay
``` shell
> grep `awk '{print $1}' 6xxx_from_pdf.txt | uniq -d | sed -e 's/^/ -e ^/' | tr -d '\012'` 6xxx_from_pdf.txt
6211 USBCS0
6211 USBCSIL
6216 USBCNT0
6216 USBCNTL
```
    To generate the hashmap (reg_pdf.hash):
``` shell
./parse_pdf.pl ./6xxx_from_pdf.txt
```

- second : import other sources of XREG / XSFR availlable in the doc, specially for radio
  - the radio regs availlable on page 266 (§23.15, table 23.5). Here my txt file is ./radio_regs.txt and the perl file to deal with it is ./parse_radio_regs.pl (I had to patch the txt file with "void" in place of empty cells)
  - the radio filtering regs (page 225, §23.4.3, table 23.1). My text file is radio_filter_regs.txt (I made some toileting inside to keep 2 columns) and the script parse_radio_filt.pl (the script manages MSB LSB entries and multi-byte registers)
  - maybe more sometime later if I need to explore one specific chapter off the doc

``` shell
./parse_radio_regs.pl radio_regs.txt
./parse_radio_filt.pl radio_filter_regs.txt
```

Then the ./comment_dptr.pl script make the job (inserting comments in assembly language to locate xsfr registers). You need to provide the 3 hashmaps to the script. Ex: 
``` shell
./comment_dptr.pl a.s ./reg_radio.hash ./reg_pdf.hash ./reg_radio_filter.hash > a2.s
```

To find out which dptr ref is not resolved (and the ones in XRAM won't be off course), you can do a :

``` shell
grep dptr_ a2.s | sort -u
```

When writing your asm, if you want to find back yours xram dptr, you can add them to a perl hash and provide them to ./comment_dptr.place
