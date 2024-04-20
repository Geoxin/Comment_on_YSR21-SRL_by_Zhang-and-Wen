#!/usr/bin/env perl
# Check re-computed list: missed or reproduced
# 2024-04-16 zx
use strict;
use warnings;
use List::Util qw/min max/;
our $ysrc = "YSR21_clcerr.csv";
our $ysrr = "YSR23_relocation.csv";
our $err  = 1; # ms
my @epairs = split /\n/,`awk '{if (\$1!="#") print \$0}' $ysrc|awk -F"," '{print \$2}'|sort -u|awk '{if (\$1~"_") print \$0}'`;
my $fuout = "List_uncomputed";
my $frout = "List_reproducibility";
open(UOUT,"> $fuout");
open(ROUT,"> $frout");
print ROUT "# epair | total | reproduced | unreprod.\n";
foreach my $epair (@epairs) {
	my @netstas = split /\n/, `awk '{if (\$1!="#") print \$0}' $ysrc|awk -F"," '{if (\$2=="$epair") print \$1}'`;
	my $nsta = scalar(@netstas);
	my @calstas = split /\n/, `awk '{if (\$2==">>>") print \$3}' data_$epair.*/Info_dtAlign`;
	my $ncomp = scalar(@calstas);
	printf UOUT "$epair  [$nsta]  [$ncomp]\n" if ($ncomp != $nsta);
	# reproducibility
	my ($nrep) = split /\n/, `awk '{if (\$2==">>>" && \$7<=$err && \$7>=-$err) print \$3}' data_$epair.*/Info_dtAlign|wc -l`;
	my ($nunr) = split /\n/, `awk '{if (\$2==">>>" && (\$7>$err || \$7<-$err))	print \$3}' data_$epair.*/Info_dtAlign|wc -l`;
	printf ROUT "%-20s  %3d  %3d  %3d\n",$epair,$nsta,$nrep,$nunr;
}
close UOUT;
close ROUT;
