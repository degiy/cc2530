#!/bin/perl
#
# to build hash based on list of registers

use Storable;

%ht=();

while(<>)
{
    next unless /0x/;
    $line=$_;
    chomp $line;
    if ($line=~/0x.*0x/)
    {
        ($ad1,$ad2,$lab)=$line=~/^0x(....).*0x(....) (.*)$/;
        $lab=uc($lab);
        $bin1=pack('H*', $ad1);
        $a1 = unpack('n', $bin1);
        $bin2=pack('H*', $ad2);
        $a2 = unpack('n', $bin2);
        print "$ad1 ($a1) - $ad2 ($a2) : $lab\n";
        if ($a2-$a1==1)
        {
            $ht{$ad1}=$lab."_LSB";
            $ht{$ad2}=$lab."_MSB";
        }
        else
        {
            $i=0;
            while ($a1<=$a2)
            {
                $ad=uc(sprintf("%04x",$a1));
                $ht{$ad}=$lab."_$i";
                $i++;
                $a1++;
            }
        }
    }
    else
    {
        ($ad,$lab)=$line=~/^0x(....) (.*)$/;
        $lab=uc($lab);
        print "$ad : $lab\n";
        $ht{$ad}=$lab;
    }
}

print join ' ',keys %ht;

store \%ht,"reg_radio_filter.hash";
