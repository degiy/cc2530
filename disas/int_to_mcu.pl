#!/bin/perl

# converter from pdf copy/paste (text) to MCU file for 8051
# Interrupt Number; Description ; Interrupt Name; Vector; Interrupt Mask; Interrup Flag

while(<>)
{
    $line=$_;
    chomp $line;
    # remove notes (1) or (2)
    $line=~s/\([12]\)//g;
    ($nb,$desc,$name,$vec,$mask,$flag)=$line=~/^([^ ]+) (.*) ([^ ]+) 0x(..) ([^ ]+) ([^ ]+)/;
    print "VEC_${name}\tCODE\t0${vec}H\t; int $nb : $desc (mask=$mask, flag=$flag)\n"
}
