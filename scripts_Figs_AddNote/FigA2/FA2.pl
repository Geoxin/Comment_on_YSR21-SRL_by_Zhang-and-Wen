#!/usr/bin/env perl
# (1) all clcerr based on YSR21-TableS2 & YSR23-errata-TableS1
# (2) dO vs. clcerr
# 2024-04-15 zx
use strict;
use warnings;
use List::Util qw/min max/;
`gmt set FONT_ANNOT_PRIMARY 10p`;
`gmt set FONT_TITLE 16p,1`;
`gmt set MAP_TITLE_OFFSET 0p`;
`gmt set FONT_LABEL 11p`;
`gmt set MAP_FRAME_PEN 0.8p`;

# YSR infos
our $ysrc = "YSR21_clcerr.csv";
our $ysrr = "YSR23_relocation.csv";
# d(dtres)= YSR-recheck
our $flist= "List_dtAlign_all";
`cat data_*/Info_dtAlign|grep ">>>" > $flist`;
our $elist= "List_eventpairs";
`awk '{if (\$4==">>>") print \$2,\$3}' $flist > $elist`;
# a random example
our @egees = qw/1991262_2011260 2001310_2014141 2007087_2016287/;

# panel (a)
# number
# --- event pair
my ($nx) = split /\n/, `cat $elist|wc -l`;
# --- case of clcerr
my ($ns) = split /\n/, `awk '{if (\$2==">>>") print \$3}' $flist|wc -l`;
# --- case of outlier
our $err = 1; # precision is to 1 ms as shown in comment
my ($no) = split /\n/, `awk '{if (\$2==">>>" && (\$7>$err || \$7<-$err)) print \$3}' $flist|wc -l`;
print STDERR "# totally $nx event pairs\n";
printf STDERR "# $no outliers among $ns cases: %.2f percent\n",$no/$ns*100;
our @lines = split /\n/, `cat $flist`;
# AAK for D1 & OBN for D2 & example doublet
my ($px1,$py1) = &FIND("1995318_2003183","AAK");
my ($px2,$py2) = &FIND("1993309_2004130","OBN");
my ($px3r,$py3r)= &FIND("$egees[0]","AQU");
my ($px3u,$py3u)= &FIND("$egees[0]","TSK");
my ($px4r,$py4r)= &FIND("$egees[1]","MAKZ");
my ($px4u,$py4u)= &FIND("$egees[1]","ANMO");
my ($px5r,$py5r)= &FIND("$egees[2]","CWC");
my ($px5u,$py5u)= &FIND("$egees[2]","COLD");
# colors
my ($clr1,$clr2) = ("magenta","brown");
my ($clrr,$clru) = ("black","blue");
my $clry = "darkorange";
my $clrm = "deepskyblue";
my $clre = "forestgreen";
my $S = "0.2c";
my $W = "1p";
# plot
my ($xmin,$xmax) = (0,$nx+1);
my ($ymin,$ymax) = (-30,30);
my $J  = "-JX25c/8c";
my $R  = "-R$xmin/$xmax/$ymin/$ymax";
print STDERR "# $R\n";
my $PS = "FA2.ps";
`gmt psxy $J $R -T -K > $PS`;
`gmt psxy $J $R -Y8c -T -K -O >> $PS`;
# error bar
`echo ">\n$xmin -$err\n$xmax -$err\n$xmax $err\n$xmin $err"|gmt psxy $J $R -Ggray -L -K -O >> $PS`;
# legend
open(PSLEGEND,"|gmt pslegend $J $R -DjTR+w3c+o0c/0c+l1.5 -C0c/0c -F+gwhite+p0.6p -K -O >> $PS");
print PSLEGEND "S 0.3c c $S - $W,$clrr 0.6c Reproduced\n";
print PSLEGEND "S 0.3c c $S - $W,$clru 0.6c Unreproduced\n";
close PSLEGEND;
# lines for D1 & D2 & exmp.
`echo ">\n$px1 $ymin\n$px1 $ymax"|gmt psxy $J $R -W0.4p,$clr1,- -K -O >> $PS`;
`echo "$px1 $ymin D1"|gmt pstext $J $R -F+f10p,$clr1+jLB -Dj0.1c/0.9c -K -O >> $PS`;
`echo ">\n$px2 $ymin\n$px2 $ymax"|gmt psxy $J $R -W0.4p,$clr2,- -K -O >> $PS`;
`echo "$px2 $ymin D2"|gmt pstext $J $R -F+f10p,$clr2+jLB -Dj0.1c/0.9c -K -O >> $PS`;
`echo ">\n$px3r $ymin\n$px3r $ymax"|gmt psxy $J $R -W0.4p,$clre,- -K -O >> $PS`;
`echo "$px3r $ymin $egees[0]"|gmt pstext $J $R -F+f10p,$clre+jLB -Dj0.06c/0.4c -K -O >> $PS`;
`echo ">\n$px4r $ymin\n$px4r $ymax"|gmt psxy $J $R -W0.4p,$clre,- -K -O >> $PS`;
`echo "$px4r $ymin $egees[1]"|gmt pstext $J $R -F+f10p,$clre+jLB -Dj0.1c/0.4c -K -O >> $PS`;
`echo ">\n$px5r $ymin\n$px5r $ymax"|gmt psxy $J $R -W0.4p,$clre,- -K -O >> $PS`;
`echo "$px5r $ymin $egees[2]"|gmt pstext $J $R -F+f10p,$clre+jLB -Dj0.1c/0.4c -K -O >> $PS`;
my $xx=0;
my $listu = "list.unrep";
my $listr = "list.repro";
open(OUTU,"> $listu");
open(OUTR,"> $listr");
foreach my $line (@lines) {
	my @elts = split " ", $line;
	if ($elts[3] eq ">>>") {
		($xx) = split /\n/, `awk '{if (\$2=="$elts[2]") print NR}' $elist`;
	} else {
		my $yy = $elts[6];
#		print STDERR "# $xx $yy\n";
		if ($yy<-$err or $yy>$err) {
			print OUTU "$xx $yy\n";
		} else {
			print OUTR "$xx $yy\n";
		}
	}
}
close OUTU;close OUTR;
`gmt psxy $J $R $listu -Sc$S -W$W,$clru -N -K -O >> $PS`;
`gmt psxy $J $R $listr -Sc$S -W$W,$clrr -N -K -O >> $PS`;
# circles: d(dtres) for AAK & OBN
`echo "$px1 $py1"|gmt psxy $J $R -Sc$S -W$W,$clr1 -N -K -O >> $PS`;
`echo "$px1 $py1 AAK"|gmt pstext $J $R -F+f10p,$clr1+jLT -Dj0.15c/0.2c -K -O >> $PS`;
`echo "$px2 $py2"|gmt psxy $J $R -Sc$S -W$W,$clr2 -N -K -O >> $PS`;
`echo "$px2 $py2 OBN"|gmt pstext $J $R -F+f10p,$clr2+jLT -Dj0.15c/0.3c -K -O >> $PS`;
`echo "$px3r $py3r"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`echo "$px3u $py3u"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`echo "$px4r $py4r"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`echo "$px4u $py4u"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`echo "$px5r $py5r"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`echo "$px5u $py5u"|gmt psxy $J $R -Sc$S -W$W,$clre -N -K -O >> $PS`;
`rm $listu $listr`;
`gmt psbasemap $J $R -Bxaf -Byaf -BSWen -K -O >> $PS`;
# title
`echo "$xmin 0 (YSR21 - calculated) (ms)"|gmt pstext $J $R -F+f12p+jTC+a90 -Dj0c/-1.4c -K -O -N >> $PS`;
`echo "$xmin 0 Difference of clock error"|gmt pstext $J $R -F+f12p+jTC+a90 -Dj0c/-1.9c -K -O -N >> $PS`;
`echo "$xmin $ymin ID"|gmt pstext $J $R -F+f12p,1+jTC -Dj0c/0.34c -Gwhite -K -O -N >> $PS`;
`echo '$xmin $ymax (a) (Un)reproducibility of YSR21 "clock errors" after the correction YSR23-errata'|gmt pstext $J $R -F+f14p,1+jLB -Dj-0.8c/0.5c -N -K -O >> $PS`;


# panels (b-d): dt(res) vs. dO
`gmt psxy $J $R -Y-7.3c -K -O -T >> $PS`;
`echo '$xmin $ymax (b-e) Examples of some irregularities in the correction YSR23-errata'|gmt pstext $J $R -F+f14p,1+jLT -Dj-1.3c/1.9c -N -K -O >> $PS`;
# panel (b): AAK of D1
my ($ee,$eee,$spesta) = ("1995318_2003183","D1_1995-2003","AAK");
# dO & clc in YSR23
my ($YdO) = split /\n/, `awk -F"," '{if (\$1=="$ee") print \$5}' $ysrr`; $YdO = -$YdO; # special definition in YSR23
my ($Ycl) = split /\n/, `awk -F"," '{if (\$1~".$spesta" && \$2=="$ee") print \$4}' $ysrc`;$Ycl*=1000; # s --> ms
# axis
$J = "-JX4.5c";
($xmin,$xmax) = (-40,40);
# RMS range
($ymin,$ymax) = (20,80);
$R = "-R$xmin/$xmax/$ymin/$ymax";
my $frms = "List_RMS_YSR23.D1";
`awk '{if (\$1!="#") print \$0}' $frms|gmt psxy $J $R -W1p,$clrm -K -O >> $PS`;
my $ymen = ($ymin+$ymax)*0.5;
`echo "$xmax $ymen RMS residual of D1 (ms)"|gmt pstext $J $R -F+f12p+jTC+a270 -Dj0c/-1.4c -K -O -N >> $PS`;
my ($mindO,$minRMS) = split " ",`awk '{if (\$1=="#" && \$2==">>>") print \$3,\$4}' $frms`;chomp $minRMS;
`echo "$mindO $minRMS"|gmt psxy $J $R -Sc0.2c -G$clrm -K -O >> $PS`;
`echo "$mindO $minRMS min(RMS)"|gmt pstext $J $R -F+f10p,1,$clrm+jCT -Dj0c/0.2c -K -O -N >> $PS`;
`gmt psbasemap $J $R -Byaf -BE -K -O >> $PS`;
# clock error
$ymin = $Ycl+$xmin;
$ymax = $Ycl+$xmax;
$R = "-R$xmin/$xmax/$ymin/$ymax";
print STDERR "# $R\n";
our $nnn = 2;
&PANELB($ee,$eee,"$spesta\_$clr1");$nnn++;
`gmt psbasemap $J $R -Bxaf -Byaf+l'"Clock error" (ms)' -BSWn -K -O >> $PS`;



# panel (c): example doublet
`gmt psxy $J $R -X7.8c -K -O -T >> $PS`;
($xmin,$xmax,$ymin) = (-40,40,30);
&PANELB("$egees[0]","$egees[0]","AQU_$clre","TSK_$clre");$nnn++;
`gmt psbasemap $J $R -Bxaf -Byaf+l'"Clock error" (ms)' -BSWen -K -O >> $PS`;
# panel (d): example doublet
`gmt psxy $J $R -X6.35c -K -O -T >> $PS`;
($xmin,$xmax,$ymin) = (-40,40,-90);
&PANELB("$egees[1]","$egees[1]","MAKZ_$clre","ANMO_$clre");$nnn++;
`gmt psbasemap $J $R -Bxaf -Byaf -BSWen -K -O >> $PS`;
# panel (e): example doublet
`gmt psxy $J $R -X6.35c -K -O -T >> $PS`;
($xmin,$xmax,$ymin) = (-40,40,0);
&PANELB("$egees[2]","$egees[2]","CWC_$clre","COLD_$clre");
`gmt psbasemap $J $R -Bxaf -Byaf -BSWen -K -O >> $PS`;

`gmt psxy $J $R -O -T >> $PS`;
`rm gmt.*`;


sub FIND {
	my ($ename,$sname) = @_;
	my ($px) = split /\n/, `awk '{if (\$2=="$ename") print NR}' $elist`;
	my $py= "none";
	($py) = split /\n/, `awk '{if (\$2==">>>" && \$3=="$sname") print \$7}' data_$ename.*/Info_dtAlign` if ($sname ne "none");
#	print STDERR "# $ename\_$sname:  ($px, $py)\n";
	return $px,$py;
}

sub PANELB {
	my ($ee,$eee,@spestas) = @_;
	print STDERR "# $ee\n";
	my ($YdO) = split /\n/, `awk -F"," '{if (\$1=="$ee") print \$5}' $ysrr`; $YdO = -$YdO; # special definition in YSR23
	# axis
=pod
	# --- set automatically
	my @ress = split /\n/, `awk '{if (\$1!="#") print \$8}' data_$ee.*/Info_dtAlign|awk -F"_" '{print \$2}'`; # only for station available at present in IRIS-SOD
	$ymin = int(min(@ress)*1000-10);
	$ymax = int(max(@ress)*1000+10);
	$xmin = $ymin;
	$xmax = $ymax;
	print STDERR "# [$YdO] [@ress]\n";
=cut
	# --- set by hand
	$ymax = $ymin+($xmax-$xmin);
	$R = "-R$xmin/$xmax/$ymin/$ymax";
	print STDERR "# $R\n";
	`echo ">\n0 $ymin\n0 $ymax"|gmt psxy $J $R -W0.9p,$clry,- -K -O >> $PS`;
	`echo "0 $ymin YSR23"|gmt pstext $J $R -F+f10p,1,$clry+jLB -Dj0.15c/0.2c -K -O >> $PS`;
	# OBN for D2 only
	for(my $i=0;$i<@spestas;$i++) {
		my ($spesta1,$spesta2) = split /\_/, $spestas[$i];
		&LINER($ee,$spesta1,$spesta2);
	}
	my $chr = chr($nnn+96);
	`echo "$xmin $ymax ($chr)"|gmt pstext -F+f14p,1+jLB -Dj-0.8c/0.4c $J $R -K -O -N >> $PS`;
	my $xmen = ($xmin+$xmax)*0.5;
	`echo "$xmen $ymax $eee"|gmt pstext -F+f12p+jCB -Dj0c/0.4c $J $R -K -O -N >> $PS`;
	`echo "$xmen $ymin Relative origin time correction (ms)"|gmt pstext $J $R -F+f11p+jCT -Dj0c/1c -K -O -N >> $PS`;
	my $ydop = sprintf("%.4f",$YdO);
	`echo "$xmen $ymin (w.r.t. $ydop s in YSR23-errata)"|gmt pstext $J $R -F+f11p+jCT -Dj0c/1.5c -K -O -N >> $PS`;
}

sub LINER {
	my ($ename,$sname,$clrrr) = @_;
	my ($ph,$ddres) = split " ", `awk '{if (\$2==">>>" && \$3=="$sname") print \$4,\$7}' data_$ename.*/Info_dtAlign`;chomp $ddres;
	last if (!defined $ph);
#	print STDERR ">>> $sname\n";
	my ($tkp,$dO) = split /\_/, `awk '{if (\$1=="$sname" && \$2=="$ph") print \$6}' data_$ename.*/Info_dtAlign`;chomp $dO;
	my ($Rclc,$Yclc) = split /\_/, `awk '{if (\$1=="$sname" && \$2=="$ph") print \$8}' data_$ename.*/Info_dtAlign`;chomp $Yclc;
#	print STDERR ">> $sname: $tkp, $dO, $Rclc, $Yclc\n";
	$Yclc*=1000; # s -> ms
#	print STDERR ">> $sname: YSR21=[$dO,$Yclc]\n";
	my ($dtobs) = split /\n/, `awk -F"," '{if (\$1~".$sname" && \$2=="$ename") print \$5-\$6}' $ysrc`;
	# clcerr = dt(obs)-dt(pre)
	my $xx1 = $xmin;
	my $xx2 = $xmax;
	my $yy1 = ($dtobs-$tkp-($xx1*0.001+$dO))*1000;
	my $yy2 = ($dtobs-$tkp-($xx2*0.001+$dO))*1000;
	my $xxO = ($dtobs-$tkp-$Yclc*0.001-$dO)*1000; # cross point (ms)
	my $clr = $clru;
	$clr = $clrrr if (defined $clrrr);
	`echo ">\n$xx1 $yy1\n$xx2 $yy2"|gmt psxy $J $R -W1p,$clr -t45 -K -O >> $PS`;
	`echo ">\n$xx1 $Yclc\n$xx2 $Yclc"|gmt psxy $J $R -W1p,$clr -t45 -K -O >> $PS`;
#	`echo ">\n$xxO $Yclc\n$xxO $ymin"|gmt psxy $J $R -W0.3p,- -K -O >> $PS`;
	`echo "$xxO $Yclc"|gmt psxy $J $R -Sc0.2c -G$clr -K -O >> $PS`;
#	`echo "$dO $Yclc"|gmt psxy $J $R -Sx0.3c -W1.3p,blue -K -O >> $PS`; # reported point of YSR21
	`echo "$xmin $Yclc $sname"|gmt pstext $J $R -F+f10p,1,$clr+jLB -Dj0.14c/0.14c -K -O >> $PS` if (defined $clrrr);
}
