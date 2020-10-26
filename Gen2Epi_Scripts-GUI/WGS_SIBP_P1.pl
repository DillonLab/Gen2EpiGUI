#!/usr/bin/perl

#################################################
# Written by Dr. Reema Singh #
# Final Release: 2019 #
#################################################

use strict;
use warnings;

my $In = $ARGV[0];
my $PATH = $ARGV[1];
my $type = $ARGV[2];
my $Res = $ARGV[3];
my $OUT = "QualityControl";
my $Trim = "Trimming";
my $Trim1 = "Trimmed_QC";
my $MQC = "MultiQC-Raw";
my $MQC1 = "MultiQC-Trimmed";

if ($type =~ /QualityCheck/i){
	system "rm -rf $Res/{$OUT,$MQC}\n";
	if (!-d "$Res/$OUT"||"$Res/$MQC"){
	system "mkdir $Res/{$OUT,$MQC}\n";}
open(INPUT,$In);
while ( my $rawData =<INPUT>){
chomp($rawData);
my ($ID,$pair1,$pair2) = split /\t/,$rawData;
system "fastqc $PATH/$pair1 $PATH/$pair2 -o $Res/$OUT -f fastq\n";
}
system "multiqc $Res/$OUT/*_fastqc.zip -o $Res/$MQC\n";
}

elsif ($type =~ /Trimming/i){
	system "rm -rf $Res/{$Trim,$Trim1,$MQC1}\n";
 	if (!-d "$Res/$Trim"||"$Res/$Trim1"||"$Res/$MQC1"){
	system "mkdir $Res/{$Trim,$Trim1,$MQC1}\n";}
open(INPUT,$In);
while ( my $rawData =<INPUT>){
chomp($rawData);
my ($ID,$pair1,$pair2) = split /\t/,$rawData;

my $OUTpair1 = join("_","OutputPaired",$pair1);
my $OUTUnpair1 = join("_","OutputUnpaired",$pair1);
my $OUTpair2 = join("_","OutputPaired",$pair2);
my $OUTUnpair2 = join("_","OutputUnpaired",$pair2);

my $lead = $ARGV[4];
my $trail = $ARGV[5];
my $SlidWin = $ARGV[6];
my $MinLen = $ARGV[7];

system "java -jar /usr/local/bin/trimmomatic.jar PE -phred33 $PATH/$pair1 $PATH/$pair2 $Res/$Trim/$OUTpair1 $Res/$Trim/$OUTUnpair1 $Res/$Trim/$OUTpair2 $Res/$Trim/$OUTUnpair2 LEADING:$lead TRAILING:$trail SLIDINGWINDOW:$SlidWin MINLEN:$MinLen\n";
system "fastqc $Res/$Trim/$OUTpair1 $Res/$Trim/$OUTpair2 -o $Res/$Trim1 -f fastq\n";
}
system "multiqc $Res/$Trim1/*_fastqc.zip -o $Res/$MQC1\n";
print "Finish Data Cleaning\n";
}

elsif ($type =~ /both/i){
	system "rm -rf $Res/{$OUT,$MQC,$Trim,$Trim1,$MQC1}\n";
	if (!-d "$Res/$OUT"||"$Res/$MQC"||"$Res/$Trim"||"$Res/$Trim1"||"$Res/$MQC1"){
	system "mkdir $Res/{$OUT,$MQC,$Trim,$Trim1,$MQC1}\n";}
open(INPUT,$In);
while ( my $rawData =<INPUT>){
chomp($rawData);
my ($ID,$pair1,$pair2) = split /\t/,$rawData;

my $OUTpair1 = join("_","OutputPaired",$pair1);
my $OUTUnpair1 = join("_","OutputUnpaired",$pair1);
my $OUTpair2 = join("_","OutputPaired",$pair2);
my $OUTUnpair2 = join("_","OutputUnpaired",$pair2);

my $lead = $ARGV[4];
my $trail = $ARGV[5];
my $SlidWin = $ARGV[6];
my $MinLen = $ARGV[7];

system "fastqc $PATH/$pair1 $PATH/$pair2 -o $Res/$OUT -f fastq\n";
system "java -jar /usr/local/bin/trimmomatic.jar PE -phred33 $PATH/$pair1 $PATH/$pair2 $Res/$Trim/$OUTpair1 $Res/$Trim/$OUTUnpair1 $Res/$Trim/$OUTpair2 $Res/$Trim/$OUTUnpair2 LEADING:$lead TRAILING:$trail SLIDINGWINDOW:$SlidWin MINLEN:$MinLen\n";
system "fastqc $Res/$Trim/$OUTpair1 $Res/$Trim/$OUTpair2 -o $Res/$Trim1 -f fastq\n";
}
system "multiqc $Res/$OUT/*_fastqc.zip -o $Res/$MQC\n";
system "multiqc $Res/$Trim1/*_fastqc.zip -o $Res/$MQC1\n";
print "Finish Data Cleaning\n";
}
