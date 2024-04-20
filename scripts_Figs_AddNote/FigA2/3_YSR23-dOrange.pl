#!/usr/bin/env perl
# RMS based on YSR23's relocations
# 2024-04-15 zx
use strict;
use warnings;
use List::Util qw/min max/;
our $ysrc = "../YSR21_clcerr.csv";
our $ysrr = "../YSR23_relocation.csv";

our ($omax,$ddo) = (0.5,0.0001);

&RMSOUT("D1_1995-2003","1995318_2003183");
&RMSOUT("D2_1993-2004","1993309_2004130");

sub RMSOUT {
	my ($ddir,$ee) = @_;
	my ($id,$enames) = split /\_/, $ddir;
	my $fout = "List_RMS_YSR23.$id";
	open(OUT,"> $fout");
	print OUT "# RMS based on YSR23-errata event location & YSR21 dt(obs)\n";
	print OUT "# dO (s) | RMS\n";
	print OUT ">\n";
	my $ainfo = "../Align-YSR23errata.$id";
	my ($YdO) = split /\n/, `awk -F"," '{if (\$1=="$ee") print \$5}' $ysrr`; $YdO = -$YdO; # special definition in YSR23-errata
	my @lines = split /\n/, `awk '{if (\$1!="#" && \$2=="P") print \$0}' $ainfo`;
	my @okps;
	for(my $i=0;$i<@lines;$i++) {
		my ($sta,$ph,$stlo,$stla,$dtkp,$dOysr,$dtpre,$dtres,$Ydtres) = split " ", $lines[$i];
		my $okp = $dOysr+$dtres*0.001; # =[dt(res)+dO]=[dt(obs)-tkp]
		$okp = $dOysr+$Ydtres*0.001 if ($Ydtres ne "------");
#		print STDERR "# $sta [$ph] $dOysr ($YdO) $okp\n";
		push @okps,$okp;
	}
	my $nnn = scalar(@okps);
	print STDERR "# $nnn\n";
	my $mindO;
	my $minRMS=800000;
	for(my $dO=$YdO-$omax;$dO<=$YdO+$omax;$dO+=$ddo) {
		my $rms = 0;
		for(my $i=0;$i<@okps;$i++) {
			$rms = $rms + ($okps[$i]-$dO)*($okps[$i]-$dO);
		}
		$rms = sqrt($rms/$nnn)*1000;
		if ($minRMS>$rms) {
			$minRMS=$rms;
			$mindO = $dO;
		}
		printf OUT "%6.3f  %10.3f\n",($dO-$YdO)*1000,$rms;
	}
	printf OUT "# >>> %6.3f $minRMS\n",($mindO-$YdO)*1000;
	close OUT;
}
