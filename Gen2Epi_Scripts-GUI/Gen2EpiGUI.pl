#!/usr/bin/perl -w
#################################################
# Written by Trevor Yarmovich for VIDO-InterVac #
# Final Release: May 2019                       #
#################################################

use Tk;
use strict;
use Tk::Pane;
use Tk::Font;
use Tk::ROText;
use Tk::JPEG;
use Tk::PNG;
use Tk::Photo;
use Tk::Menu;


##################################################
# Set global variables to be used during session #
##################################################
my $windowTitle = "Gen2EpiGUI"; #Window title that will be displayed
my $projectPath = ""; #Path to input file
my $projectDir = ""; #Project Directory where input is located
my $outputDir = ""; #Output directory path that will be used
my $outputDirName = ""; #Name of the directory set by the user
my $fastqInput = ""; #Directory to be used for fastq files
my $genomeInputPath = ""; #File to be used  for Genome Input
my $genomeInputDir = ""; #Directory to be used for Genome Input
my $annotationInput = ""; #Directory to be used for Annotation Input
my $fileLength = ""; #Default File Size for Prepare Input Script

####################
# Script locations #
####################
my $wd = '/home/gen2epi/Desktop/Gen2Epi_Scripts'; #Working Directory
my $prepareInputScript = 'Prepare_Input.pl'; #Used for Prepare Input Script
my $qcScript = 'WGS_SIBP_P1.pl'; #Used for Quality Control Script
my $trimScript = 'WGS_SIBP_P1.pl'; #Used for Trimming Script
my $bothScript = 'WGS_SIBP_P1.pl'; #Used for BOTH Quality Control and Trimming
my $denovoScript = 'WGS_SIBP_P2.pl'; #Used for DeNovo
my $scaffChromScript = 'WGS_SIBP_P3-Chr-C1.pl'; #Used for Scaffolding Chromosome
my $scaffPlasmidScript = 'WGS_SIBP_P3-Plas_C1.pl'; #Used for Scaffolding Plasmid
my $mastUpdateScript = 'MASTdbUpdate.pl'; #Used for MAST Update
my $mastTypingScript = 'WGS_SIBP_P4_Epi.pl'; #Used for MAST Typing
my $mlstUpdateScript = 'MLSTdbUpdate.pl'; #Used for MLST Update
my $mlstTypingScript = 'WGS_SIBP_P4_Epi.pl'; #Used for MLST Typing
my $starUpdateDb = 'ngSTARdb.pl'; #Used for STAR db update
my $starUpdateMeta  = 'NgSTARmeta.pl'; #Used for STAR Meta db update
my $starTypingScript = 'WGS_SIBP_P4_Epi.pl'; #Used for STAR Typing
my $nucleotideScript = 'TetRes.pl'; #Used for Nucleotide
my $proteinScript = 'SeqProt.pl'; #Used for Protein
my $readMappingScript = 'ReadMapping.pl'; #Used for Read Mapping
my $preassembledScript = 'WGS_SIBP_P3-Chr-C1_2.pl'; #Used for preassembled  input

my $perlCommand = ""; #Perl Command that will be executed
my $executionSignal = ""; #The DisplayText summary of the command to be executed


##########################
# Graphic File locations #
##########################
my $usaskLogo = '/home/gen2epi/Desktop/Gen2Epi_Scripts/Graphics/usask-logo-small.png';
my $vidoLogo = '/home/gen2epi/Desktop/Gen2Epi_Scripts/Graphics/Vido_logo.png';
my $bacteria = '/home/gen2epi/Desktop/Gen2Epi_Scripts/Graphics/Ng-bacteria.jpg';


############################
# Trimming System defaults #
############################
my $lL = 3; #Leading Length - default value - range is 0-350
my $tL = 3; #TrailingLength - default value - range is 0-350
my $sWS = 4; #Sliding Window Start - default value - range is 1-40 
my $sWE = 15; #Sliding Window End - default value - range is 1-40 but >slidingWindowStart
my $mL = 30; #MinimumLength - default value - range is 0-350
my $cleaningBoth = "False";


###############################################################
# Create main window and set window size and the window title #
###############################################################
my $mw = MainWindow->new;
$mw->geometry($mw->screenwidth."x".$mw->screenheight."+0+0"); #Start the main window maximized to screen width and height
$mw->title($windowTitle);

my $fontSize = 12;
my $font = $mw->fontCreate(-size => $fontSize);

#######################################################################
# Create Frames and populate the frames with a Scrollable Text Widget #
#######################################################################
my $topPane = $mw->Frame->pack(-expand => 1, -fill => 'both', -side => 'top');
my $bottomPane = $mw->Frame()->pack(-fill => 'both', -side => 'bottom');
my $inputWindow = $topPane->Frame()->pack(-fill => 'x', -side => 'top');
my $textViewer = $topPane->Scrolled("ROText", -scrollbars => 'e', -font => $font)->pack(-expand => 1, -fill => 'both', -side => 'bottom');
my $topCanvas = $bottomPane->Canvas(-height => 100, -background => 'LavenderBlush2')->pack(-fill => 'both', -side => 'top');


populateTextViewerHelp("$wd/Documentation/StartingText");
$textViewer->insert('end',"\nThis text window is used only to display and record feedback from actions taken by the user. It cannot be edited.\n");

#my $inputColor = 'LavenderBlush2';
my $inputColor = 'SlateGray1';

############################################################
# Setup and create graphics that sit above the $textViewer #
############################################################
my $vidoImage = $topCanvas->Photo(-file => $vidoLogo);
my $bacteriaImage = $topCanvas->Photo(-file => $bacteria);
my $usaskImage = $topCanvas->Photo(-file => $usaskLogo);
$topCanvas->createImage(175, 50, -anchor => 'w', -image => $vidoImage);
$topCanvas->createImage(3, 50, -anchor => 'w', -image => $bacteriaImage);
$topCanvas->createImage(985, 50, -anchor => 'e', -image => $usaskImage);


