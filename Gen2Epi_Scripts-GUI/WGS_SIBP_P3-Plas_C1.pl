#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $In = $ARGV[0];
my $Path = $ARGV[1];
my $th = $ARGV[2];
my $db = $ARGV[3];
my $Res = $ARGV[4];

##### Scaffolding

	my $OUT1 = "Plasmid_Identification";
	if (!-d "$Res/$OUT1"){
	system "mkdir $Res/$OUT1\n";}

	open(HAS,$In);
	while(my $line = <HAS>){
	chomp($line);
	my($has,$pair1,$pair2) = split /\t/,$line;
	my $out = $has;
	$out = join (".",$has,"blastn");
	system "blastn -query $Path/$has/contigs.fasta -db $db -out $Res/$OUT1/$out -num_threads $th -num_descriptions 1 -num_alignments 1\n";
 	}
