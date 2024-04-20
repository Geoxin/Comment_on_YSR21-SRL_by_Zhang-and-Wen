#!/usr/bin/env perl
# OBN & AAK alignment based on dt(obs) in two studies
# 2024-04-15 zx
use strict;
use warnings;
use List::Util qw/sum min max/;
`gmt set FONT_ANNOT_PRIMARY 10p`;
`gmt set FONT_TITLE 16p,1`;
`gmt set MAP_TITLE_OFFSET 0p`;
`gmt set FONT_LABEL 12p`;
`gmt set MAP_FRAME_PEN 0.8p`;
our $cfile = "YSR21_clcerr.csv";
our $rfile = "YSR23_relocation.csv";
our $J = "-JX10c/4c";
our $M = "-M-2c";
our $PS = "FA3.ps";
our ($clr1,$clr2) = qw/red blue/;

# check dt(obs) of OBN of D2
my $sname = "II.OBN";
my $ename = "1993309_2004130";
# origin time correction in YSR23-errata-TableS1
our ($YdO) = split /\n/, `awk -F"," '{if (\$1~"$ename") print \$5}' $rfile`;
$YdO = -$YdO; # special definiation in YSR23
# dt(obs) in YSR21-TableS2
our ($Ydtobs) = split /\n/, `awk -F"," '{if (\$1~"$sname" && \$2=="$ename") print \$5-\$6}' $cfile`;
$Ydtobs = sprintf("%.3f",$Ydtobs);
# dt(obs) measured in this comment
our ($Zdtobs) = (2.15377+0.002835+8*0.001); # dtpre+dtres; see Table1&2 of the comment
$Zdtobs = sprintf("%.3f",-$Zdtobs);
# Unrecoverable dt(obs) of YSR21
our ($xmin,$xmax,$ymin,$ymax) = (742,748,-1.2,1.1);
our $R = "-R$xmin/$xmax/$ymin/$ymax";
`gmt psxy $J $R -T -K > $PS`;
`gmt psxy $J $R -X-1c -Y10c -K -O -T >> $PS`;
our $sac1 = "D2.1993.II.OBN.BHZ.sac.bp";
our $sac2 = "D2.2004.II.OBN.BHZ.sac.bp";
our $dt = $Ydtobs;
&PLTSHIFT;
`echo "$xmin $ymax (a)"|gmt pstext $J $R -F+f14p,1+jLT -Dj0.2c/0.2c -K -O -N >> $PS`;
`echo "$xmax $ymin with a shift of dt measurement in YSR21 of $dt s"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.6c -K -O -N >> $PS`;
`echo "$xmax $ymin [see Table S2 in YSR21]"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.2c -K -O -N >> $PS`;
`gmt psxy $J $R -X10.5c -K -O -T >> $PS`;
$dt = $Zdtobs;
&PLTSHIFT;
`echo "$xmin $ymax (b)"|gmt pstext $J $R -F+f14p,1+jLT -Dj0.2c/0.2c -K -O -N >> $PS`;
`echo "$xmax $ymin with a shift of dt measurement in ZW23 of $dt s"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.6c -K -O -N >> $PS`;
my $ddtobs = sprintf("%d",($Ydtobs-$Zdtobs)*1000);
`echo "$xmax $ymin [$dt s (ZW23) = $Ydtobs s (YSR21) + $ddtobs ms]"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.2c -K -O -N >> $PS`;
`gmt psxy $J $R -X-10.5c -K -O -T >> $PS`;
`echo "0.5 4 Unrecoverable dt measurement in YSR21-TableS2: OBN of D2_1993-2004"|gmt pstext -JX20.5c/5c -R0/1/0/5 -F+f14p,1+jCB -Dj-1c/0.5c -K -O -N >> $PS`;

# check dt(obs) of AAK of D1
$sname = "KN.AAK";
$ename = "1995318_2003183";
# origin time correction in YSR23-errata-TableS1
($YdO) = split /\n/, `awk -F"," '{if (\$1~"$ename") print \$5}' $rfile`;
$YdO = -$YdO; # special definiation in YSR23
# dt(obs) in YSR21-TableS2
($Ydtobs) = split /\n/, `awk -F"," '{if (\$1~"$sname" && \$2=="$ename") print \$5-\$6}' $cfile`;
$Ydtobs = sprintf("%.3f",$Ydtobs);
# dt(obs) measured in this comment
($Zdtobs) = (1.922702+0.019840+47*0.001); # dtpre+dtres; see Table1&2 of the comment
$Zdtobs = sprintf("%.3f",-$Zdtobs);
# Unrecoverable dt(obs) of YSR21
($xmin,$xmax,$ymin,$ymax) = (545,551,-1.2,1.1);
$R = "-R$xmin/$xmax/$ymin/$ymax";
`gmt psxy $J $R -Y-6.5c -K -O -T >> $PS`;
$sac1 = "D1.1995.KN.AAK.BHZ.sac.bp";
$sac2 = "D1.2003.KN.AAK.BHZ.sac.bp";
$dt = $Ydtobs;
&PLTSHIFT;
`echo "$xmin $ymax (c)"|gmt pstext $J $R -F+f14p,1+jLT -Dj0.2c/0.2c -K -O -N >> $PS`;
`echo "$xmax $ymin with a shift of dt measurement in YSR21 of $dt s"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.6c -K -O -N >> $PS`;
`echo "$xmax $ymin [see Table S2 in YSR21]"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.2c -K -O -N >> $PS`;
`gmt psxy $J $R -X10.5c -K -O -T >> $PS`;
$dt = $Zdtobs;
&PLTSHIFT;
`echo "$xmin $ymax (d)"|gmt pstext $J $R -F+f14p,1+jLT -Dj0.2c/0.2c -K -O -N >> $PS`;
`echo "$xmax $ymin with a shift of dt measurement in ZW23 of $dt s"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.6c -K -O -N >> $PS`;
$ddtobs = sprintf("%d",($Ydtobs-$Zdtobs)*1000);
`echo "$xmax $ymin [$dt s (ZW23) = $Ydtobs s (YSR21)]"|gmt pstext $J $R -F+f10p+jBR -Dj0.2c/0.2c -K -O -N >> $PS`;
`gmt psxy $J $R -X-10.5c -K -O -T >> $PS`;
`echo "0.5 4 Recoverable dt measurement in YSR21-TableS2: AAK of D1_1995-2003"|gmt pstext -JX20.5c/5c -R0/1/0/5 -F+f14p,1+jCB -Dj-1c/0.5c -K -O -N >> $PS`;

`gmt psxy $J $R -T -O >> $PS`;
`rm gmt.*`;

sub PLTSHIFT {
	# copied from script for Fig.5d of this comment
	`gmt pssac $J $R $sac1 $M -W1p,$clr1  -C -T+s$dt -K -O >> $PS`;
	`gmt pssac $J $R $sac2 $M -W1p,$clr2 -C -K -O >> $PS`;
	`gmt psbasemap $J $R -Bxa2f1+l'Time (s)' -By -BwenS -K -O >> $PS`;
	open(PSLEGEND,"|gmt pslegend $J $R -DjTR+w2.8c+o0c/-0.01c+l1.3 -C0.2c/0.2c -K -O >> $PS");
	print PSLEGEND "S 0.3c - 0.6c - 1p,$clr1 0.8c 19931105\n";
	print PSLEGEND "S 0.3c - 0.6c - 1p,$clr2 0.8c 20040509\n";
	close PSLEGEND;
}
