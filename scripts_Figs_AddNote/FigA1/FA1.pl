#!/usr/bin/env perl
# (1) dt residual based on YSR23-errata
# (2) align based on YSR21-clcerr of OBN
# 2024-04-15 zx
use strict;
use warnings;
use List::Util qw/sum min max/;
`gmt set FONT_ANNOT_PRIMARY 10p`;
`gmt set FONT_TITLE 16p,1`;
`gmt set MAP_TITLE_OFFSET 0p`;
`gmt set FONT_LABEL 12p`;
`gmt set MAP_FRAME_PEN 0.8p`;
our $cfile = "../YSR21_clcerr.csv";
our $rfile = "../YSR23_relocation.csv";
our $PS = "FA1.ps";
our ($clrp,$clrn) = qw/blue red/;
our ($clr1,$clr2) = qw/red blue/;

# check dt(obs) of OBN of D2
my $sname = "II.OBN";
my $ename = "1993309_2004130";
# origin time correction in YSR23-errata-TableS1
our ($YdO) = split /\n/, `awk -F"," '{if (\$1~"$ename") print \$5}' $rfile`;
$YdO = -$YdO; # special definiation in YSR23
# dt(obs) in YSR21-TableS2
our ($Ydtobs) = split /\n/, `awk -F"," '{if (\$1~"$sname" && \$2=="$ename") print \$5-\$6}' $cfile`;
# dt(obs) measured in this comment
our ($Zdtobs) = (2.15377+0.002835+8*0.001); # dtpre+dtres; see Table1&2 of the comment
our $redtres = sprintf("%.1f",($Zdtobs-2.158)*1000); # (ms); dt(pre) based on YSR23-relocation
$redtres*=-1; # following definition in the comment Fig.1&3


# dt(res) of D1 & D2
our $J  = "-JQ10c";
our $R  = "-R-170/190/-90/90";
`gmt psxy $J $R -T -K > $PS`;
`gmt psxy $J $R -X-1c -Y10c -K -O -T >> $PS`;
`echo "-170 90 (a) dt(res) based on corrected relocation results in YSR23-errata"|gmt pstext $J $R -F+f14p,1+jBL -Dj-1c/0.5c -N -K -O >> $PS`;
# --- (1) D1_1995-2003
&PLTPHASE("D1_1995-2003","1995318_2003183","AAK");
# ref. of AAK
my $JM = "-JX10c";
my $RM = "-R0/10/0/10";
my ($rename,$rspesta) = ("1995318_2003183","AAK");
#`gmt psbasemap $JM $RM -Bxa1f1g1 -Bya1f1g1 -BSWEN --MAP_FRAME_PEN=0.5p,red --FONT_ANNOT_PRIMARY=10p,red -K -O >> $PS`;
`echo "\n4.2 0\n8.8 0\n8.8 1.4\n4.2 1.4"|gmt psxy $JM $RM -Gwhite -W0.15p -L -K -O >> $PS`;
`echo '6.5 1.3 "Clock error" reported in YSR21'|gmt pstext $JM $RM -F+f8p,1+jTC -Dj0c/0c -N -K -O -N >> $PS`;
`echo "\n4.4 1\n8.6 1"|gmt psxy $JM $RM -W0.3p -K -O >> $PS`;
my ($rdtres) = split /\n/, `awk -F"," '{if (\$1~".$rspesta" && \$2=="$rename") print \$4}' $cfile`;
$rdtres*=-1; # following definition in the comment Fig.1&3
$rdtres*=1000; # s -> ms
my $rdtresplt = abs($rdtres*0.01); # same scale of legend
`echo "7.1 0.5 $rdtresplt c"|gmt psxy $JM $RM -Ss -W1p,$clrp -K -O -N >> $PS` if ($rdtres>=0);
`echo "7.1 0.5 $rdtresplt c"|gmt psxy $JM $RM -Sc -W1p,$clrn -K -O -N >> $PS` if ($rdtres<0);
`echo '5.5 0.8 $rspesta'|gmt pstext $JM $RM -F+f8p,1+jTL -Dj0c/0c -N -K -O -N >> $PS`;
`echo '5.5 0.4 $rdtres ms'|gmt pstext $JM $RM -F+f8p,1,$clrp+jTL -Dj0c/0c -N -K -O -N >> $PS` if ($rdtres>=0);
`echo '5.5 0.4 $rdtres ms'|gmt pstext $JM $RM -F+f8p,1,$clrn+jTL -Dj0c/0c -N -K -O -N >> $PS` if ($rdtres<0);
`gmt psxy $J $R -X11.5c -K -O -T >> $PS`;
# --- (2) D2_1993-2004
&PLTPHASE("D2_1993-2004","1993309_2004130","OBN");
# ref. of OBN
$JM = "-JX10c";
$RM = "-R0/10/0/10";
($rename,$rspesta) = ("1993309_2004130","OBN");
#`gmt psbasemap $JM $RM -Bxa1f1g1 -Bya1f1g1 -BSWEN --MAP_FRAME_PEN=0.5p,red --FONT_ANNOT_PRIMARY=10p,red -K -O >> $PS`;
`echo "\n4.2 0\n8.8 0\n8.8 1.4\n4.2 1.4"|gmt psxy $JM $RM -Gwhite -W0.15p -L -K -O >> $PS`;
`echo '6.5 1.3 "Clock error" reported in YSR21'|gmt pstext $JM $RM -F+f8p,1+jTC -Dj0c/0c -N -K -O -N >> $PS`;
`echo "\n4.4 1\n8.6 1"|gmt psxy $JM $RM -W0.3p -K -O >> $PS`;
# YSR21
($rdtres) = split /\n/, `awk -F"," '{if (\$1~".$rspesta" && \$2=="$rename") print \$4}' $cfile`;
$rdtres*=-1; # following definition in the comment Fig.1&3
$rdtres*=1000; # s -> ms
$rdtresplt = abs($rdtres*0.01); # same scale of legend
`echo "7.1 0.5 $rdtresplt c"|gmt psxy $JM $RM -Ss -W1p,$clrp -K -O -N >> $PS` if ($rdtres>=0);
`echo "7.1 0.5 $rdtresplt c"|gmt psxy $JM $RM -Sc -W1p,$clrn -K -O -N >> $PS` if ($rdtres<0);
`echo '5.5 0.8 $rspesta'|gmt pstext $JM $RM -F+f8p,1+jTL -Dj0c/0c -N -K -O -N >> $PS`;
`echo '5.5 0.4 $rdtres ms'|gmt pstext $JM $RM -F+f8p,1,$clrp+jTL -Dj0c/0c -N -K -O -N >> $PS` if ($rdtres>=0);
`echo '5.5 0.4 $rdtres ms'|gmt pstext $JM $RM -F+f8p,1,$clrn+jTL -Dj0c/0c -N -K -O -N >> $PS` if ($rdtres<0);
`gmt psxy $J $R -X-11.5c -Y-5c -T -K -O >>$PS`;


