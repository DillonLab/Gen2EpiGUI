#!/usr/bin/perl;

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;
use WWW::Mechanize;

##### Strain Type
#
my $st ='http://www.ng-mast.net/sql/st_comma.asp';

my $mech = WWW::Mechanize->new();
$mech->get($st);
$mech->save_content("NG_MAST.txt");

open(FILE,"NG_MAST.txt");
open (OUT,'>>',"/home/gen2epi/Downloads/ngmaster-master/ngmaster/db/ng_mast.txt");
print OUT "ST,POR,TBPB\n";
while(my $file = <FILE>){
chomp($file);
$file =~s/<br>/\n/g;
print OUT "$file\n";
}

system "rm -rf NG_MAST.txt\n";

##### POR

my $por = 'http://www.ng-mast.net/sql/fasta.asp?allele=POR';

my $mech1 = WWW::Mechanize->new(); 
$mech1->get($por);
$mech1->save_content("por.tfa");


##### TBPB

my $tbpb = 'http://www.ng-mast.net/sql/fasta.asp?allele=TBPB';
my $mech2 = WWW::Mechanize->new();
$mech2->get($tbpb);
$mech2->save_content("tbpb.tfa");


system "sh allele.sh\n";
system "rm -rf por.tfa\n";
system "rm -rf por1.tfa\n";
system "rm -rf tbpb.tfa\n";
system "rm -rf tbpb1.tfa\n";