#################################################
# Create the Menu that will execute the scripts #
#################################################
$mw->configure(-menu => my $menubar = $mw->Menu);
$menubar->configure(-font => 'Arial 12');

# -------------------------
# Create Parents in MenuBar
# -------------------------
my $project = $menubar->cascade(-label => '~Project', -tearoff => 'false');
my $dataCleaning = $menubar->cascade(-label => 'Data ~Cleaning', -tearoff => 'false');
my $assembly = $menubar->cascade(-label => '~Assembly', -tearoff => 'false');
my $amrStrain = $menubar->cascade(-label => 'AMR & ~Strain', -tearoff => 'false');
my $viewOutput = $menubar->cascade(-label => 'View Output ~Files', -tearoff => 'false');
my $helpMenu = $menubar->cascade(-label => '~Help', -tearoff => 'false', -background => 'green');

$mw->bind($mw, "<Control-p>" => \&executePrepareInput); #Bind Prepare Input
$mw->bind($mw, "<Control-f>" => sub{$fastqInput = openDirectory();}); #Bind Fastq
$mw->bind($mw, "<Control-g>" => sub{$genomeInputDir = openDirectory();}); #Bind Genome
$mw->bind($mw, "<Control-a>" => sub{$annotationInput = openDirectory();}); #Bind Annotation
$mw->bind($mw, "<Control-r>" => \&executeMapping); #Bind Read Mapping
$mw->bind($mw, "<Control-o>" => \&openFile); #Bind Open
$mw->bind($mw, "<Control-x>" => \&exit); #Bind Exit
$mw->bind($mw, "<Control-q>" => \&executeQC); #Bind Quality Control
$mw->bind($mw, "<Control-i>" => sub{$cleaningBoth = "False"; cleanTrim();}); #Bind Both
$mw->bind($mw, "<Control-b>" => sub{$cleaningBoth = "True"; cleanTrim();}); #Bind Both
$mw->bind($mw, "<Control-d>" => \&executeDeNovo); #Bind De Novo
$mw->bind($mw, "<Control-c>" => \&executeChromosome); #Bind Chromosome
$mw->bind($mw, "<Control-l>" => \&executePlasmid); #Bind Plasmid
$mw->bind($mw, "<Control-v>" => \&populateTextViewer); #Bind View Text File


# ----------------------------
# Menubar children of $project
# ----------------------------
$project->command(
	-label		=> '~Open Project',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-o',
	-command	=> \&openProject
);

$project->command(
	-label		=> 'Set Output Directory',
	-font		=> 'Arial 12',
	-command	=> \&chooseOutputDirectory
);
my $inputs = $project->cascade(
	-label		=> 'Set ~Input Directories',
	-font		=> 'Arial 12',
	-tearoff	=> 'false'
);
$project->separator;
$project->command(
	-label		=> '~Prepare Input',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-p',
	-command	=> \&chooseFileLength
);
$project->separator;
$project->command(
	-label		=> 'E~xit Program',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-x',
	-command	=> \&exit
);


# --------------------------
# Menubar children of Inputs 
# --------------------------
$inputs->command(
	-label		=> '~Fastq',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-f',
	-command	=> sub{$fastqInput = openDirectory();} # The input file for the fastq input
);
$inputs->command(
	-label		=> '~Genome File',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-g',
	-command	=> sub{$genomeInputDir = openDirectory();} # The input file for the genome input
);
$inputs->command(
	-label		=> '~Annotation',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-a',
	-command	=> sub{$annotationInput = openDirectory();} # The input file for the annotation input
);


# ---------------------------------
# Menubar children of $dataCleaning
# ---------------------------------
$dataCleaning->command(
	-label		=> '~Read Mapping',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-r',
	-command	=> \&executeMapping
);
#$dataCleaning->command(
#	-label		=> 'Contamination C~heck',
#	-accelerator	=> 'Ctrl-h',
#	-command	=> Execute Command Script
#);
$dataCleaning->separator;
$dataCleaning->command(
	-label		=> '~Quality Control',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-q',
	-command	=> \&executeQC
);
$dataCleaning->command(
	-label		=> 'Tr~imming',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-i',
	-command	=> sub{$cleaningBoth = "False"; cleanTrim();}
);
$dataCleaning->command(
	-label		=> '~Both',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-b',
	-command	=> sub{$cleaningBoth = "True"; cleanTrim();}
);
$dataCleaning->separator;
$dataCleaning->command(
	-label		=> 'Reset Trimming Parameters',
	-font		=> 'Arial 12',
	-command	=> \&resetTrimmingParameters
);


# -----------------------------
# Menubar children of $assembly
# -----------------------------
$assembly->command(
	-label		=> '~De Novo',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-d',
	-command	=> \&executeDeNovo
);
my $scaffold = $assembly->cascade(
	-label		=> '~Scaffolding',
	-font		=> 'Arial 12',
	-tearoff	=> 'false'
);
$assembly->command(
	-label		=> 'Preassembled Genome',
	-font		=> 'Arial 12',
	-command	=> \&executePreassembledContigs
);


# --------------------------------
# Menubar children of $scaffolding
# --------------------------------
my $chromosome = $scaffold->cascade(
	-label		=> '~Chromosome',
	-font		=> 'Arial 12',
	-tearoff	=> 'false'
);
$chromosome->command(
	-label		=> 'Multiple Genomes',
	-font		=> 'Arial 12',
	-command	=> \&executeMultipleGenomes
);
$chromosome->command(
	-label		=> 'Single Genomes',
	-font		=> 'Arial 12',
	-command	=> \&executeSingleGenomes
);
$scaffold->command(
	-label		=> 'P~lasmid',
	-font		=> 'Arial 12',
	-accelerator	=> 'Ctrl-l',
	-command	=> \&executeScaffPlasmid
);



