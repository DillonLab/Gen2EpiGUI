#!/usr/bin/perl;

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;
use WWW::Mechanize;

my $abcZ ='http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/abcZ/alleles_fasta';
my $adk = 'http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/adk/alleles_fasta';
my $aroE ='http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/aroE/alleles_fasta';
my $fumC ='http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/fumC/alleles_fasta';  
my $gdh = 'http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/gdh/alleles_fasta';
my $pdhC ='http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/pdhC/alleles_fasta';
my $pgm = 'http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/loci/pgm/alleles_fasta';

my $pubMLSTProfile = 'http://rest.pubmlst.org/db/pubmlst_neisseria_seqdef/schemes/1/profiles_csv';

my $mech = WWW::Mechanize->new();
my $mech1 = WWW::Mechanize->new();
my $mech2 = WWW::Mechanize->new();
my $mech3 = WWW::Mechanize->new();
my $mech4 = WWW::Mechanize->new();
my $mech5 = WWW::Mechanize->new();
my $mech6 = WWW::Mechanize->new();
my $mech7 = WWW::Mechanize->new();

$mech->get($abcZ);
$mech1->get($adk);
$mech2->get($aroE);
$mech3->get($fumC);
$mech4->get($gdh);
$mech5->get($pdhC);
$mech6->get($pgm);
$mech7->get($pubMLSTProfile);

$mech->save_content("abcZ.fas");
$mech1->save_content("adk.fas");
$mech2->save_content("aroE.fas");
$mech3->save_content("fumC.fas");
$mech4->save_content("gdh.fas");
$mech5->save_content("pdhC.fas");
$mech6->save_content("pgm.fas");
$mech7->save_content("pubMLST_profile.txt");

#system "cat abcZ.fas adk.fas aroE.fas fumC.fas gdh.fas pdhC.fas pgm.fas >MLST_alleles.fas\n";
my $cmd = 'FNR==1{print ""}1';
system "awk '$cmd' *.fas >MLST_alleles.fas\n";
system "seqret -sequence MLST_alleles.fas -outseq MLST_alleles.fasta\n";

system "rm -rf *.fas\n";
