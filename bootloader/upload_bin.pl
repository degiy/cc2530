#!/bin/perl
#
# contacts the bootloader to upload userprog and run it

die "Usage : $0 <bin_file> </dev/ttyUSB0>\n" unless $#ARGV==1;
($f,$device)=@ARGV;

($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                    $atime,$mtime,$ctime,$blksize,$blocks)
    = stat($f);
print "uploading binary $f (size $size) to $device\n";

print "set speed on $device\n";
`stty -F $device 115200`;

open(ff,">$device") or die "cannot open $device to write to\n";
open(f,$f) or die "cannot open $f to read from\n";

print "send header\n";
$header='U'.pack('v',$size);
syswrite ff,$header;
print "read bin file\n";
sysread f,$bin,$size;
print "upload starts\n";
syswrite ff,$bin,$size;
print "done\n";
close f;
close ff;
