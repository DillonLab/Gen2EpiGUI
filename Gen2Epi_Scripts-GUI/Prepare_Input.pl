#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $dir = $ARGV[0];
my $str = $ARGV[1];
my $Res = $ARGV[2];

open(OUT,">$Res/Test_Inp");
opendir(DIR,$dir);

while(my $files = readdir(DIR)){
chomp($files);
next if ($files =~m/^\./);
my $name = substr($files,0,$str);
print OUT "$name\t$files\n";
system "sort $Res/Test_Inp >$Res/Test_Inp1";
my $cmd1 = 's != $1 || NR ==1{s=$1;if(p){print p};p=$0;next} {sub($1,"",$0);p=p""$0;}END{print p}';
my $sp = '-F " "';
system "awk $sp '$cmd1' $Res/Test_Inp1 >$Res/Prepare_Input.txt\n";
}
system "rm -rf $Res/Test_Inp\n";
system "rm -rf $Res/Test_Inp1\n";

