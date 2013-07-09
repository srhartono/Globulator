#!/usr/bin/perl
#
# draw.pl
# This script draw image based on imageJ result file GLOB_.txt, CRES_.txt, and LINK_.txt
# by Stella Hartono
####################

my ($result) = @ARGV;
die "Usage: $0 <result folder file>\n" unless @ARGV == 1;

my @globfh = <$result\/GLOB_*.txt>;
my @cresfh = <$result\/CRES_*.txt>;
my @linkfh = <$result\/LINK_*.txt>;

my @command;
my @results;
foreach my $globfh (@globfh) {
	push (@command, "R --vanilla --no-save --args $globfh $globfh.pdf < bin/draw_glob.R");
	push (@results, "$globfh.pdf");
}
foreach my $cresfh (@cresfh) {
	push (@command, "R --vanilla --no-save --args $cresfh $cresfh.pdf < bin/draw_cres.R");
	push (@results, "$cresfh.pdf");
}
foreach my $linkfh (@linkfh) {
	push (@command, "R --vanilla --no-save --args $linkfh $linkfh.pdf < bin/draw_link.R");
	push (@results, "$linkfh.pdf");
}

foreach my $command (@command) {
	print "draw.pl: Running $command\n";
	system($command) == 0 or print "draw.pl: Failed to run $command: $!\n";
}

print "draw.pl: Result pdf files:\n";
my $count = 0;
foreach my $result (sort @results) {
	$count++;
	print "$count\.\t$result\n";
}
