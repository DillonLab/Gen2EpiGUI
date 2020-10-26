#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;
use WWW::Mechanize;

my $penA = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=penA";
my $mtrR = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=mtrR";
my $porB = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=porB";
my $ponA = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=ponA";
my $gyrA = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=gyrA";
my $parC = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=parC";
my $twenty = "https://ngstar.canada.ca/alleles/download?lang=en&loci_name=23S";

my $mech = WWW::Mechanize->new();
my $mech1= WWW::Mechanize->new();
my $mech2= WWW::Mechanize->new();
my $mech3= WWW::Mechanize->new();
my $mech4= WWW::Mechanize->new();
my $mech5= WWW::Mechanize->new();
my $mech6= WWW::Mechanize->new();

$mech->get($penA);
$mech1->get($mtrR);
$mech2->get($porB);
$mech3->get($ponA);
$mech4->get($gyrA);
$mech5->get($parC);
$mech6->get($twenty);

$mech->save_content("penA.fas");
$mech1->save_content("mtrR.fas");
$mech2->save_content("porB.fas");
$mech3->save_content("ponA.fas");
$mech4->save_content("gyrA.fas");
$mech5->save_content("parC.fas");
$mech6->save_content("23S.fas");

my $cmd = 'FNR==1{print ""}1';
system "awk '$cmd' *.fas >NgSTAR_alleles.fas\n";
system "seqret -sequence NgSTAR_alleles.fas -osformat fasta -outseq AMR-Genes-NgStar-alleles.fasta\n";

system "rm -rf *.fas\n";
