#!/bin/perl
#
# indent 8051 asm
#

while(<>)
{
    chomp;
    $line=$_;
    $line=~tr/\011/ /;
    $line=~s/ +/ /g;
    if ($line=~/^ ?$/)
    {
        print "\n";
        next;
    }
    if ($line=~/;;/)
    {
        $line=~s/^ *;;/    ;;/;
        print $line,"\n";
        next;
    }
    if ($line=~/^ ?[^ :]+ ?: ?;/)
    {
        ($deb,$end)=$line=~/^ ?([^ :]+) ?: ?;(.*)$/;
        $deb.=':';
        printf "%-42s; %s\n",$deb,$end;
        next;
    }
    if ($line=~/^ ?[^: ]+ ?: ?.+$/)
    {
        ($deb,$end)=$line=~/^ ?([^: ]+) ?: ?(.+)$/;
        print $deb,":\n";
        $line=$end;
    }
    if ($line=~/^ ?[^:]+: ?$/)
    {
        $line=~s/^ ?([^:]+):.*$/\1/;
        print $line,":\n";
        next;
    }
    $op=$parm=$com='';
    if ($line=~/;/)
    {
        ($deb,$com)=$line=~/^([^;]+); ?(.*)$/;
        $line=$deb;
    }
    ($op,$parm)=$line=~/^ ?([^ ]+) ?(.*)$/;
    $parm=~s/, ?/, /g;
    if ($com eq '')
    {
        printf "    %-8s%-30s\n", $op,$parm;
    }
    else
    {
        printf "    %-8s%-30s; %s\n", $op,$parm,$com;
    }
}
