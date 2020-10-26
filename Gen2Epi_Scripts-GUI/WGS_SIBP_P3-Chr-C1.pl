#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $In = $ARGV[0];
my $genomePath = $ARGV[1];
my $Path = $ARGV[2];
my $ann = $ARGV[3];
my $th = $ARGV[4];
my $anntype = $ARGV[5];
my $Res = $ARGV[6];

##### Scaffolding


	my $OUT = "Chr_Scaffolds";
	if (!-d "$Res/$OUT"){
        system "mkdir $Res/$OUT\n";}

	open(HAS,$In);
	while(my $has = <HAS>){
	chomp($has);
	my ($ID,$pair1,$pair2) = split /\t/,$has;
	if (!-d "$Res/$OUT/$ID"){
                system "mkdir $Res/$OUT/$ID\n";}
	my $genFas = $ID;
	$genFas =~ s/$/.fasta/g;
	open(OUT, ">", "$Res/$OUT/$ID.rcp");
	print OUT ".references = $ID\n.target = contigs\n\n$genFas=$genomePath/$genFas\ncontigs.fasta=$Path/$ID/contigs.fasta ";
	system "ragout.py $Res/$OUT/$ID.rcp --refine -t $th -o $Res/$OUT/$ID\n";
	

##### Annotation and Quality assessment

	opendir(DIR,"$Res/$OUT/$ID");
	my $name = join("_",$ID,"scaffolds.fasta");
	while(my $line = readdir(DIR)){
	chomp($line);
	next if ($line =~m/^\./);
	if ($line=~ m/_scaffolds.fasta$/){
	system "cp $Res/$OUT/$ID/$line $Res/$OUT/$ID/$name\n";
	my $OUT1 = $name;
	$OUT1 =~ s/.fasta//g;
	my $prot = join("_",$OUT1,"prot.fasta");
	my $nucl = join("_",$OUT1,"nucl.fasta");
	my $annot = join("_",$OUT1,"annot-genes");
	system "prodigal -a $Res/$OUT/$ID/$prot -d $Res/$OUT/$ID/$nucl -f gff -i $Res/$OUT/$ID/$name -o $Res/$OUT/$ID/$OUT.gff -p meta -s $Res/$OUT/$ID/$annot\n";
	if ($anntype =~ /TXT/i){
	my $Anno = $ID;
	$Anno =~ s/$/.txt/g;
	system "metaquast.py $Res/$OUT/$ID/$name -R $genomePath/$genFas -G $ann/$Anno -o $Res/$OUT/$ID\n";
	}
	elsif($anntype =~ /GFF/i){
	my $Anno = $ID;
        $Anno =~ s/$/.gff/g;
	system "metaquast.py $Res/$OUT/$ID/$name -R $genomePath/$genFas -G $ann/$Anno -o $Res/$OUT/$ID\n";
	}
		}
	}
}
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/ScaffoldsStats.pl $In $Res/$OUT $Res\n"; 
