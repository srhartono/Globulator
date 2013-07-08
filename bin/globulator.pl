#!/usr/bin/perl
# globulator.pl by Stella
# special thanks to Keith and Ian;
##############################

use warnings; use strict; use Getopt::Std;
use Config; use Cwd;

my $usage = "usage: globulator.pl -a <globule file (DIC)> -b <crescent file (R+G)> -c <contamination file (R+G)>
options:
 -h: help
 -v: version
 -a: globule file (DIC)
 -b: crescent file (R+G)
 -c: contamination file (R+G) 
";

my %opt;
getopts('hva:b:c:_', \%opt);
if ($opt{h}) {print $usage; exit}
if ($opt{v}) {print "globulator.pl: version 1.1\n";exit}

die $usage unless defined($opt{a}) and defined($opt{b}) and defined($opt{c});
checkfile($opt{a});
checkfile($opt{b});
checkfile($opt{c});
# Setting OS and directories
my $OS = $Config{'archname'};
my $dir_bin = getcwd;
my $dir_home;
if ($dir_bin !~ m/globulator\/bin$/i) {
	($dir_bin) = $0 =~ m/^(.*)\/globulator.pl$/i;
	($dir_bin) = $0 =~ m/^(.*)\\globulator.pl$/i if ($OS =~ m/MSwin/i);
}

($dir_home) = $dir_bin =~ m/^(.*)\/bin/i;
my @time = localtime(time);
my $date = $time[5]+1900 . "_$time[4]_$time[3]";
my $hour = "_$time[2]_$time[1]_$time[0]";
my ($direc) = $opt{a} =~ m/(.*)\/DIC_.*.txt$/i;

#inputs
my ($glob_input, $cres_input, $cont_input) = ($opt{a}, $opt{b}, $opt{c});

#global vars
my $pi = 3.141592565;
my $reverse = ($glob_input =~ m/rev.txt$/i) ? 1 : 0;

#make directory unless it exist
my ($path) = $glob_input =~ m/^.*\/DIC_(.*).txt$/i;
die "make sure Globule file label start with DIC!\n" unless defined($path);

#read
#returns the (area, x, y of) each in that format.
my (@glob) = process_file($glob_input, 'glob');
my (@cres) = process_file($cres_input, 'cres');
my (@cont) = process_file($cont_input, 'cont');

open (my $nuclout, ">$direc\/NUCLEATED_$path.txt") or die "can't open NUCLEATED_$path.txt\n";
open (my $globout, ">$direc\/GLOB_$path\.txt") or die "can't open GLOB_$path\.txt\n";
open (my $cresout, ">$direc\/CRES_$path\.txt") or die "can't open CRES_$path\.txt\n";
open (my $statout, ">$direc\/STAT_$path\.txt") or die "can't open STAT_$path\.txt\n";
open (my $linkout, ">$direc\/LINK_$path\.txt") or die "can't open LINK_$path\.txt\n";
open (my $ambiout, ">$direc\/AMBI_$path\.txt") or die "can't open AMBI_$path\.txt\n";

#debug the coordinates
debug_coor(\@glob, \@cres);

#stats 
#Returns distribution at output.txt, in the same folder. 
#Also will calculate resolution and slide size based on max x and max y
my ($length_map, $width_map) = stats(@glob);
#make map array and push each globule values accordingly (g contains globule values)
my (@map);
foreach my $g(@glob) {

	my $x = int(${$g}{x}/$length_map); 
	my $y = int(${$g}{y}/$width_map);
	push @{$map[$x][$y]}, $g;
}

#make map array that does not have globule value to have empty value instead of undefined.
@map = mapclean(@map);

