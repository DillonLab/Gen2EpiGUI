#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $In = $ARGV[0];
my $PATH= $ARGV[1];
my $type = $ARGV[2];
my $epi1 = "MLST";
my $epi2 = "NgSTAR";
my $Res = $ARGV[3];

my $Seq = "All_Sequences";
if (!-d "$PATH/$Seq"){
                system "mkdir $PATH/$Seq\n";}
open(INPUT,$In);
	while (my $line = <INPUT>){
	chomp($line);
	my($ID,$pair1,$pair2) = split /\t/,$line;
		opendir(DIR,"$PATH/$ID");
        		while(my $has = readdir(DIR)){
        		chomp($has);
        		next if ($has =~m/^\./);
			next if ($has =~m/contigs_scaffolds.fasta/);
        		if ($has =~ m/_scaffolds.fasta$/ || $has =~ m/_nucl.fasta/){	
			system "cp $PATH/$ID/$has $PATH/$Seq\n";
			
}}
}

if ($type =~ /ngmast/i){
        my $MAST = "NgMAST_Raw.txt";
        opendir(DIR,"$PATH/All_Sequences");
        while(my $line = readdir(DIR)){
        chomp($line);
        next if ($line =~m/^\./);
        if ($line =~ m/_scaffolds.fasta$/){
        system "singularity exec /home/gen2epi/phgenomics-singularity-ngmaster-master-latest.simg ngmaster $PATH/All_Sequences/$line >>$Res/$MAST\n";
        }}
        system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/Parse_NgMAST.pl $Res/$MAST $Res\n";
        system "rm -rf $Res/NgMAST_Raw.txt\n";
}

elsif($type =~ /MLST/i){
        if (!-d "$Res/$epi1"){
                system "mkdir $Res/$epi1\n";}
my $genes = $ARGV[4];
my $alleles = $ARGV[5];
my $profile = $ARGV[6];
opendir(DIR1,"$PATH/All_Sequences");
while(my $line1 = readdir(DIR1)){
chomp($line1);
next if ($line1 =~m/^\./);
if ($line1 =~ m/_nucl.fasta$/){
my $OUT = $line1;
$OUT =~ s/.fasta/_MLST.blastn/g;
my $OUT1 = $OUT;
my $OUT2 = $OUT;
my $OUT3 = $OUT;
$OUT1 =~ s/_MLST.blastn/_MLSTSeqID/g;
$OUT2 =~ s/_MLST.blastn/_MLSTSeqID.fasta/g;
$OUT3 =~ s/_MLST.blastn/_MLSTSeqID_alleles/g;
my $OUT4 = $OUT3;
$OUT4 =~ s/_nucl_MLSTSeqID_alleles/.txt/g;
my $OUT5 = $OUT4;
$OUT5 =~ s/.txt/_sorted.txt/g;
my $OUT6 = $OUT5;
$OUT6 =~ s/_sorted.txt/_pubMLST.txt/g;
system "makeblastdb -in $PATH/All_Sequences/$line1 -dbtype nucl\n";
system "blastn -query $genes -db $PATH/All_Sequences/$line1 -out $Res/$epi1/$OUT -outfmt 6 -max_target_seqs 1\n";
system "cut -f2 $Res/$epi1/$OUT >$Res/$epi1/$OUT1\n";
my $one = 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV';
system "perl -ne '$one' $Res/$epi1/$OUT1 $PATH/All_Sequences/$line1 >$Res/$epi1/$OUT2";
print "\n";
system "makeblastdb -in $alleles -dbtype nucl\n";
system "blastn -query $Res/$epi1/$OUT2 -db $alleles -out $Res/$epi1/$OUT3 -outfmt 6 -max_target_seqs 1\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/alleles.pl $Res/MLST $Res\n";
my $aw = '{for (i=1;i<=NF;i++)a[i,NR]=$i} END{for (i=1;i<=NF;i++) for (j=1;j<=NR;j++) printf "%s%s",a[i,j],(j==NR?ORS:OFS)}';
system "sort -k 1 $Res/$epi1/$OUT4 |awk '$aw' >$Res/$epi1/$OUT5\n";
my $aw1 = 'FNR==NR{a[$1,$2,$3,$4,$5,$6,$7]; next} ($2,$3,$4,$5,$6,$7,$8)in a{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}';
system "awk '$aw1' $Res/$epi1/$OUT5 $profile >$Res/$epi1/$OUT6\n";
}}
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/Parse_NgMLST.pl $Res/MLST $Res\n";
system "rm -rf $Res/MLST\n";
#system "rm -rf *.nsq\n";
#system "rm -rf *.nin\n";
#system "rm -rf *.nhr\n";
}
elsif($type =~ /ngstar/i){
        if (!-d "$Res/$epi2"){
                system "mkdir $Res/$epi2\n";}

my $ngGenes = $ARGV[4];
my $ngalleles = $ARGV[5];
system "makeblastdb -in $ngalleles -dbtype nucl\n";
opendir(DIR2,"$PATH/All_Sequences");
while(my $line2 = readdir(DIR2)){
chomp($line2);
next if ($line2 =~m/^\./);
if ($line2 =~ m/_scaffolds.fasta$/){
my $OUT7 = $line2;
$OUT7 =~ s/.fasta/_NgSTAR.blastn/g;
system "makeblastdb -in $PATH/All_Sequences/$line2 -dbtype nucl\n";
system "blastn -query $ngGenes -db $PATH/All_Sequences/$line2 -out $Res/$epi2/$OUT7 -outfmt 6 -max_target_seqs 1\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/merger.pl $Res/$epi2\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/merge_profile.pl $Res/$epi2\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/Extract.pl $Res/$epi2 $PATH/All_Sequences\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/Extract_pro.pl $Res/$epi2 $PATH/All_Sequences\n";
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/NgProfile.pl $Res/$epi2 $ngalleles\n";
}}
system "perl /home/gen2epi/Desktop/Gen2Epi_Scripts/NgStarParse.pl $Res\n";
system "Rscript /home/gen2epi/Desktop/Gen2Epi_Scripts/Match.R $Res/NgStarRes.txt $Res/NgStarSearchResults-WithST.txt\n";
system "Rscript /home/gen2epi/Desktop/Gen2Epi_Scripts/Match1.R $Res/NgStarRes.txt $Res/NgStarSearchResults-WithoutST.txt\n";

system "rm -rf *.nin";
system "rm -rf *.nhr";
system "rm -rf *.nsq";
system "rm -rf $Res/NgStarGenAllele_Profile";
system "rm -rf $Res/NgStarRes.txt";
system "rm -rf $Res/NgSTAR";
}