# plot waveforms
$J = "-JX8c/-3c";
my ($xmin,$xmax,$ymin,$ymax) = (742,747,-1,0.9);
$R = "-R$xmin/$xmax/$ymin/$ymax";
my $M = "-M2c";
my $W = "-W1p";
# instrument response changes:
`echo "$xmin $ymin (b) P waveforms processed with instrument responses used in this comment and YSR21"|gmt pstext $J $R -F+f14p,1+jLB -Dj-1c/0.5c -K -O -N >> $PS`;
our $sac1 = "OBN.D2.1993.sac";
our $sac2 = "OBN.D2.2004.sac";
# --- copy of Fig.5d
&FIG5d;
`echo "$xmax $ymax (With instr. resp."|gmt pstext $J $R -F+f10p+jLB -Dj0.15c/0.6c -K -O -N >> $PS`;
`echo "$xmax $ymax used in ZW23)"|gmt pstext $J $R -F+f10p+jLB -Dj0.15c/0.1c -K -O -N >> $PS`;
`gmt psxy $J $R -X11.5c -K -O -T >> $PS`;
# --- data processed by YSR21-instr.resp.
$sac1 = "II.OBN.00.BHZ.M.1993.309.070429.SAC.bp.ysr21";
$sac2 = "II.OBN.00.BHZ.M.2004.130.222754.SAC.bp.ysr21";
&FIG5d;
`echo "$xmax $ymax (With instr. resp."|gmt pstext $J $R -F+f10p+jLB -Dj0.15c/0.6c -K -O -N >> $PS`;
`echo "$xmax $ymax used in YSR21)"|gmt pstext $J $R -F+f10p+jLB -Dj0.15c/0.1c -K -O -N >> $PS`;
`gmt psxy $J $R -X-11.5c -Y-5.7c -K -O -T >> $PS`;


`gmt psxy $J $R -T -O >> $PS`;
`rm gmt.*`;