#main (link crescent to globule)
my (@used_bin, @used_glob, @amb_cres);
my $check = 0;
print $linkout "\n>LINKED<\n";
print $linkout "Cres_area\tCres_x\tCres_y\tGlob_area\tGlob_x\tGlob_y\n";
foreach my $c(@cres) {
	my $x = int(${$c}{x}/$length_map);
	my $y = int(${$c}{y}/$width_map);

	#create bin, which is the "zoomed in" vesion of @map. 
	#First, define area to be searched
	#Then we will only search globules in this zoomed in map instead of the whole globule.
	
	my @bin;
	my $min_x = $x-1 <= 0 ? 0:$x-1; 
	my $max_x = $x+1 < @map? $x+1:@map-1; 
	my $min_y = $y-1 <= 0 ? 0:$y-1;
	my $max_y = $y+1 < @map ? $y+1:@map-1;
	for (my $i = $min_x; $i<=$max_x; $i++) {
		for (my $j = $min_y; $j<=$max_y; $j++) {
			my $maplength = @{$map[$i][$j]};
			for (my $k = 0; $k < $maplength; $k++) {
				if (defined($used_bin[$i])) {
				my $used_bin_length = @{$used_bin[$i]};
					for (my $l = 0; $l < $used_bin_length; $l++) {
						if (defined(${$map[$i][$j][$k]}{x}) and defined($used_bin[$i][$l])) {
							if (${$map[$i][$j][$k]}{x} == $used_bin[$i][$l]) {
								$map[$i][$j][$k] = ();
							}
						}	
					}
				}
			}
			if (defined($map[$i][$j])) { 
				push (@bin, @{$map[$i][$j]});
			}

		}
	}
	my ($xc, $yc, $area_c) = (${$c}{x}, ${$c}{y}, ${$c}{area});
	
	#links = link the globule and crescent
	#used_bin contains globule that has been linked, to make sure that the linked globule is only ONCE.
	my $usedglob = links(\$xc, \$yc, \$area_c, \@bin);

	if (defined($usedglob) and $usedglob != 1) {
		$check = 1;
		
		#make a map, so it's faster to search.
		my $x = int($usedglob/$length_map);
		push (@{$used_bin[$x]}, $usedglob);
			
		for (my $i = 0; $i < @used_bin; $i++) {
			if (not defined($used_bin[$i])) {
				$used_bin[$i] = ();
			}
			else {
				my $length = @{$used_bin[$i]};
				for (my $j = 0; $j <$length; $j++) {
				}
			}
		}
	}
}

print $ambiout "\n>AMBIGUOUS CRESCENT<\nCres_x\ty_coor\yCres_area\n";
foreach my $cresent(@amb_cres) {
	foreach my $hash(@$cresent) {
		my ($xc, $yc, $area_c) = (${$hash}{x}, ${$hash}{y}, ${$hash}{area});
		print $ambiout "$xc\t$yc\t$area_c\n";
	}
}
close ($globout);
close ($cresout);
close ($nuclout);
close ($statout);
close ($linkout);
close ($ambiout);

print "globulator.pl: result directory = $direc\n";
print "globulator.pl: NUCLEATED_$path.txt file gives total area of contamination\n";
print "globulator.pl: GLOB_$path\.txt file is a list of globule area and coordinates\n";
print "globulator.pl: CRES_$path\.txt file is a list of crescent area and coordinates\n";
print "globulator.pl: AMBI_$path\.txt file is a list of crescent area and coordinates that is ambiguous (can't be linked)\n";
print "globulator.pl: LINK_$path\.txt file is a list of crescent area and coordinates and their linked globules\n";
print "globulator.pl: STAT_$path\.txt file is a distribution of globule area\n";

exit(0);

###############
# SUBROUTINES #
###############

