#!/usr/bin/perl
#globcalc
#calculate number of globules with crescent
#also return area size

use strict; use warnings; use Cwd; use Config;

die "usage: globcalc.pl <directory containing linked.txt>" unless @ARGV;
my $OS = $Config{archname};
my $slashes = $OS =~ m/MsWin/i ? "\\" : "\/";
my $dir = $ARGV[0] . $slashes;

my @dir = <$dir*>;
my ($dir_res, $dirname) = $dir =~ m/(.*\\result)\\(.*)\\$/i if ($OS =~ m/MSWin/i);
($dir_res, $dirname) = $dir =~ m/(.*\/result)\/(.*)\/$/i if ($OS !~ m/MsWin/i);
my (@nuc_human, @nuc_monkey);

open (my $summary, ">$dir_res\/$dirname\_summary.txt") or die "can't create $dir_res\/$dirname\_summary.txt (permission issue?)\n";
print "summarizer.pl: summary of results : $dir_res\/$dirname\_summary.txt (only relevant to human/monkey comparison, otherwise it will give blank page)\n";
print $summary "SUMMARY OF FILE AT $dir\n";
foreach my $fh (@dir) {
	if ($fh =~ m/NUCLEATED_\d{4}_.*WM.*.txt$/i or $fh =~ m/NUCLEATED_\d{4}d.*WM.*.txt$/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		while (my $line = <$in>) {
			my @arr = split("\t", $line);
			$arr[1] *= 100;
			push (@nuc_human, $arr[1]);
		}
	}
	elsif ($fh =~ m/NUCLEATED_\d{5}.*WM.txt/i and $fh !~ m/NUCLEATED_\d{5}.*10min.*WM.txt/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		while (my $line = <$in>) {
			my @arr = split("\t", $line);
			$arr[1] *= 100;	
			push (@nuc_monkey, $arr[1]);
		}
	}
}

if (defined($nuc_human[0])) {
	@nuc_human = sort {$a <=> $b} (@nuc_human);
	my $low = $nuc_human[0];
	@nuc_human = sort {$b <=> $a} (@nuc_human);
	my $high = $nuc_human[0];
	my $ave = averages(@nuc_human);
	printf $summary "human nucleated cell contamination\t%.3f%%\t(%.3f%% to %.3f%%)\n", $ave, $low, $high;
}

if (defined($nuc_monkey[0])) {
	@nuc_monkey = sort {$a <=> $b} (@nuc_monkey);
	my $low = $nuc_monkey[0];
	@nuc_monkey = sort {$b <=> $a} (@nuc_monkey);
	my $high = $nuc_monkey[0];
	my $ave = averages(@nuc_monkey);
	printf $summary "\nmonkey nucleated cell contamination\t%.3f%%\t(%.3f%% to %.3f%%)\n", $ave, $low, $high;
}


my (@link_human, @link_monkey);
my ($count_human_file, $count_monkey_file) = (0,0);

foreach my $fh (@dir) {
	if ($fh =~ m/LINK_\d{4}_.*WM.*.txt$/i or $fh =~ m/LINK_\d{4}d.*WM.*.txt$/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		$count_human_file++;
		while (my $line = <$in>) {
			if ($line =~ m/^\d/i) {
				my @arr = split("\t", $line);
				push (@link_human, $arr[3]);
			}
		}
	}
	elsif ($fh =~ m/LINK_\d{5}.*WM.txt/i and $fh !~ m/LINK_\d{5}.*10min.*WM.txt/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		$count_monkey_file++;
		while (my $line = <$in>) {
			if ($line =~ m/^\d/i) {
				my @arr = split("\t", $line);
				push (@link_monkey, $arr[3]);
			}
		}
	}
}

