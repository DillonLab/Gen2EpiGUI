#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use warnings;
use strict;

my $file =$ARGV[0];
my $file1 = $ARGV[1];
open (OUT,'>>', "$file1/NgMAST.txt");
open(FILE,$file);
print OUT "Samples\tNgMAST\tPOR\tTBPB\n";
while(my $line = <FILE>){
if ($line =~ /ID/){
my $line1 = <FILE>;
chomp($line1);
my ($name,$NgMAST,$POR,$TBPB) = split("\t",$line1);
my $samples = $name;
$samples =~ s/^.*\///g;
print OUT "$samples\t$NgMAST\t$POR\t$TBPB\n";
}}