#1 process file
sub process_file {
	my ($input, $type) = (@_);

	my $small_area = 0;
	print "globulator.pl: processing $input...\n";
	my @area_check = `cut -f2 $input`;
	@area_check = sort {$b cmp $a} @area_check;
	shift(@area_check) if $area_check[0] =~ /Area/;
	if ($area_check[0] < 500000) {$small_area = 1};

	open (my $in, "<$input") or die "Can't open $input\n";
	
	#get location of each data, which is on the header
	my ($loc_x, $loc_y, $loc_area, $loc_circ, $loc_round, $loc_minor, $loc_angle);
	my @arr = split("\t", my $line = <$in>);
	
	for (my $i=0;$i<@arr;$i++) {
		($loc_x = $i) if ($arr[$i] =~ m/^X$/i);
		($loc_y = $i) if ($arr[$i] =~ m/^Y$/i);
		($loc_area = $i) if ($arr[$i] =~ m/^Area$/i);
		($loc_circ = $i) if ($arr[$i] =~ m/^Circ.$/i);
		($loc_round = $i) if ($arr[$i] =~ m/^Round$/i);
		($loc_minor = $i) if ($arr[$i] =~ m/^Round$/i);
		($loc_angle = $i) if ($arr[$i] =~ m/^Angle$/i);		
	}

	#process data inside file</IN>
	my @coor;
	while (my $line = <$in>) {
		chomp($line);
		next if $line !~ /^\d/;
		my @arr = split("\t", $line);
		my ($area, $x, $y, $circ, $round, $minor, $angle) = ($arr[$loc_area], $arr[$loc_x], $arr[$loc_y], $arr[$loc_circ], $arr[$loc_round], $arr[$loc_minor], $arr[$loc_angle]);
		#if it's globule, correct area, x, and y.
		if (($type) =~ m/^.*glob.*$/is) {
		die "Died at $line\n" if not defined($area);
			
			if ($circ < 0.1 ) {
				$area = $area/(1/((0.5+(1/$pi)+((abs(0.5-$round)/0.5)*(0.5-(1/$pi)))))**2*$circ);
			}
			elsif (0.1 <= $circ and $circ < 0.8) {
				$area = $area/((0.5+(1/$pi)+((abs(0.5-$round)/0.5)*(0.5-(1/$pi))))**2*$circ);
			}
			else {
				$area = $area/$circ;
			}
			
			if ($reverse == 1 and 40 < $angle and $angle < 45) {
				my $radius_distance = radius($area)-$minor;
				$x = $x+($radius_distance*cos($angle*3.14159265/180));
				$y = $y+($radius_distance*sin($angle*3.14159265/180));
			}
			elsif ($reverse == 0 and 40 < $angle and $angle < 45) {
				my $radius_distance = radius($area)-$minor;
				$x = $x-($radius_distance*cos($angle*3.14159265/180));
				$y = $y-($radius_distance*sin($angle*3.14159265/180));
			}
		}
		
		#get everything if file is cont
		if ($type =~ m/^cont$/is) {
			my %hash = ('area'=>$area,'x'=> $x,'y'=> $y);
			push(@coor, \%hash);
		}
		
		#ignore noise if file is not cont(bubble < 500k area)
		elsif ($small_area == 0 and $area > 500000) {
			my %hash = ('area'=>$area,'x'=> $x,'y'=> $y);
			push(@coor, \%hash);
		}
		elsif ($small_area == 1) {
			my %hash = ('area'=>$area,'x'=> $x,'y'=> $y);
			push(@coor, \%hash);
		}
	}
	if ((@coor) == 0) {
	}
	return @coor;
}

#2
sub stats {
	my (@area, @x, @y);
	my (@coors) = (@_);
	foreach my $hash(@coors) {
		push (@area, ${$hash}{area});
		push (@x, ${$hash}{x});
		push (@y, ${$hash}{y});
	}

	#find resolution
	@area = sort {$b <=> $a}@area;
	@x    = sort {$b <=> $a}@x;
	@y    = sort {$b <=> $a}@y;

	#find distribution of area
	my (@result, %count, $total);
	for (my $i=0; $i<@area; $i++) {
		if (exists $count{$area[$i]}) {
			$count{$area[$i]}++;
		}
		else {
			$count{$area[$i]} = 1;
		}
		$total++;
	}
	foreach my $key (keys %count) {
		push (@result, $key, $count{$key}, $count{$key}/$total);
	}

	#nucleated cells analysis
	my $nucleated = nuc_cell(\@cres, \@cont);

	#print area in this output file
	print $statout "\n>STATISTICS<\n";
	print $nuclout "average_area_of_contamination_of_$path\t$nucleated\n";
	
	print $statout "AREA\tAMOUNT\tPERCENTAGE\n";
	for (my $j=0; $j<@result; $j+=3) {
		printf $statout "%.4f\t%d\t%.4f percent\n", $result[$j], $result[$j+1], $result[$j+2]*100;
	}	
		
	my $res = $x[0]/radius($area[0]);
	return ($x[0]/$res,$y[0]/$res);
}

#3: links each crescent with the appropriate globule, which is chosen by closest distance
sub links {
	
	#read
	my ($xc, $yc, $area_c, @bin) = (${$_[0]}, ${$_[1]}, ${$_[2]}, @{$_[3]});
	my @bin2;
	#calculate each distance
	foreach my $g(@bin) {
		if (defined(${$g}{x})) {
			my $distance = distance($xc, $yc, ${$g}{x}, ${$g}{y}) - radius($area_c) - radius(${$g}{area});
			push(@bin2, [$distance, $g]);
		}
	}
	
	@bin2 = sort {$a->[0] <=> $b->[0]} @bin2; #sort by smallest distance. 
	my @glob_query;
	my $radius_c = radius($area_c);
	for (my $i = 1; $i<10; $i++) {
		last if defined ($glob_query[0]);
		my $radius_c_limit = $i*0.5*$radius_c;
		for my $j(0..@bin2-1) {
			if ($bin2[$j][0]<$radius_c_limit) { #$bin2[$j][0] is the distance between globule and crescent.
				push (@glob_query, [$bin2[$j][0], \$bin2[$j][1]]); #bin2[$j][1] is the data of the globule that contains hash of area, x, and y.
			}
		}
		
	}
	
	my @cres_data;
	if (not defined($glob_query[0])) {
		push (@amb_cres, [{x => $xc, y => $yc, area => $area_c}]);
	}
	
	else {
		push(@cres_data, [{x => $xc, y => $yc, area => $area_c}], \@glob_query);
		my $result = equalizer(@cres_data);
		return ($result) if defined($result);
	}

}

