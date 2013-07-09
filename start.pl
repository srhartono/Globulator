#!/usr/bin/perl
# start.pl 
# by stella (srhartono@ucdavis.edu)
# main wrapper script
###############################

use warnings; use strict; 
use Config; use File::Copy; use Cwd;

#Get OS type and set up shell path
my $dir_user;
my $OS = $Config{'archname'};
if ($OS =~ m/MSWin/i) {
	$ENV{PATH} .= ";c:\\windows\\command".
              ";c:\\windows\\system32".
              ";c:\\winnt\\system32";
	$dir_user = $ENV{HOMEPATH};
}
elsif ($OS =~ m/darwin/i or $OS =~ m/linux/i) {	
	$dir_user = $ENV{HOME};
}
else {
	print "start.pl: your OS might not be supported\n";
	$dir_user = $ENV{HOME};
}

#check for important files
my $dir_home = getcwd;

if ($dir_home !~ m/globulator$/i) {
	($dir_home) = $0 =~ m/^(.*)\/start.pl$/i;
	($dir_home) = $0 =~ m/^(.*)\\start.pl$/i if ($OS =~ m/MSwin/i);
}
my $dir_imagej 		= $dir_home   . "/ImageJ"	;
my $dir_imagej_macros 	= $dir_imagej . "/macros/"	;
my $dir_bin 		= $dir_home   . "/bin/"		;
my $dir_res 		= $dir_home   . "/result/"	;
my $dir_slide 		= $dir_home   . "/PUT_SLIDES_HERE/"	;

#set result filename
my @time = localtime(time);
my $date = $time[5]+1900 . "_$time[4]_$time[3]";
my $hour = "_$time[2]_$time[1]";
my $dir_res_current2 = $dir_res . $date . $hour;
my $dir_res_current = $dir_res . $date . $hour . "/";
mkdir $dir_res_current;

#set path for imageJ
open (my $path, ">$dir_user/path.cfg") or die "can't create $dir_user/path.cfg (probably permission issue)\n"; #<- use open since touch is not supported on windows
print $path "$dir_home/PUT_SLIDES_HERE/DIC/\n";
print $path "$dir_home/PUT_SLIDES_HERE/RG/\n";
print $path "$dir_res_current\n";
close $path;

my @filename = ("globulator.pl", "GLOB_UNIX.ijm", "GLOB_WIN.ijm", "CRES_UNIX.ijm", "CRES_WIN.ijm", "CONT_UNIX.ijm", "CONT_WIN.ijm");
#check if files exist
foreach my $file(@filename) {
	$file = $dir_bin . "/" . $file;
	checkfile($file);
}
my $file_jar_orig = $dir_home . "/ij.jar"; checkfile ($file_jar_orig);
my $file_jar = $dir_imagej . "/ij.jar";
my $file_macro = $dir_imagej . "/macros/GLOB_UNIX.ijm";

#check if this is first time running or imageJ just got updated
#copy macro to imageJ macros folder
if ((not -e $file_macro and not -s $file_macro) or (not -e $file_jar)) {
	print "start.pl: Setting up ImageJ macros (first time runnng or updated)\n";
	copy("$file_jar_orig", "$dir_imagej") or die "error: can't copy $file_jar_orig (permission issue?)\n";
	my @macros = <$dir_bin*.ijm>;
	for (my $i = 0; $i< @macros; $i++) {
		print "start.pl: copying $macros[$i]...";
		copy("$macros[$i]", "$dir_imagej_macros") or die "error: can't copy $macros[$i] (permission issue?)\n";
		print "start.pl: success\n";
	}
}

#run imageJ
#imageJ will produce .txt files in result folder
#get ImageJ result files
my $type 	= $OS =~ m/MSWin/i ? "WIN" : "UNIX"; 
my $macroglob 	= $dir_imagej_macros . "GLOB_" . $type . ".ijm";
my $macrocres 	= $dir_imagej_macros . "CRES_" . $type . ".ijm";
my $macrocont 	= $dir_imagej_macros . "CONT_" . $type . ".ijm";
my @macros 	= ($macroglob, $macrocres, $macrocont);

for (my $i = 0; $i < @macros; $i++) {
	print "start.pl: Processing Globule Slides\n" 		if ($i == 0);
	print "start.pl: Processing Crescent Slides\n" 		if ($i == 1);
	print "start.pl: Processing Nucleated Cell Slides\n" 	if ($i == 2);
	my $fullpaths = "java -jar -Xmx1024m $file_jar $macros[$i]"; #Xmx1024m = allocate 1GB memory
	system($fullpaths);
}

my @dir_res = <$dir_res_current*>;

print "start.pl: Result directory = $dir_res_current\n";
my (@filenames_glob, @filenames_cres);

for (my $i = 0; $i < @dir_res; $i++) {
	if ($dir_res[$i] =~ m/DIC_(\w+)\.\.?txt$/i) {
		my ($filename) = $dir_res[$i] =~ m/DIC_(\w+)\.\.?txt$/i;
		push (@filenames_glob, $filename);
	}
	elsif ($dir_res[$i] =~ m/RG_(\w+)\.\.?txt$/i and $dir_res[$i] !~ m/RG_(\w+)CONT\.\.?txt$/i) {
		my ($filename) = $dir_res[$i] =~ m/RG_(\w+)\.\.?txt$/i;
		push (@filenames_cres, $filename);
	}
}
die "imageJ result files not found in $dir_res_current\n" if (not defined($filenames_glob[0]) and not defined($filenames_cres[0]));

#process result files
my $globpl = $dir_bin . "globulator.pl";
chmod 0777, $globpl unless ($OS =~ m/MSWin/i);
for (my $i = 0; $i<@filenames_glob; $i++) {
	my $DIC = $dir_res_current . "/DIC_" . $filenames_glob[$i] .     "..txt";
	my $RG  = $dir_res_current . "/RG_"  . $filenames_cres[$i] .     "..txt";
	my $RGC = $dir_res_current . "/RG_"  . $filenames_cres[$i] . ".CONT.txt";
	my $fullpath = "$globpl -a $DIC -b $RG -c $RGC";
	print "start.pl: perl -f $fullpath\n" and system ("perl -f $fullpath") if ($OS =~ m/MSWin/i);
	print "start.pl: $fullpath\n" and system ("$fullpath") if ($OS =~ m/darwin/i or $OS =~ m/linux/i or $OS !~ m/MSWin/i);
}

#make a summary
my $summary_path = $dir_bin . "summarizer.pl $dir_res_current2";
chmod 0777, $summary_path unless ($OS =~ m/MSWin/i);
system ("perl -f $summary_path") if ($OS =~ m/MSwin/i);
system ("$summary_path") if ($OS !~ m/MSWin/i);

# Create graph
my $draw_cmd = "perl bin/draw.pl $dir_res_current";
system($draw_cmd) == 0 or print "start.pl: Error at running bin/draw.pl: $!\n";

sub checkfile {
	my ($filename) = @_;
	if (not -e $filename and not -s $filename) {
		die "WARNING: start.pl: $filename does not exist at bin directory!\n";
	}
}