#print "summarizer.pl: Number of Human file: $count_human_file\nNumber of Monkey file: $count_monkey_file\n";
my ($ave_human, $ave_monkey, $count_human, $count_monkey);
if (defined($link_human[0])) {
	@link_human = sort {$a <=> $b} (@link_human);
	my $low = $link_human[0];
	@link_human = sort {$b <=> $a} (@link_human);
	my $high = $link_human[0];
	$ave_human = averages(@link_human);
	$count_human = @link_human;
	printf $summary "\naverage area of human globule with crescent\t%.3f (%.3f - %.3f)\n", $ave_human, $low, $high;
}

if (defined($link_monkey[0])) {
	@link_monkey = sort {$a <=> $b} (@link_monkey);
	my $low = $link_monkey[0];
	@link_monkey = sort {$b <=> $a} (@link_monkey);
	my $high = $link_monkey[0];
	$ave_monkey = averages(@link_monkey);
	$count_monkey = @link_monkey;
	printf $summary "\naverage area of monkey globule with crescent\t%.3f (%.3f - %.3f)\n", $ave_monkey, $low, $high;
}

if (defined($link_monkey[0]) and defined($link_human[0])) {
	printf $summary "\nsize HUMAN globule with crescent relative to MONKEY\t %.3f%%\n", $ave_human*100/$ave_monkey;
}

my (@glob_human, @glob_monkey);

foreach my $fh (@dir) {
	if ($fh =~ m/GLOB_\d{4}_.*WM.*.txt$/i or $fh =~ m/GLOB_\d{4}d.*WM.*.txt$/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		while (my $line = <$in>) {
			if ($line =~ m/^\d/i) {
				my @arr = split("\t", $line);
				push (@glob_human, $arr[0]);
			}
		}
	}
	elsif ($fh =~ m/GLOB_\d{5}.*WM.txt/i and $fh !~ m/GLOB_\d{5}.*10min.*WM.txt/i) {
		open (my $in, "$fh") or die "can't open $fh (permission issue?)\n";
		while (my $line = <$in>) {
			if ($line =~ m/^\d/i) {
				my @arr = split("\t", $line);
				push (@glob_monkey, $arr[0]);
			}
		}
	}
}
my ($ave_human_glob, $ave_monkey_glob, $count_globhuman, $count_globmonkey);
if (defined($glob_human[0])) {
	@glob_human = sort {$a <=> $b} (@glob_human);
	my $low = $glob_human[0];
	@glob_human = sort {$b <=> $a} (@glob_human);
	my $high = $glob_human[0];
	$ave_human_glob = averages(@glob_human);
	$count_globhuman = @glob_human;
	printf $summary "average area of human globule\t%.3f (%.3f - %.3f)\n", $ave_human_glob, $low, $high;
}

if (defined($glob_monkey[0])) {
	@glob_monkey = sort {$a <=> $b} (@glob_monkey);
	my $low = $glob_monkey[0];
	@glob_monkey = sort {$b <=> $a} (@glob_monkey);
	my $high = $glob_monkey[0];
	$ave_monkey_glob = averages(@glob_monkey);
	$count_globmonkey = @glob_monkey;
	printf $summary "\naverage area of monkey globule\t%.3f (%.3f - %.3f)\n", $ave_monkey_glob, $low, $high;
}

if (defined($glob_monkey[0]) and defined($glob_human[0])) {
	printf $summary "\nsize HUMAN globule relative to MONKEY\t%.3f%%
					  \nnumber of human globule\t%d
					  \nnumber of monkey globule\t%d
					  \nhuman globule with crescent is\t%.3f%%
					  \nmonkey globule with crescent is\t%.3f%%",
					  $ave_human_glob*100/$ave_monkey_glob,
					  $count_globhuman,
					  $count_globmonkey,
					  $count_human*100/$count_globhuman,
					  $count_monkey*100/$count_globmonkey;
}
close $summary;

sub averages {
	my @val = @_;
	my $total;
	my $count;
	foreach my $val (@val) {
		$total += $val;
		$count++;
	}
	return ($total/$count)
}
	
