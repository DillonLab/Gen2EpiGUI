#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;
use WWW::Mechanize;

my $penA = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=penA";
my $mtrR = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=mtrR";
my $porB = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=porB";
my $ponA = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=ponA";
my $gyrA = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=gyrA";
my $parC = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=parC";
my $twenty = "https://ngstar.canada.ca/alleles/download_metadata?lang=en&loci_name=23S";
my $profile = "https://ngstar.canada.ca/sequence_types/download?lang=en";
my $profmeta = "https://ngstar.canada.ca/sequence_types/download_metadata?lang=en";

my $mech = WWW::Mechanize->new();
my $mech1= WWW::Mechanize->new();
my $mech2= WWW::Mechanize->new();
my $mech3= WWW::Mechanize->new();
my $mech4= WWW::Mechanize->new();
my $mech5= WWW::Mechanize->new();
my $mech6= WWW::Mechanize->new();
my $mech7= WWW::Mechanize->new();
my $mech8 = WWW::Mechanize->new();

$mech->get($penA);
$mech1->get($mtrR);
$mech2->get($porB);
$mech3->get($ponA);
$mech4->get($gyrA);
$mech5->get($parC);
$mech6->get($twenty);
$mech7->get($profile);
$mech8->get($profmeta);

$mech->save_content("penA_metadata.xlsx");
system "xlsx2csv penA_metadata.xlsx -d '\t' >penA_metadata.txt\n";

$mech1->save_content("mtrR_metadata.xlsx");
system "xlsx2csv mtrR_metadata.xlsx -d '\t' >mtrR_metadata.txt\n";

$mech2->save_content("porB_metadata.xlsx");
system "xlsx2csv porB_metadata.xlsx -d '\t' >porB_metadata.txt\n";

$mech3->save_content("ponA_metadata.xlsx");
system "xlsx2csv ponA_metadata.xlsx -d '\t' >ponA_metadata.txt\n";

$mech4->save_content("gyrA_metadata.xlsx");
system "xlsx2csv gyrA_metadata.xlsx -d '\t' >gyrA_metadata.txt\n";

$mech5->save_content("parC_metadata.xlsx");
system "xlsx2csv parC_metadata.xlsx -d '\t' >parC_metadata.txt\n";

$mech6->save_content("23S_metadata.xlsx");
system "xlsx2csv 23S_metadata.xlsx -d '\t' >23S_metadata.txt\n";

$mech7->save_content("ngSTAR_profile.xlsx");
system "xlsx2csv ngSTAR_profile.xlsx -d '\t' >ngSTAR_profile.txt\n";

$mech8->save_content("ngSTAR_profile_metadata.xlsx");
system "in2csv ngSTAR_profile_metadata.xlsx >ngSTAR_profile_metadata.csv\n";
system "python /home/gen2epi/Desktop/Gen2Epi_Scripts/csvtotext.py ngSTAR_profile_metadata.csv ngSTAR_profile_metadata.txt\n";

system "rm -rf *.xlsx\n";
system "rm -rf *.csv\n";