#4
sub radius {
	my $area = $_[0];
	print ($area, $pi) if $area == 0;
	my $radius = sqrt($area/$pi);
	return ($radius);
}

#5
sub distance {
	my ($xc, $yc, $xg, $yg) = @_;
	my $distance = sqrt(($xc-$xg)**2+($yc-$yg)**2);
	return ($distance);
}

#6
sub equalizer {
	my @cres_data2 = @_; #crescent data, glob data
	my ($area_c, $xc, $yc) = (${$cres_data2[0][0]}{area}, ${$cres_data2[0][0]}{x}, ${$cres_data2[0][0]}{y});
	
	my @glob_query = $cres_data2[1];

	#defining area
	my @area;
	foreach my $i (0..@{$glob_query[0]}-1) {
		push (@area, ${${$glob_query[0][$i][1]}}{area});
	}
	
	#A) take biggest globule 
	#(this might look like a manual size-sorting, which can simply be done by sort (), but there are actually more conditions that's going to be added later)
	my $glob_num = 0;
	my $checker = 0;
	for (my $j = 0; $j<@area; $j++) {
		if ($area[$j] > (0.25*$area_c)) { #condition 1: glob area is at least bigger than 25% of crescent, it won't be called ambiguous
			$checker = 1;
			if ($area[$j] > $area[$glob_num]) { #condition 2: glob area is bigger than (previous) biggest glob area
				$glob_num = $j;			
			}
		}
	}
	
	my $used;
	my $area_g = ${${$glob_query[0][$glob_num][1]}}{area};
	my $xg = ${${$glob_query[0][$glob_num][1]}}{x};
	my $yg = ${${$glob_query[0][$glob_num][1]}}{y};
	if ($checker == 1) {
		printf $linkout "$area_c\t$xc\t$yc\t$area_g\t$xg\t$yg\n" if (defined($area_g) and defined($xg) and defined($yg));
		$used = $xg;
		return ($used);
	}
	else {
		push (@amb_cres, [{x => $xc, y => $yc, area => $area_c}]);
	}
}

#7 mapclean
sub mapclean {
	my @map = @_;
	for (my $i=0; $i<@map; $i++) {
		for (my $j=0; $j<@map; $j++) {
			if (not defined $map[$i][$j]) {
				$map[$i][$j] = [];
			}
		}
	}
	return @map;
}


#<DEBUG> print coors $out to check if the program reads input file correctly
sub debug_coor {
	my @input = @_;

	my @glob2 = @{$input[0]};
	my @cres2 = @{$input[1]};
	my ($glob_input, $cres_input) = ($opt{a}, $opt{b});
	
	print $globout "Globules\n\#Glob_area\tGlob_x\tGlob_y\n";
	foreach my $g(@glob2){
		print $globout "${$g}{area}\t${$g}{x}\t${$g}{y}\n";
	}
	print $cresout "\nCrescents\n\#Cres_area\tCres_x\tCres_y\n";
	foreach my $c(@cres2) {
		print $cresout "${$c}{area}\t${$c}{x}\t${$c}{y}\n";
	}
}

sub nuc_cell {
	my @input = @_;
	my @cres2 = @{$input[0]};
	my @red_tot = @{$input[1]};
	my ($area_c, $area_tot) = 0;
	foreach my $c(@cres2) {
		$area_c += ${$c}{area};
	}
	foreach my $red(@red_tot) {
		$area_tot += ${$red}{area};
	}
	my $nuc_cell = 1-($area_c/$area_tot);
	return($nuc_cell);
		
}
	
	
sub printer {
	my $arg = $_[0];
	print "globulator.pl: printer: $arg\n";
}

sub checkfile {
        my ($filename) = @_;
        if (not -e $filename and not -s $filename) {
                die "WARNING: globulator.pl: $filename does not exist at bin directory!\n";
        }
}
