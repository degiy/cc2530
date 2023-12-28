
## to generate a MCU file proper for the CC2530 (CODE, BIT and DATA lines)
# ASEM51 does not provide one for the CC253X family

# convert to MCU file, the extract of page 31 (§2.2.3, table 2.1) : SFR entries in RAM
./sfr_to_mcu.pl sfr_cc2530.txt > cc_data.mcu

# convert interruptions vectors (@ in CODE) to MCU file (page 44, §2.5.1, table 2.5)
./int_to_mcu.pl int_vectors_cc2530.txt > cc_int.mcu

# cc_bits.mcu : enter by hand (from §2.5)
# for information only SFR registers with an address in 0X0H or 0X8H can be accessible using bit ops
# the rule is : 0XYH for the bit Y at address 0X0H and 0XZH for the bit Y at address 0X8H (with Z=8+Y)
# thanks at disasm51 python code for that, I would have guess it otherwise (doc on 8051 is so so)

# then concatenate the 3 files to form the final MCU file to provide to disasm51
cat cc_data.mcu cc_int.mcu cc_bits.mcu > cc.mcu

## now you have the material to use disasm51 to disassemble your 8051 binary code, but it won't be enough because you will need to comment the mov DPTR, #dptr_XXYY to know which XREG is accessed (radio, adc, timer, uart, ...)


