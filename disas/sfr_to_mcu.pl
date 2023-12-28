#!/bin/perl

# converter from pdf copy/paste (text) to MCU file for 8051
#  format from pdf is register <space> SFR address <space> cat <space> desc.
#

while(<>)
{
    $line=$_;
    chomp $line;
    ($reg,$ad,$cat,$com)=$line=~/^([^ ]+) 0x(..) ([^ ]+) (.*)$/;
    $cat="TIM" if $cat eq "Timer";
    $cat="MEM" if $cat eq "MEMORY";
    print "${cat}_${reg}\tDATA\t0${ad}H\t; $com\n"
}