# ------------------------------
# Menubar children of $amrStrain
# ------------------------------
my $mast = $amrStrain->cascade(
	-label		=> 'MAS~T',
	-font		=> 'Arial 12',
	-tearoff	=> 'false',
);
my $mlst = $amrStrain->cascade(
	-label		=> 'M~LST',
	-font		=> 'Arial 12',
	-tearoff	=> 'false',
);
my $star = $amrStrain->cascade(
	-label		=> 'STA~R',
	-font		=> 'Arial 12',
	-tearoff	=> 'false',
);
my $tetres = $amrStrain->cascade(
	-label		=> 'T~ETRES',
	-font		=> 'Arial 12',
	-tearoff	=> 'false',
);


# -------------------------
# Menubar children of $mast
# -------------------------
$mast->command(
	-label		=> 'MAST Update',
	-font		=> 'Arial 12',
	-command	=> \&executeMASTUpdate
);
$mast->command(
	-label		=> 'MAST Typing',
	-font		=> 'Arial 12',
	-command	=> \&executeMASTTyping
);


# -------------------------
# Menubar children of $mlst
# -------------------------
$mlst->command(
	-label		=> 'MLST Update',
	-font		=> 'Arial 12',
	-command	=> \&executeMLSTUpdate
);
$mlst->command(
	-label		=> 'MLST Typing',
	-font		=> 'Arial 12',
	-command	=> \&executeMLSTTyping
);


# -------------------------
# Menubar children of $star
# -------------------------
my $starUpdate = $star->cascade(
	-label		=> 'STAR Update',
	-font		=> 'Arial 12',
	-tearoff	=> 'false'
);
$star->command(
	-label		=> 'STAR Typing',
	-font		=> 'Arial 12',
	-command	=> \&executeSTARTyping
);


# ---------------------------
# Menubar children of $tetres
# ---------------------------
$tetres->command(
	-label		=> 'Nucleotide',
	-font		=> 'Arial 12',
	-command	=> \&executeNucleotide
);
$tetres->command(
	-label		=> 'Protein',
	-font		=> 'Arial 12',
	-command	=> \&executeProtein
);


# -------------------------------
# Menubar children of $starUpdate
# -------------------------------
$starUpdate->command(
	-label		=> 'STARdbUpdate',
	-font		=> 'Arial 12',
	-command	=> \&executeSTARdbUpdate
);
$starUpdate->command(
	-label		=> 'STARdbMetaDataUpdate',
	-font		=> 'Arial 12',
	-command	=> \&executeSTARdbMETAUpdate
);


# -------------------------
# Menubar children of $help
# -------------------------
$helpMenu->command(
	-label		=> 'FAQ',
	-font		=> 'Arial 12',
	#-command	=> sub {populateTextViewerHelp("$wd/Documentation/FAQ");}
	-command        => sub {
		system("firefox $wd/Documentation/FAQ.pdf");
	}
);

$helpMenu->command(
	-label		=> 'Introductory Demo',
	-font		=> 'Arial 12',
	-command	=> sub {
		system("firefox $wd/Documentation/Demo.pdf");
	}
);
$helpMenu->command(
	-label		=> 'User Manual',
	-font		=> 'Arial 12',
	-command	=> sub {
		system("firefox $wd/Documentation/UserManual.pdf");
	}
);
$helpMenu->command(
	-label		=> 'Reference Guide',
	-font		=> 'Arial 12',
	-command	=> sub {
		system("firefox $wd/Documentation/ReferenceGuide.pdf");
	}

);

$helpMenu->command(
	-label		=> 'VM Help',
	-font		=> 'Arial 12',
	#-command	=> sub {populateTextViewerHelp("$wd/Documentation/VM");}
	-command        => sub {
		system("firefox $wd/Documentation/VM.pdf");
	}
);
$helpMenu->command(
	-label		=> 'About',
	-font		=> 'Arial 12',
	-command	=> sub {populateTextViewerHelp("$wd/Documentation/About");}
);


# ------------------------------------
# Menubar children of $viewOutputFiles
# ------------------------------------
$viewOutput->command(
	-label		=> '~View Text File in Main Window',
	-font		=> 'Arial 12',
	-command	=> \&populateTextViewer
);
$viewOutput->command(
	-label		=> 'View Text in New Window',
	-font		=> 'Arial 12',
	-command	=> \&openTextViewer
);
$viewOutput->command(
	-label		=> 'View HTML in New Window',
	-font		=> 'Arial 12',
	-command	=> \&openHTMLViewer
);
	

#################
#################
## SUBROUTINES ##
#################
#################

