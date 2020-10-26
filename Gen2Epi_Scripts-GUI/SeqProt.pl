#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $dir = $ARGV[0];
my $Res = $ARGV[1];

open(OUT,">$Res/rpsJ_prot.fasta");
opendir(HAS,$dir);
	while(my $has = readdir(HAS)){
		chomp($has);
		next if ($has =~m/^\./);
        	next if ($has =~m/_tblastnFMT/);
		next if ($has =~m/.fasta/);
		next if ($has =~m/.ID/);
		my $name = $has;
		$name =~ s/.tblastn//g; 
		open(FILE,"$dir/$has");
		while(my $line = <FILE>){
			chomp($line);
		if($line =~ m/Sbjct/){
		$line =~ s/Sbjct/$name/g;
		print OUT "$line\n";
		}
	}
}		
my $cmd = 'if ($. %2){ chomp }else{ s/^/ = / }';
system "perl -pe '$cmd' $Res/rpsJ_prot.fasta >$Res/rpsJ_protein.fasta\n";

open(FILE, "<$Res/rpsJ_protein.fasta");
open (OUT1, ">$Res/Prot_rpsJ.fas");
while(my $has1 = <FILE>){
	chomp($has1);
	$has1 =~ s/\s\d+$//g;
	$has1 =~ s/\d+\s= Dillon.*\s\d+\s//g;
	$has1 =~ s/^/>/g;
	$has1 =~ s/\s\d+//g;
	$has1 =~ s/=.*\d+//g;
	$has1 =~ s/\s+/\n/g;
	print OUT1 "$has1\n";
}
	system "seqret --sequence $Res/Prot_rpsJ.fas -outseq $Res/Prot_rpsJ.fasta\n";

system "rm -rf $Res/rpsJ_prot.fasta";
system "rm -rf $Res/rpsJ_protein.fasta";
system "rm -rf $Res/Prot_rpsJ.fas";
