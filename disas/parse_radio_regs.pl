#!/bin/perl
#

use Storable;

while(<>)
{
    next unless /^0x/;
    $line=$_;
    chomp $line;
    ($ad,$e1,$e2,$e3,$e4)=$line=~/^0x(....) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)$/;
    print "$ad,$e1,$e2,$e3,$e4\n";
    $bin=pack('H*', $ad);
    $a = unpack('n', $bin);
    print $a,"\n";
    $ht{uc(sprintf "%04x",$a)}=$e1;
    $ht{uc(sprintf "%04x",$a+1)}=$e2;
    $ht{uc(sprintf "%04x",$a+2)}=$e3;
    $ht{uc(sprintf "%04x",$a+3)}=$e4;
}

print join ' ',keys %ht;

store \%ht,"reg_radio.hash";
