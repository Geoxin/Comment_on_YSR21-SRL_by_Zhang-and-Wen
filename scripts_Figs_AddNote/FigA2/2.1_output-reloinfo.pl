#!/usr/bin/env perl
# output relocation infos based on YSR23-errata
# 2024-04-11 zx
use strict;
use warnings;
use List::Util qw/min max/;
our $ysrc = "../YSR21_clcerr.csv";
our $ysrr = "../YSR23_relocation.csv";
# YSR23-errata:
#   early event is the master; 
#   later event PDE-info is used to calculate dt(pre)
our @ddirs = glob "data_*_*.*";
foreach my $dir (@ddirs) {
	my ($enames,$snum) = split /\./, $dir;
	my (undef,$ee1,$ee2) = split /\_/, $enames;
	my $epair= "$ee1\_$ee2";
	# relo-info
	my ($nr) = split /\n/, `awk -F"," '{if (\$1=="$epair") print NR}' $ysrr`;
	die "[ERROR] NO evn-info for $epair!\n" if (!defined $nr);
	print STDERR "--- [$nr] $epair\n";
	my (undef,$dX2,$az2,$dh2,$dO2,$date1,$time1,$la1,$lo1,$dep1,$mag1) = split ",", `awk -F"," '{if (NR==$nr) print \$0}' $ysrr`;
	my (undef,undef,undef,undef,undef,$date2,$time2,$la2,$lo2,$dep2,$mag2) = split ",", `awk -F"," '{if (NR==$nr+1) print \$0}' $ysrr`;
	my $dX2km = $dX2*0.001;
	my $dh2km = $dh2*0.001;
	my ($evla1,$evlo1,$evdp1,$dO1) = ($la1,$lo1,$dep1,0.00);
	my ($evla2,$evlo2);
	if ($dX2==0) {
		$evla2 = $evla1;
		$evlo2 = $evlo1;
	} else {
		($evlo2,$evla2) = split " ",`gmt project -C$evlo1/$evla1 -A$az2 -L0/$dX2km -Q -G$dX2km|awk '{if (\$3==$dX2km) print \$1,\$2}'`;chomp $evlo2;
	}
	my $evdp2 = $evdp1+$dh2km;
	$dO2 = -$dO2; # special definiation in YSR23
	my $fevn = "$dir/Info_YSR23errata_$epair";
	open(EOUT,"> $fevn");
	print EOUT "# ID | evlo | evla | evdp/km | Origin\n";
	print EOUT "${ee1}_catalog  $evlo1  $evla1  $evdp1  $dO1\n";
	print EOUT "$ee2          $evlo2  $evla2  $evdp2  $dO2\n";
	print EOUT "${ee2}_catalog  $lo2  $la2  $dep2\n";
	close EOUT;
}
