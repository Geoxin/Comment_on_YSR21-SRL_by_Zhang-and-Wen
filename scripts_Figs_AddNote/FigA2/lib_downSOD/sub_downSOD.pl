#!/usr/bin/env perl
# cycle: downSOD
use strict;
use warnings;
my @dirs = split /\n/, `cat List_todown`;
for(my $i=IIII;$i<@dirs;$i=$i+NNNN) {
	print STDERR "# $dirs[$i]\n";
	chdir $dirs[$i];
	`sod -f download.xml`;
	`mv seismograms/Event_* .`;
	`rm -r Sod* *log seismograms`;
	chdir "..";
}
