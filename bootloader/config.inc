; config

stack=0x80 ; stack will start from 0x80 and growth up to 0xff
xdata_in_code = 0x8000 ; Start of RAM in code space
ram_resa_for_data = 0x1000 ; reservation of RAM for pure data storage (vs. code)
begin_up_xdata=ram_resa_for_data    ; begin of user programm in xdata space
data_xdata=0x1f00   ; 256 bytes of fast RAM (DATA) inside XDATA space
user_prog = (xdata_in_code+begin_up_xdata) ; where user prog is expected to be copy (4KB for RAM, 4KB for code in RAM). Include int vectors.
