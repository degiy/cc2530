#!/bin/perl

use Storable;

while(<>)
{
    next unless / /;
    $line=$_;
    chomp $line;
    ($ad,$e)=$line=~/^(....) (.*)$/;
    $ht{$ad}=$e;
}

print join ' ',keys %ht;

store \%ht,"reg_pdf.hash";
