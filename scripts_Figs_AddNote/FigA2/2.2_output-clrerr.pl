#!/usr/bin/env perl
# (1) output dt(pre) based on YSR23-errara
# (2) compare with YSR21-clrerr list
# 2024-04-15 zx
use strict;
use warnings;
use List::Util qw/min max/;
our $ysrc = "../YSR21_clcerr.csv";
our $ysrr = "../YSR23_relocation.csv";
our @phases = qw/Pn Pg P Pdiff PKPab PKPbc PKiKP PKPdf/;
our @tmarks = (0,1,2,3,4);
our $ulist= "List_multilocstas";
# YSR23-errata:
#   early event is the master; 
#   later event PDE-info is used to calculate dt(pre);
#   dO of later event is in opposite sign: neg==later
# [some stations with multiple locations in a year need to be checked by hand]
`awk '{if (\$1!="#") print \$0}' $ysrc|awk -F"," '{print \$2}'|sort -u|awk '{if (\$1~"_") print \$0}' > List_epairs`;
my @epairs = split /\n/, `awk '{if (\$1!="#") print \$0}' List_epairs`;
#@epairs = split /\n/, `awk '{print \$1}' List_uncomputed`;
foreach my $epair (@epairs) {
	my ($ee1,$ee2) = split /\_/, $epair;
	my ($dir) = glob "data_$epair.*";
	die "[ERROR] NO datadir for $epair!\n" if (!defined $dir);
	my $einfo = "Info_YSR23errata_$epair";
	# no sac down || no relocation info caled
	die "[ERROR] NO evninfo for $dir!\n" if (!-e "$dir/$einfo");
	chdir $dir;
	print STDERR "# $epair\n";

	# evn info
	my (undef,$evlo1,$evla1,$evdp1,$dO1) = split " ", `awk '{if (\$1=="${ee1}_catalog") print \$0}' $einfo`;
	my (undef,$evlo2,$evla2,$evdp2,$dO2) = split " ", `awk '{if (\$1=="$ee2") print \$0}' $einfo`;
	my (undef,$evlo2c,$evla2c,$evdp2c) = split " ", `awk '{if (\$1=="${ee2}_catalog") print \$0}' $einfo`;
	my $dh = $evdp2-$evdp1;
	my $dO = $dO2-$dO1;
#	print STDERR ">>> $dh,$dO\n";
	# sta info
	my @netstas = split /\n/, `awk '{if (\$1!="#") print \$0}' ../$ysrc|awk -F"," '{if (\$2=="$epair") print \$1}'`;
	my $nsta = scalar(@netstas);
	print STDERR "# [$nsta] stations: @netstas\n";
	my ($edir1,$edir2) = glob "Event_*";
	my $fout = "Info_dtAlign";
	open(OUT,"> $fout");
	print OUT "# sta | ph | gc2c | stlo1_stlo2 | stla1_stla2 | dtkp_dO | dtpre_dtpreYSR21 | dtresYre_dtresYSR21(clrerr) | d(dtres) (YSR21-re)\n";
	printf OUT "# [$nsta]  $epair >>> sta | ph(dtpre_min) | gc2c | ddtpre/ms | ddtres/ms\n";
	for(my $i=0;$i<@netstas;$i++) {
		my ($net,$sta) = split /\./, $netstas[$i];
		# YSR
		my ($dtresYSR,$dtobsYSR,$dtcicYSR,$dtpreYSR) = split " ",`awk -F"," '{if (\$1=="$netstas[$i]" && \$2=="$epair") print \$4,\$5,\$6,\$7}' ../$ysrc`;
		next if (!defined $dtpreYSR);
		print STDERR "--- $sta\n";
#		print STDERR ">>> &&&$dtresYSR===$dtobsYSR###$dtpreYSR===\n";
		# sta info
		my ($sac1,$sac2);
		($sac1) = glob "$edir1/$net.$sta.*.BHZ.sac" if (defined $edir1);
		($sac2) = glob "$edir2/$net.$sta.*.BHZ.sac" if (defined $edir2);
		my ($stlo1,$stla1,$stlo2,$stla2);
		if (defined $sac1 and defined $sac2) {
			(undef,$stlo1,$stla1) = split " ",`saclst stlo stla f $sac1`;
			(undef,$stlo2,$stla2) = split " ",`saclst stlo stla f $sac2`;
		} elsif (defined $sac1 and !defined $sac2) {
			(undef,$stlo1,$stla1) = split " ",`saclst stlo stla f $sac1`;
			$stlo2 = $stlo1;
			$stla2 = $stla1;
		} elsif (!defined $sac1 and defined $sac2) {
			(undef,$stlo2,$stla2) = split " ",`saclst stlo stla f $sac2`;
			$stlo1 = $stlo2;
			$stla1 = $stla2;
		} else {
			($stlo1,$stla1) = &FINDSTA($net,$sta,$ee1);
			($stlo2,$stla2) = &FINDSTA($net,$sta,$ee2);
		}
		die "[ERROR] NO sta.info!\n" if (!defined $stlo1 or !defined $stla1 or !defined $stlo2 or !defined $stla2);
#		print STDERR ">>> ==$stlo1&&$stlo2==\n";
#		print STDERR ">>> ==$stla1&&$stla2==\n";
		# gcarc
		my ($gc1)  = split " ", `distaz $stla1 $stlo1 $evla1 $evlo1`;
		my ($gc2)  = split " ", `distaz $stla2 $stlo2 $evla2 $evlo2`;
		my ($gc2c) = split " ", `distaz $stla2 $stlo2 $evla2c $evlo2c`;
#		print STDERR ">>> ===$gc2c===\n";
		my $dD = $gc2-$gc1;
		# dtdD & dtdh from ttimes_IASP91
		my $ddtpmin = 8000;
		my ($pphmin,$ddtrmin);
		# 5 P-wave phases are caled
		# the smallest d(dtpre) is saved
		# --- it not clearly shown which phase 
		#     was exactly used in YSR21
		for(my $j=0;$j<@phases;$j++) {
			next if ($gc2c<100 && $phases[$j] eq "PKiKP");
			my $ph = $phases[$j];
			my $mk = $tmarks[$j];
			my ($tm,$dtdD,$dtdh) = split /\|/, &dtdDdh($ph,$evdp2c,$gc2c);
			if ($tm==-1) {
#				print STDERR "[SKIP] NO info of $ph for $sta\n";
				next;
			}
			# dtpre
			my $dtdp  = $dD*$dtdD+$dh*$dtdh;
			my $dtpre = $dtdp+$dO;
			my $ddtp  = sprintf("%6.1f",($dtpreYSR-$dtpre)*1000);
			# dtres
			my $dtresYre = $dtobsYSR-$dtcicYSR-$dtpre; # dt(obs) as listed in YSR21
		 	# difference of dtres(recheck) & dtres(YSR21)
			my $ddtr= sprintf("%6.1f",($dtresYSR-$dtresYre)*1000);
			# output
			my $spg = sprintf("%-10s  %-6s  %8.2f",$sta,$ph,$gc2c);
			my $sts = sprintf("%8.4f_%-8.4f  %8.4f_%-8.4f",$stlo1,$stlo2,$stla1,$stla2);
			my $tkp = sprintf("%10.6f_%-10.6f",$dtdp,$dO);
			my $prs = sprintf("%10.6f_%-8.4f",$dtpre,$dtpreYSR);
			my $rrs = sprintf("%8.4f_%-8.4f",$dtresYre,$dtresYSR);
			printf OUT "$spg  $sts  $tkp  $prs  $rrs $ddtr\n";
			# the smallest d(dtpre) is saved of the station
			if (abs($ddtpmin)>abs($ddtp)) {
				$ddtpmin = $ddtp;
				print STDERR ">>> $sta: $ddtpmin, $ddtp  [$ph]\n";
				$pphmin  = $ph;
				$ddtrmin = $ddtr;
			}
		}
		# some stations of gc<100 are marked with PKiKP only in ttimes; ignore the station
		next if (!defined $ddtrmin);
		printf OUT "# >>> %-9s  %-5s  %7.2f  $ddtpmin  $ddtrmin\n",$sta,$pphmin,$gc2c;
	}
	close OUT;
	chdir "..";
}