sub chooseFileLength {

	#Remove old input window if exists
	my @kids = $inputWindow->children;
	foreach (@kids) { 
		$_->name->destroy();
	}
	$inputWindow->pack(-side => 'top', -fill => 'x'); #Repack inputWindow so it will redisplay the $tempPane after forgetPack

	# Fill $topFrame with labels and text entry for trimming execution - starts with default values	
	my $tempPane = $inputWindow->Frame->pack(-fill => 'x');
	$tempPane->configure(-background => $inputColor);

	my $parmTitle = $tempPane->Label(
		-text => 'Please type in the length of the file name: ',
		-background => $inputColor)
		->pack(-side => 'top', -anchor => 'w');
 
	my $parmDirLabel = $tempPane->Label(
		-text => 'Length (1 - 20 characters): ',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmDirEntry = $tempPane->Entry(
		-textvariable => \$fileLength, 
		-width => 2)
		->pack(-side => 'left');

	my $cancelButton = $tempPane->Button(
		-text => "Cancel", 
		-width => 12, 
		-command => sub{
			$tempPane->destroy(); 
			$inputWindow->packForget();
			})
		->pack(-side => 'right');
	my $confirmButton = $tempPane->Button(
		-text => "Confirm", 
		-width => 12,
		-command => sub{
			#Ensure file length is within accepted parameters
			if ($fileLength >= "1" && $fileLength <= "20") {
				$tempPane->destroy();
				$inputWindow->packForget();
				executePrepareInput();
				
			} 
			else {
				$textViewer->insert('end', "\n**SYSTEM ERROR** Please enter a number from 1 to 20.\n");
				$textViewer->see('end');
				$fileLength = "";
				$textViewer->bell;
			}
		})
		->pack(-side => 'right');
	$parmDirEntry->focus;

	

}


#######################################################################################################################
# Purpose: Subroutine to request output directory name from the user 						      #
# Postconditions: Opens the user input frame to allow user to enter in the output directory name,		      #
#			executes the setOutputDirectory subroutine then hides the input frame after pressing the      #
#			Confirm button, or just hides the input frame after pressing the Cancel button		      # 
#######################################################################################################################
sub chooseOutputDirectory {

	#Remove old input window if exists
	my @kids = $inputWindow->children;
	foreach (@kids) { 
		$_->name->destroy();
	}
	$inputWindow->pack(-side => 'top', -fill => 'x'); #Repack inputWindow so it will redisplay the $tempPane after forgetPack

	# Fill $topFrame with labels and text entry for trimming execution - starts with default values	
	my $tempPane = $inputWindow->Frame->pack(-fill => 'x');
	$tempPane->configure(-background => $inputColor);
	my $chooseDir = openDirectory();

	#If previously set, on cancel will set to last chosen $outputDir, otherwise will remain null
	if (not defined $chooseDir) {
	
		if ($outputDir ne '') {
			$textViewer->insert('end', "\n**SYSTEM** Invalid choice, output directory reset to $outputDir. If this is not correct, please set the output directory again...\n");
		}
		else {
			$textViewer->insert('end', "\n**SYSTEM** Invalid choice output directory not set. Please try again...\n");
		}
		$textViewer->see('end');
		$tempPane->destroy();
	}
	else {
	
		my $parmTitle = $tempPane->Label(
			-text => 'Type the name of your new output subdirectory, or leave the field blank and click confirm if the listed directory will be your output directory:', 
			-background => $inputColor)
			->pack(-side => 'top', -anchor => 'w');
 
		my $parmDirLabel = $tempPane->Label(
			-text => "$chooseDir/",
			-background => $inputColor)
			->pack(-side => 'left');
		my $parmDirEntry = $tempPane->Entry(
			-textvariable => \$outputDirName, 
			-width => 75)
			->pack(-side => 'left');

		my $cancelButton = $tempPane->Button(
			-text => "Cancel", 
			-width => 12, 
			-command => sub{
				$tempPane ->destroy(); 
				$inputWindow->packForget();
				})
			->pack(-side => 'right');
		my $confirmButton = $tempPane->Button(
			-text => "Confirm", 
			-width => 12,
			-command => sub{
				#Use regex to trim spaces at beginning and end of entry string to prevent creating a 
				#directory with spaces at the beginning or end of the string
				$outputDirName =~ s/^\s+//;
				$outputDirName =~ s/\s+$//; 
			
				#If string is empty just use selected directory otherwise use the new directory
				if ($outputDirName eq '') {
					$tempPane->destroy();
					$inputWindow->packForget();
					setOutputDirectory("$chooseDir");
					
				}
				else {
					$tempPane->destroy();
					$inputWindow->packForget();
					setOutputDirectory("$chooseDir/$outputDirName");
					
				}
			})
			->pack(-side => 'right');
		$parmDirEntry->focus;
		}
	
	
}


####################################################################
# Purpose: Subroutine to create the absolute output directory path #
# Preconditions:						   #
#	$_[0]: The name of the output directory specified 	   #
# Postconditions: Sets $outputDir to what the user chose	   #
####################################################################
sub setOutputDirectory {

	#$outputDir = $projectDir . '/' . $_[0];
	$outputDir = $_[0];
	#Check if output directory exists, if not, create it
	my $error;
	mkdir $outputDir or $error = $1;
	unless (-d $outputDir) {
		die "\n**SYSTEM** Cannot create directory $outputDir: $error\n";
	}
	$textViewer->insert('end', "\n**SYSTEM** The output directory has been set to $outputDir\n");
	$textViewer->see('end');

	mkdir "$outputDir/SystemLogs" or $error = $1;
	unless (-d "$outputDir/SystemLogs") {
		die "\n**SYSTEM** Cannot create directory $outputDir/SystemLogs: $error\n";
	}
	$textViewer->insert('end', "\n**SYSTEM** The System Logs directory has been set to $outputDir/SystemLogs\n");

}


###############################################################################################################
# Purpose: Subroutine opens the default web browser viewer and fills it with the HTML file chosen by the user #
# PostConditions: Launches Firefox and opens the user selected html file                                      #
###############################################################################################################
sub openHTMLViewer {

	my $htmlFileTypes = [['HTML Files', ['.html']]];
	my $openHtmlFile = $mw->getOpenFile(
		-filetypes 	=> $htmlFileTypes, 
		-initialdir 	=> "/home/gen2epi/Desktop/Test_DATA",
		-title		=> "Open Text File"
	);

	system("firefox $openHtmlFile&");
}


########################################################################################################
# Purpose: Subroutine opens the default text viewer and fills it with the text file chosen by the user #
# PostConditions: Opens the default text editor in a new window with the user selected text file       #
########################################################################################################
sub openTextViewer {

	my $textFileTypes = [['Text Files', ['.txt', '.text', '.fasta', '.csv', '.log']]];
	my $openTextFile = $mw->getOpenFile(
		-filetypes 	=> $textFileTypes, 
		-initialdir 	=> "/home/gen2epi/Desktop/Test_DATA",
		-title		=> "Open Text File"
	);
	system("xdg-open $openTextFile&") if $openTextFile;
}

#############################################################################
# Purpose: Subroutine to populate @textViewer with help file information    #
# Postconditions: Populates the textviewer with the help file 		    #
#############################################################################
sub populateTextViewerHelp {

	$textViewer->configure(-font => 'Arial 16', -foreground => 'blue');
	my $textFile = $_[0];

	$textViewer->delete("1.0", 'end');
	
	open(F, $textFile) || die "**SYSTEM** Can't open $textFile: $!\n\n";
	while(<F>)
	{
		# Insert each line to the $textViewer widget
		$textViewer->insert('end', $_);
	}
	# Close the file
	close(F);
}


#############################################################################
# Purpose: Subroutine to populate @textViewer with textfile information     #
# Postconditions: Populates the textviewer with the user selected text file #
#############################################################################
sub populateTextViewer {
	
	my $fileTypes = [['Text Files', ['.txt', '.text', '.fasta', '.csv', '.log']]];
	my $open = $mw->getOpenFile(
		-filetypes 	=> $fileTypes,
		-title		=> "Open Text File"
	);
	my $textFile = $open if $open;

	$textViewer->configure(-font => 'Arial 12', -foreground => 'black');
	$textViewer->delete("1.0", 'end');
	
	open(F, $textFile) || die "\n**SYSTEM** Can't open $textFile: $!\n";
	while(<F>)
	{
		# Insert each line to the $textViewer widget
		$textViewer->insert('end', $_);
	}
	# Close the file
	close(F);

}


################################################################################################################
# Purpose: Subroutine call openFile and sets $projectPath, $projectDir, and the windowTitle based on selection #
# Postconditions: Sets the window title, the $projectPath, and the $projectDir based on user selection         #
################################################################################################################
sub openProject {
	$projectPath = openFile(); # The input file for the project
	$projectDir = `dirname $projectPath | tr -d '\n'` if $projectPath; # The directory of the input file
		
	$textViewer->insert('end', "\n**SYSTEM** Project Working Directory set to $projectDir.\n"); 
	$textViewer->see('end');
	$windowTitle = qq {Gen2EpiGUI - PROJECT OPEN: "$projectPath"} if $projectPath;
	$mw->title($windowTitle);
}

############################################
# Subroutine opens genome file and sets it #
############################################
sub openGenomeFile {
	
	my $open = $mw->getOpenFile(
		-initialdir 	=> $genomeInputDir,
		-title		=> "Choose Genome Input File to Use");
	$textViewer->insert('end', "\n**SYSTEM** File $open chosen by user.\n") if $open;
	$textViewer->see('end');
	return $open; #The input file for genome TETRES
}

###########################################################################################
# Purpose: Subroutine to allow user to select a file and return that file                 #
# Return: Returns the absolute path to the file selected by the user                      #
###########################################################################################
sub openFile {
	my $open = $mw->getOpenFile(
		-initialdir 	=> "/home/gen2epi/Desktop/Test_DATA",
		-title		=> "Choose Project Input File");
	$textViewer->insert('end', "\n**SYSTEM** File $open chosen by user.\n") if $open;
	$textViewer->see('end');
	return $open;
}


#######################################################################
# Purpose: Subroutine to allow the user to select a directory to open #
# Return: Returns the absolute path to the user selected directory    #
#######################################################################
sub openDirectory {
	my $openDir = $mw->chooseDirectory(
		-initialdir 	=> '/home/gen2epi/Desktop/Test_DATA',
		-title 		=> 'Choose a Directory');
	$textViewer->insert('end', "\n**SYSTEM** Directory $openDir chosen by user.\n") if $openDir;
	$textViewer->see('end');
	return $openDir;
}


###############################################################################################
# Purpose: Subroutine calls sub trimmingParameters, and uses those values to execute Trimming #
# Postconditions: executes the trimmingParameters subroutine                                  #
###############################################################################################
sub cleanTrim {

	
	trimmingParameters();
}


########################################################################################################################
# Purpose: Subroutine calls sub trimmingParameters, and uses those values to execute BOTH Trimming and Quality Control #
# Postconditions: executes the executeBoth subroutine                                                                  #
########################################################################################################################
sub cleanBoth {
	
	executeBoth();
}


#######################################################################################################################
# Purpose: Subroutine to request trimming parameters from the user and change the default parameters for this session #
# Postconditions: Opens the user input frame to allow user to enter in the trimming parameters,			      #
#			executes the validateTrimming subroutine after pressing the Confirm button using the 	      #
#			parameters set by the user and then hides the input frame, or just hides the input frame      #
#			after pressing the Cancel button							      # 
#######################################################################################################################
sub trimmingParameters {
	
	#Set temporary variables to hold user entry until commit
	my $templL = $lL;
	my $temptL = $tL;
	my $tempsWS = $sWS;
	my $tempsWE = $sWE;
	my $tempmL = $mL;

	#Remove old input window if exists
	my @kids = $inputWindow->children;
	foreach (@kids) { 
		$_->name->destroy();
	}
	$inputWindow->pack(-side => 'top', -fill => 'x'); #Repack inputWindow so it will redisplay the $tempPane after forgetPack

	# Fill $topFrame with labels and text entry for trimming execution - starts with default values	
	my $tempPane = $inputWindow->Frame->pack(-fill => 'x');
	$tempPane->configure(-background => $inputColor);

	my $parmTitle = $tempPane->Label(
		-text => 'Please confirm parameters to be used:',
		-background => $inputColor)
		->pack(-side => 'top', -anchor => 'w');

	my $parmLeadingLengthLabel = $tempPane->Label(
		-text => '     Leading Length',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmLeadingLengthEntry = $tempPane->Entry(
		-textvariable => \$templL, 
		-width => 4)
		->pack(-side => 'left');

	my $parmTrailingLengthLabel = $tempPane->Label(
		-text => '     Trailing Length',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmTrailingLengthEntry = $tempPane->Entry(
		-textvariable => \$temptL, 
		-width => 4)
		->pack(-side => 'left');

	my $parmSlidingWindowStartLabel = $tempPane->Label(
		-text => '     Sliding Window Start',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmSlidingWindowStartEntry = $tempPane->Entry(
		-textvariable => \$tempsWS, 
		-width => 4)
		->pack(-side => 'left');

	my $parmSlidingWindowEndLabel = $tempPane->Label(
		-text => '     Sliding Window End',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmSlidingWindowEndEntry = $tempPane->Entry(
		-textvariable => \$tempsWE, 
		-width => 4)
		->pack(-side => 'left');

	my $parmMinimumLengthLabel = $tempPane->Label(
		-text => '     Minimum Length',
		-background => $inputColor)
		->pack(-side => 'left');
	my $parmMinimumLengthEntry = $tempPane->Entry(
		-textvariable => \$tempmL, 
		-width => 4)
		->pack(-side => 'left');

	my $parmCancelButton = $tempPane->Button(
		-text => "Cancel", 
		-width => 12, 
		-command => sub{
			$tempPane->destroy(); 
			$inputWindow->packForget();
			})
		->pack(-side => 'right');
	my $parmConfirmButton = $tempPane->Button(
		-text => "Confirm", 
		-width => 12,
		-command => sub{
			
			#Check if user entry is valid
			my $boolean = validateTrimming($templL, $temptL, $tempsWS, $tempsWE, $tempmL);

			if ($boolean eq 'true') {
				#change session parameters
				$lL = $templL;
				$tL = $temptL;
				$sWS = $tempsWS;
				$sWE = $tempsWE;
				$mL = $tempmL;
				$textViewer->insert('end', "\n**SYSTEM** Trimming Validation Successful.\n");
				$textViewer->see('end');

				#Remove input window so user can't click button again
				$tempPane->destroy();
				$inputWindow->packForget();

				#Execute Command to run Trimming
				if ($cleaningBoth eq "True") {
					executeBoth(); 
				}
				else { 
					executeTrimming();
				}
			}
			else {
				#Send user feedback on error
				$textViewer->delete("1.0", 'end');
				$textViewer->insert("1.0", "\n**SYSTEM ERROR** One of your Trimming parameters is outside of the allowed range.\n");
				$textViewer->see('end');
				$textViewer->bell;
			} 		
		})
		->pack(-side => 'right');
	$parmLeadingLengthEntry->focus;
}


########################################################################
# Purpose: Subroutine resets the trimming parameters to system default #
# Postconditions: Resets the trimming parameters tto system default    #
########################################################################
sub resetTrimmingParameters {
	$lL = 3; #default value - range is 0-350
	$tL = 3; #default value - range is 0-350
	$sWS = 4; #default value - range is 1-40 
	$sWE = 15; #default value - range is 1-40 but >slidingWindowStart
	$mL = 30; #default value - range is 0-350
	$textViewer->delete("1.0", 'end');

	#Send feedback to the user
	my $formattedUpdate = 
	"\n**SYSTEM** Trimming parameters reset to:
	Leading Length: $lL
	Trailing Length: $tL
	Sliding Window: $sWS:$sWE
	Minimum Length: $mL\n";
	$textViewer->insert("1.0", $formattedUpdate);
	$textViewer->see('end');
}

#######################################################################################
# Purpose: Subroutine executes the Prepare_Input script 		    	      #
# Postconditions: calls the subroutine scriptExecution to execute $prepareInputScript #
#######################################################################################
sub executePrepareInput {
	
	$perlCommand = "perl $wd/$prepareInputScript $fastqInput $fileLength $outputDir 2>&1" if $fileLength;
	$executionSignal = "Prepare_Input";
	scriptExecution($perlCommand, $executionSignal);
}

#######################################################################################
# Purpose: Subroutine executes the Preassembled Contigs script 		    	      #
# Postconditions: calls the subroutine scriptExecution to execute $preassembledScript #
#######################################################################################
sub executePreassembledContigs {

	$perlCommand = "perl $wd/$preassembledScript $outputDir/Prepare_Input.txt $genomeInputDir/WHO-F.fasta $outputDir/Chrom_AssemblyTrimmedReads $annotationInput/WHO-F.txt 1 $outputDir";
	$executionSignal = "Preassembled_Contigs";
	scriptExecution($perlCommand, $executionSignal);
}

#######################################################################################
# Purpose: Subroutine executes the Preassembled Contigs script for Single Genomes     #
# Postconditions: calls the subroutine scriptExecution to execute $preassembledScript #
#######################################################################################
sub executeSingleGenomes {

	$perlCommand = "perl $wd/$preassembledScript $outputDir/Prepare_Input.txt $genomeInputDir/WHO-F.fasta $outputDir/Chrom_AssemblyTrimmedReads $annotationInput/WHO-F.txt 1 $outputDir";
	$executionSignal = "Single_Genomes";
	scriptExecution($perlCommand, $executionSignal);
}

###############################################################################
# Purpose: Subroutine executes the Trimming perl script 	              #
# Postconditions: calls the subroutine scriptExecution to execute $trimScript # 
###############################################################################
sub executeTrimming {

	$perlCommand = "perl $wd/$trimScript $projectPath $fastqInput Trimming $outputDir $lL $tL $sWS:$sWE $mL 2>&1";
	$executionSignal = "Trimming";
	scriptExecution($perlCommand, $executionSignal);
}


#############################################################################
# Purpose: Subroutine executes the Quality Control perl script 		    #
# Postconditions: calls the subroutine scriptExecution to execute $qcScript #
#############################################################################
sub executeQC {
	
	$perlCommand = "perl $wd/$qcScript $projectPath $fastqInput qualitycheck $outputDir 2>&1"; 
	$executionSignal = "Quality_Control";
	scriptExecution($perlCommand, $executionSignal);
}


###############################################################################
# Purpose: Subroutine executes both Trimming and Quality Control 	      #
# Postconditions: calls the subroutine scriptExecution to execute $bothScript #
###############################################################################
sub executeBoth {

	$textViewer->insert('end', "\n**SYSTEM** Execute BOTH QC and Trimming.\n");

	$perlCommand = "perl $wd/$bothScript $projectPath $fastqInput both $outputDir $lL $tL $sWS:$sWE $mL 2>&1"; 
	$executionSignal = "Quality_Control_AND_Trimming";
	scriptExecution($perlCommand, $executionSignal);
}


#################################################################################
# Purpose: Subroutine executes De Novo 					        #
# Postconditions: calls the subroutine scriptExecution to execute $denovoScript #
#################################################################################
sub executeDeNovo {

	$perlCommand = "perl $wd/$denovoScript $projectPath $outputDir/Trimming trimmed 2 $outputDir 2>&1";
	$executionSignal = "De_Novo";
	scriptExecution($perlCommand, $executionSignal);
}


####################################################################################
# Purpose: Subroutine executes Scaffolding Chromosome 				   #
# Postconditions: calls the subroutine sciptExecution to execute $scaffChromScript #
####################################################################################
sub executeMultipleGenomes {

	$perlCommand = "perl $wd/$scaffChromScript $projectPath $genomeInputDir $outputDir/Chrom_AssemblyTrimmedReads $annotationInput 2 TXT $outputDir 2>&1";
	$executionSignal = "Multiple_Genomes";
	scriptExecution($perlCommand, $executionSignal);

}


#######################################################################################
# Purpose: Subroutine executes Scaffolding Plasmid 				      #
# Postconditions: calls the subroutine scriptExecution to execute $scaffPlasmidScript #
#######################################################################################
sub executeScaffPlasmid {

	$perlCommand = "perl $wd/$scaffPlasmidScript $projectPath $outputDir/Plasmid_AssemblyTrimmedReads 1 $projectDir/Plasmid.fasta $outputDir 2>&1";
	$executionSignal = "Scaffolding_Plasmid";
	scriptExecution($perlCommand, $executionSignal);

}


#####################################################################################
# Purpose: Subroutine executes MAST Update 					    #
# Postconditions: calls the subroutine scriptExecution to execute $mastUpdateScript #
#####################################################################################
sub executeMASTUpdate {

	$perlCommand = "perl $wd/$mastUpdateScript 2>&1";
	$executionSignal = "MAST_Update";
	scriptExecution($perlCommand, $executionSignal);

}


#####################################################################################
# Purpose: Subroutine executes MAST Typing 					    #
# Postconditions: calls the subroutine scriptExecution to execute $mastTypingScript #
#####################################################################################
sub executeMASTTyping {

	$perlCommand = "perl $wd/$mastTypingScript $projectPath $outputDir/Chr_Scaffolds NGMAST $outputDir 2>&1";
	$executionSignal = "MAST_Typing";
	scriptExecution($perlCommand, $executionSignal);

}


#####################################################################################
# Purpose: Subroutine executes MLST Update 					    #
# Postconditions: calls the subroutine scriptExecution to execute $mlstUpdateScript #
#####################################################################################
sub executeMLSTUpdate {

	$perlCommand = "perl $wd/$mlstUpdateScript 2>&1";
	$executionSignal = "MLST_Update";
	scriptExecution($perlCommand, $executionSignal);

}


#####################################################################################
# Purpose: Subroutine executes MLST Typing 					    #
# Postconditions: calls the subroutine scriptExecution to execute $mlstTypingScript #
#####################################################################################
sub executeMLSTTyping {

	$perlCommand = "perl $wd/$mlstTypingScript $projectPath $outputDir/Chr_Scaffolds MLST $outputDir $wd/MLST-Genes.fasta $wd/MLST_alleles.fasta $wd/pubMLST_profile.txt 2>&1";
	$executionSignal = "MLST_Typing";
	scriptExecution($perlCommand, $executionSignal);

}


#####################################################################################
# Purpose: Subroutine executes STAR Typing 					    #
# Postconditions: calls the subroutine scriptExecution to execute $starTypingScript #
#####################################################################################
sub executeSTARTyping {

	$perlCommand = "perl $wd/$starTypingScript $projectPath $outputDir/Chr_Scaffolds ngstar $outputDir $wd/AMR-Genes-NgStar.fasta $wd/AMR-Genes-NgStar-alleles.fasta 2>&1";
	$executionSignal = "STAR_Typing";
	scriptExecution($perlCommand, $executionSignal);

}


#################################################################################
# Purpose: Subroutine executes STARUpdateDb 				        #
# Postconditions: calls the subroutine scriptExecution to execute $starUpdateDb #
#################################################################################
sub executeSTARdbUpdate {

	$perlCommand = "perl $wd/$starUpdateDb 2>&1";
	$executionSignal = "STAR_Database_Update";
	scriptExecution($perlCommand, $executionSignal);

}


##############################################################################
# Purpose: Subroutine executes STARdbMETAUpdate 			     #
# Postconditions: calls subroutne scriptExecution to execute $starUpdateMeta #
##############################################################################
sub executeSTARdbMETAUpdate {

	$perlCommand = "perl $wd/$starUpdateMeta 2>&1";
	$executionSignal = "STAR_Database_META_Update";
	scriptExecution($perlCommand, $executionSignal);

}

#########################################################################################
# Purpose: Subroutine executes ReadMapping 						#
# Postconditions: calls subroutine openGenomeFile to get the user defined genome file	#
#	and then calls subroutine scriptExecution to execute $readMappingScript		#
#########################################################################################
sub executeMapping {
	$genomeInputPath = openGenomeFile();
	$perlCommand ="perl $wd/$readMappingScript $projectPath $genomeInputPath $fastqInput $outputDir 2>&1";
	$executionSignal = "Read_Mapping";
	scriptExecution($perlCommand, $executionSignal) if $genomeInputPath;
}

#################################################################################
# Purpose: Subroutine executes TetRes						#
# Postconditions: calls subroutine scriptExecution to execute $nucleotideScript	#
#################################################################################
sub executeNucleotide {
	$perlCommand = "perl $wd/$nucleotideScript $wd/rpsJ.fasta $outputDir/Chr_Scaffolds/All_Sequences $outputDir 2>&1";
	$executionSignal = "Nucleotide";
	scriptExecution($perlCommand, $executionSignal);
}


#################################################################################
# Purpose: Subroutine executes SeqProt						#
# Postconditions: calls subroutine scriptExecution to execute $proteinScript	#
#################################################################################
sub executeProtein {
	$perlCommand = "perl $wd/$proteinScript $outputDir/TetResOut $outputDir 2>&1";
	$executionSignal = "Protein";
	scriptExecution($perlCommand, $executionSignal);
}

############################################################################################################################
# Purpose: Subroutine executes the $perlCommand and signals the user $executionSignal of the process that sent the request #
# Preconditions:													   #
#	$_[0]: The script with parameters to be executed = $perlCommand							   #
#	$_[1]: The summarized text description of the perlCommand = $executionSignal					   #
# Postconditions: $perlCommand is run and its STDOUT and STDERR are routed to the $textViewer as user feedback while the   #
#			script runs. Once completed it also creates a log file in the output directory with the file name  #
#			$executionSignal.log to record the script feedback for later review				   #
############################################################################################################################
sub scriptExecution {

	if ($projectPath ne "" && $outputDir ne "" && $fastqInput ne "" && $genomeInputDir ne "" && $annotationInput ne "" || $fastqInput ne "" && $outputDir ne "" && $executionSignal eq "Prepare_Input" || $projectPath ne "" && $outputDir ne "" && $genomeInputDir ne "" && $annotationInput ne "" && $executionSignal eq "Preassembled Contigs") {

		$textViewer->configure(-font => 'Arial 12', -foreground => 'black');
		$textViewer->delete("1.0", 'end');
	
		# prints execution Signal
		$textViewer->insert('end', "\n**SYSTEM** Executing $_[1] script, please wait...\n");
		$textViewer->insert('end', "\n$_[0]\n\n");
		$textViewer->update();
	
		# opens temporary output to feed stdout and stderr
		open (PERL_OUTPUT, '-|', $_[0]) or die "\n**SYSTEM ERROR** Error with $_[1].pl\n";
	
		my $streamedOutput;

		# Streams output to textViewer
		while(defined ($streamedOutput =<PERL_OUTPUT>))
		{
			# Insert each line to the $textViewer widget
			$textViewer->insert('end', $streamedOutput);
			$textViewer->update();
			$textViewer->see('end');
		}
		close(PERL_OUTPUT);
	
		# Signals completion
		$textViewer->insert('end', "\n**SYSTEM** Script completed ($_[1])...\n");
	
		#Write to log file in output directory
		open (LOGFILE, ">$outputDir/SystemLogs/$_[1].log");
		print LOGFILE $textViewer->get("1.0", 'end');
		close(LOGFILE);
		$textViewer->insert('end', "\n**SYSTEM** Logged script output to $outputDir/SystemLogs/$_[1].log\n");
		$textViewer->update();
		$textViewer->see('end');
	} else {
		$textViewer->delete("1.0",'end');
		$textViewer->insert('end', "\n**SYSTEM ERROR** Please set output path, and all inputs before executing scripts.\n");
	}
	$textViewer->see('end');
}


##########################################################################################
# Purpose: Subroutine that checks that the trimming values are within accepted limits    #
# Preconditions: 									 #
#	_[0]: Leading Length								 #
#	_[1]: Trailing Length								 #
#	_[2]: Sliding Window Start							 #
#	_[3]: Sliding Window End							 #
#	_[4]: Minimum Length								 #
# Return: 'true' if passes validation, 'false' otherwise				 #
##########################################################################################
sub validateTrimming {
	# Check to see that all parameters are within valid ranges before executing script
	if (
		$_[0] >= 0 && $_[0] <= 350 &&
		$_[1] >= 0 && $_[1] <= 350 &&
		$_[2] >= 1 && $_[2] <= 40 &&
		$_[3] >= 1 && $_[3] <= 40 &&
		$_[4] >= 0 && $_[4] <= 350) {

		return 'true';	
		
	} else {
		
		return 'false';	
	} 
}

MainLoop;