sub PLTPHASE {
	my ($edir,$ename,$spesta) = @_;
	print STDERR "# $edir\n";
	# location
	my ($id) = split /\_/, $edir;
	my $Yfile  = "Align-YSR23errata.$id";
	my ($evlo,$evla) = split " ", `awk '{if (NR==2) print \$2,\$3}' Info.YSR23errata.$id`;chomp $evla;
	# map
	`gmt pscoast $J $R -Bxa60f30 -Bya30f15 -BSWen -W1/0.1p,darkgray -Ggray -K -O -A10000 >> $PS`;
	# legend
	open(PSLEGEND,"|gmt pslegend $J $R -DjBL+w4c+o0.03c/0.03c+l1.2 -C0.2c/0.2c -F+p0.05p+gwhite -K -O >> $PS");
	print PSLEGEND "N 4\n";
	print PSLEGEND "G 0.2c\n";
	print PSLEGEND "S 0.3c s 0.3c - 1p,$clrp 0.5c\n";
	print PSLEGEND "S 0.2c s 0.6c - 1p,$clrp 0.5c\n";
	print PSLEGEND "S 0.3c s 0.9c - 1p,$clrp 0.5c\n";
	print PSLEGEND "L 10p 1 C (+)\n";
	print PSLEGEND "G 0.5c\n";
	print PSLEGEND "S 0.3c c 0.3c - 1p,$clrn  0.5c\n";
	print PSLEGEND "S 0.2c c 0.6c - 1p,$clrn  0.5c\n";
	print PSLEGEND "S 0.3c c 0.9c - 1p,$clrn  0.5c\n";
	print PSLEGEND "L 10p 1 C (-)\n";
	print PSLEGEND "G 0.3c\n";
	print PSLEGEND "L 10p 1 C 30\n";
	print PSLEGEND "L 10p 1 L 60\n";
	print PSLEGEND "L 10p 1 C 90\n";
	print PSLEGEND "L 10p 1 C (ms)\n";
	print PSLEGEND "G -0.1c\n";
	close PSLEGEND;
	# dt(res) list
	my @lines = split /\n/, `awk '{if (\$1!="#" && \$1!="$spesta") print \$0}' $Yfile|awk '{if (\$9=="------") print \$1,\$2,\$3,\$4,\$8; else print \$1,\$2,\$3,\$4,\$9}'`;
	# plot for each station
	open(PSXYR,"| gmt psxy $J $R -W0.3p,dimgray,- -K -O -N >> $PS");
	open(PSXYP,"| gmt psxy $J $R -Ss -W1p,$clrp -K -O -N >> $PS");
	open(PSXYN,"| gmt psxy $J $R -Sc -W1p,$clrn  -K -O -N >> $PS");
	open(PSTEXT,"|gmt pstext $J $R -F+f6p+jTC -Dj0c/-0.3c -N -K -O -N >> $PS");
	foreach my $line (@lines) {
		my ($sta,$ph,$stlo,$stla,$dtres) = split " ", $line;
		$dtres*=-1; # following definition in the comment Fig.1&3
		$dtres*=0.01; # (ms) chg size for good vision
		print PSXYR ">\n";
		print PSXYR "$stlo $stla\n";
		print PSXYR "$evlo $evla\n";
		printf PSXYP "$stlo $stla %f c\n",abs($dtres) if ($dtres>=0);
		printf PSXYN "$stlo $stla %f c\n",abs($dtres) if ($dtres<0);
		print PSTEXT "$stlo $stla $sta($ph)\n";
	}
	close PSXYR;
	close PSXYP;
	close PSXYN;
	close PSTEXT;
	# Plot event
	`echo $evlo $evla | gmt psxy $J $R -Sa0.5c -Gred -W0.2p,black -K -O -N >> $PS`;
	# title
	`echo "-170 90 $edir"|gmt pstext $J $R -F+f14p,1+jTL -Dj0.15c/0.2c -N -K -O >> $PS`;
}

sub FIG5d {
	# copied from script for Fig.5d of this comment
	my $dtres = 8;
	my $pdt = -2.1563-$dtres*0.001;
	`gmt pssac $J $R $sac1 $M -W1p,$clr1 -C -T+s$pdt -K -O >> $PS`;
	`gmt pssac $J $R $sac2 $M -W1p,$clr2 -C -K -O >> $PS`;
	`gmt psbasemap $J $R -Bxa2f1 -By -BwenS -K -O >> $PS`;
	`echo "$xmin 0.75 dt(res) = $dtres ms"|gmt pstext $J $R -F+f10p,1+jBL -Dj0.1c/0c -N -K -O >> $PS`;
	`echo "743.7 -0.65 P"|gmt pstext $J $R -F+f9p,2+jTC -Dj0c/0c -N -K -O >> $PS`;
}
