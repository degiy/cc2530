#!/bin/perl
#
#syntax prog <a.s> <hash1> <hash2> ...

use Storable;

%ht=();

$asm=shift @ARGV;
#print "working on asm file $asm\n";
while ($#ARGV>=0)
{
    $hash=shift @ARGV;
    #print "loading hashtable file $hash\n";
    $ref=retrieve($hash);
    %ht=(%ht,%{$ref});
}
#print join ' ',keys %ht;

open(f,$asm) or die;
read f,$st,1000000;
close f;

for $a (keys %ht)
{
    #print $a,"\n";
    $lab=$ht{$a};
    $st=~s/(?<=mov DPTR, #dptr_${a}) *$/  ; ${lab}/mg;
}
print $st;
