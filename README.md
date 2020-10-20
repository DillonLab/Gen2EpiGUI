# Gen2EpiGUI: User-Friendly Pipeline for Analyzing Whole-Genome Sequencing Data for Epidemiological Studies of Neisseria gonorrhoeae

# Requirements

1)	Perl V5.16.3 or higher
2)	Install Perl module ‘Tk’ and required dependencies
3)	Install the following programs and make them executable 

        a.	FastQC
        b.	MultiQC
        c.	Trimmomatic
        d.	Kraken
        e.	Bowtie2
        f.	SPAdes
        g.	BBMap
        h.	Ragout
        i.	Prodigal
        j.	QUAST
        k.	BLAST
        l.	EMBOSS
        m.	NGMASTER
        
4)	If the installed programs are not executable, then all required softwares should be in path 

        a.	export PATH=$PATH:/installation-path/FastQC
        b.	export PATH=$PATH:/installation-path/Trimmomatic-0.36
        c.	export PATH=$PATH:/installation-path/SPAdes-3.11.1-Linux/bin
        d.	export PATH=$PATH:/installation-path/SPAdes-3.11.1-Linux/share
        e.	export PATH=$PATH:/installation-path/bbmap/
        f.	export PATH=$PATH:/installation-path/ngmaster/
        g.	export PATH=$PATH:/installation-path/x86_64
        h.	export PATH=$PATH:/installation-path/ncbi-blast-2.6.0+/bin/
        i.	export PATH=$PATH:/installation-path/EMBOSS-6.6.0/bin
        j.	export PATH=$PATH:/installation-path/Sibelia-master
        k.	export PATH=$PATH:/installation-path/Sibelia-master/bin
        l.	export PATH=$PATH:/installation-path/Sibelia-master/bin/bin
        m.	export PATH=$PATH:/installation-path/Sibelia-master/bin/lib
        n.	export PATH=$PATH:/installation-path/Sibelia-master/bin/share
        o.	export PATH=$PATH:/installation-path/fenderglass-Ragout-71562fc
        p.	export PATH=$PATH:/installation-path/quast-4.5
        q.	export PATH=$PATH:/installation-path/Prodigal-2.6.3
        r.	export PATH=$PATH:/installation-path/bowtie2-2.3.2
        
        Alternately, users can also copy the above-mentioned commands [a-r] in “.bashrc” and then set the path in the current working directory by running the following command 
      
        “source .bashrc”  
        
5)	Copy the test dataset in the current working directory under

        “/home/user/Desktop/Test_DATA”
        
6)	Copy the Gen2Epi_Scripts-GUI folder in your current working directory.
 
7)	Open terminal (Applications->Favorites->Terminal) and cd into 
 
        “/home/user/Desktop/Gen2Epi_Scripts“

8) 	copy “Gen2EpiGUI.pl” script on the Desktop. To use the user-friendly version of the pipeline follow the instructions given in “UserManual.pdf” & “IntroductoryDemo.pdf”.             
# How to use Gen2EpiGUI via Commandline

  1)	Prepare a tab-limited input file describing the full name and the paired-end read files, e.g., 
  
    WHO-F WHO-F_S2_L001_R1_001.fastq.gz WHO-F_S2_L001_R2_001.fastq.gz
    WHO-G WHO-G_S3_L001_R1_001.fastq.gz WHO-G_S3_L001_R2_001.fastq.gz
    WHO-K WHO-K_S4_L001_R1_001.fastq.gz WHO-K_S4_L001_R2_001.fastq.gz
    WHO-L WHO-L_S5_L001_R1_001.fastq.gz WHO-L_S5_L001_R2_001.fastq.gz
    
   First column = Sample ID

   Second Column = First fastq read pair

   Third Column = Second fastq read pair

   Note: Make sure to put all the fastq reads in the same folder. 

   If you have thousands of samples then the input file in the above-mentioned format can be prepared by using the following script:

	“perl Prepare_Input.pl <path-to-fastq-files> <number e.g 5> <Output directory>”
  
  For more information, please see “Gen2Epi-GUI-REFERENCE_GUIDE.pdf” 

  2)	Create an output directory and perform quality check and trimming using following commands
  
         “mkdir Output”		
	“perl WGS_SIBP_P1.pl /home/user/Desktop/Test_DATA/Input /home/user/Desktop/Test_DATA/WHO_Data both Output 3 3 4:15 30”
		
  3)	For de-novo assembly

	“perl WGS_SIBP_P2.pl /home/user/Desktop/Test_DATA/Input Output/Trimming trimmed 2 Output”
	
  4)	For chromosome scaffolding
  	
	“Perl WGS_SIBP_P3-Chr-C1.pl /home/user/Desktop/Test_DATA/Input /home/user/Desktop/Test_DATA/WHO_Full_Reference_genome/Chromosome /home/user/Desktop/Gen2Epi_Scripts/Output/Chrom_AssemblyTrimmedReads /home/user/Desktop/Test_DATA/WHO_Genome_Annotation/Chromosome 1 TXT Output”
	
  5)	For plasmid-type identification
  		
	“Perl WGS_SIBP_P3-Plas_C1.pl /home/user/Desktop/Test_DATA/Input Output/Plasmid_AssemblyTrimmedReads 1 /home/user/Desktop/Test_DATA/Plasmid.fasta Output”
	
  6)	For epidemiological analysis and AMR prediction of the assembled scaffolds: Please make sure to delete the existing output file before running the following commands.
  
 	 a.	NG-MAST
	 
	 	“perl MASTdbUpdate.pl”
	        “perl WGS_SIBP_P4_Epi.pl /home/user/Desktop/Test_DATA/Input Output/Chr_Scaffolds NGMAST Output”
		
	 b.	NG-MLST
	 
	 	“perl MLSTdbUpdate.pl”
	        “perl WGS_SIBP_P4_Epi.pl /home/user/Desktop/Test_DATA/Input Output/Chr_Scaffolds MLST Output MLST-Genes.fasta MLST_alleles.fasta pubMLST_profile.txt”
		
		Please Note: In case you encounter “BLAST database index” error then make sure to build the blast database for “MLST-Genes.fasta” using the following command:
		
	        “makeblastdb –in MLST-Genes.fasta –db nucl”
		
	 c.	NG-STAR	
	 
	 	“perl ngSTARdb.pl”
	        “perl NgSTARmeta.pl”
	        “perl WGS_SIBP_P4_Epi.pl /home/user/Desktop/Test_DATA/Input Output/Chr_Scaffolds ngstar Output AMR-Genes-NgStar.fasta AMR-Genes-NgStar-alleles.fasta”	
    	
	 d.	Chromosome-mediated Tetracycline Resistance	
	
	        “perl TetRes.pl rpsJ.fasta Output/Chr_Scaffolds/All_Sequences Output”
	        “perl SeqProt.pl Output”
		
# Contact

Professor Jo-Anne R Dillon: j.dillon@usask.ca 

Professor Anthony Kusalik: kusalik@cs.usask.ca 

Dr. Reema Singh: res498@usask.ca; res498@mail.usask.ca 

# Alternate links

https://github.com/ReemaSingh/Gen2EpiGUI 

ftp://www.cs.usask.ca/pub/combi

# Citation

Singh R, Yarmovich T, Kusalik A, Dillon JA. Gen2EpiGUI: User-Friendly Pipeline for Analyzing Whole-Genome Sequencing Data for Epidemiological Studies of Neisseria gonorrhoeae. Sexually Transmitted Diseases. 2020 Oct 1;47(10):e42-4.