#---------------------------------------------------------
# Subroutine for Calculating dt/dD & dt/dh using ttimes
# INPUT:  phase,  evdp, gcarc
# OUTPUT: dt/dD, dt/dh
# via ttimes (Buland & Chapman, 1983) (IASP91 based)
#---------------------------------------------------------
sub dtdDdh {
	my ($phase,$evdp,$gcarc) = @_;
	my $tttxt = "$phase\_$evdp\_$gcarc";
	my ($dtdD,$dtdh);
	`echo "all\n\n$evdp\n$gcarc\n-1\n-1\n" | ttimes >> $tttxt`;
	open(TTT,"<$tttxt"); my @ttlines = <TTT>; close TTT;
	`rm $tttxt`;
	for(my $i=0;$i<@ttlines;$i++) {
		if ($ttlines[$i] =~ "#") {
			my ($ph,$tm,$dtdD,$dtdh);
			for(my $ii=$i+2;$ii<@ttlines-2;$ii++) {
				chomp $ttlines[$ii];
				if ($ii==$i+2) {
					(undef,undef,$ph,$tm,undef,undef,$dtdD,$dtdh) = split " ", $ttlines[$ii];
				} else {
					(undef,$ph,$tm,undef,undef,$dtdD,$dtdh) = split " ", $ttlines[$ii];
				}
				# the very first arrival of the phase is used
				if ($ph eq $phase) {
					return "$tm|$dtdD|$dtdh";
					last;
				} # if the phase wanted
			} # for ttimes-output-lines
			last;
		} # locate the phases-line of ttimes
	} # for all lines-of-ttimes
	if (!defined($dtdD)) {
		return "-1|-1|-1";
	}
}

# find station of those undownloaded via SOD
sub FINDSTA{
	my ($net,$sta,$ee) = @_;
	my $yy = substr($ee,0,4);
	print STDERR "=====> FINDSTA: $sta [$ee]\n";
	my @lines = split /\n/, `find_stations -b $yy -e $yy -s $sta -n $net|awk '{if (\$4=="$net.$sta") print \$0}'|sort -u`;
	my ($stlo,$stla);
	if (scalar(@lines)==1) {
		($stlo,$stla) = split " ", $lines[0];
	} else {
#		die "[CHECK] NO/Multi stations found:\n@lines\n";
		($stlo,$stla) = split " ", `awk '{if (\$1=="$ee" && \$2=="$net.$sta") print \$3,\$4}' ../$ulist`;chomp $stla;
	}
	return $stlo,$stla;
}
