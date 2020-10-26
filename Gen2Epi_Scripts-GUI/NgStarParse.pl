#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use warnings;
use strict;

my $al = "NgStarGenAllele_Profile";
my $Res= $ARGV[0];
open(OUT, ">","$Res/NgStarRes.txt");
open(HAS,$al);
		while(my $has=<HAS>){
		chomp($has);
		$has =~ s/,//g;
		my @all = split(" ",$has);
		#my @samp = grep {/Sample/} @all;
		my @samp = $all[0];
		my @penA = grep {/penA_/} @all;
		@penA = grep {s/penA_//} @penA ;
		my @mtrR = grep {/mtrR_/} @all;
		@mtrR = grep {s/mtrR_//} @mtrR;
		my @porB = grep {/porB_/} @all;
		@porB = grep {s/porB_//} @porB;
		my @ponA = grep {/ponA_/} @all;
		@ponA = grep {s/ponA_//} @ponA;
		my @gyrA = grep {/gyrA_/} @all;
		@gyrA = grep {s/gyrA_//} @gyrA;
		my @parC = grep {/parC_/} @all;
		@parC = grep {s/parC_//} @parC;
		my @TwtT = grep {/23S_/} @all;
		@TwtT = grep {s/23S_//} @TwtT;
		print OUT "@samp\t@penA\t@mtrR\t@porB\t@ponA\t@gyrA\t@parC\t@TwtT\n";
#		print "@samp\t@penA\t@mtrR\t@porB\t@ponA\t@gyrA\t@parC\t@TwtT\n";
}

system "rm -rf NgStarGenAllele_Profile\n";


