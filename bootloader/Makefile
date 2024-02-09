##
# CC2530 boot loader into RAM through uart
# and few monitor stuffs
# inspired from paul_mon.as and cc2531_bootloader
#

# Sources
SRCS         = $(wildcard *.s)
BASENAME     = bootloader
IHX_FILE     = $(BASENAME).ihx
HEX_FILE     = $(BASENAME).hex
BIN_FILE     = $(BASENAME).bin
MEM_FILE     = $(BASENAME).mem
MAP_FILE     = $(BASENAME).map


REL_FILES    = $(SRCS:%.s=%.rel)
SYM_FILES    = $(SRCS:%.s=%.sym)
RST_FILES    = $(SRCS:%.s=%.rst)
LST_FILES    = $(SRCS:%.s=%.lst)

GENERATED    =  $(HEX_FILE) $(IHX_FILE) $(BIN_FILE) $(MEM_FILE) $(REL_FILES) $(SYM_FILES) $(RST_FILES) $(LST_FILES) $(MAP_FILE)

AS       = sdas8051
ASFLAGS  = -cpwb

LD       = sdld
LDFLAGS  = -numwx

.PHONY: all clean

all: $(BIN_FILE) $(HEX_FILE)

%.bin: %.ihx
	objcopy --input-target=ihex --output-target=binary $< $@

%.hex: %.ihx
	packihx $< > $@

$(IHX_FILE) $(RST_FILES) $(MEM_FILE): $(REL_FILES) $(LST_FILES) $(SYM_FILES)
	$(LD) $(LDFLAGS) -i $(IHX_FILE) $(REL_FILES)

%.rel: %.s %.lst Makefile
	$(AS) $(ASFLAGS) -o $@ $<

%.lst: %.s
	$(AS) $(ASFLAGS) -l $@ $<

%.sym: %.s
	$(AS) $(ASFLAGS) -s $@ $<

main.rel: $(wildcard *.inc)

clean:
	rm -f $(GENERATED)



# end
