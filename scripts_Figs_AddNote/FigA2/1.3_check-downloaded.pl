#!/usr/bin/env perl
# check if really downloaded
# 2024-04-14 zx
use strict;
use warnings;
our $ccsv = "../YSR21_clcerr.csv";
our $rcsv = "../YSR23_relocation.csv";
our $fout = "List_undownloaded";
open(OUT,"> $fout");

# event pairs in YSR23-errata
our @epairs = split /\n/, `awk '{if (\$1!="#") print \$0}' $ccsv|awk -F"," '{print \$2}'|sort -u|awk '{if (\$1!="") print \$0}'`;
foreach my $epair (@epairs) {
	# stations of clrerr
	my @stas = split /\n/, `awk -F"," '{if (\$2=="$epair") print \$1}' $ccsv`;
	my $nsta = scalar(@stas);
	my @nets = split /\n/, `awk -F"," '{if (\$2=="$epair") print \$1}' $ccsv|awk -F"." '{print \$1}'|sort -u`;
	# dir
	my $edir = "data_$epair.$nsta";
	my @stadowns = split /\n/, `ls $edir/Event_*|grep "sac"|awk -F"." '{print \$1"."\$2}'|sort|uniq`;
	if (!defined $stadowns[0]) {
		print OUT "# $epair [NONE]\n";
		next;
	}
	my @edirs = glob "$edir/Event_*";
	if (scalar(@edirs)!=2) {
		print OUT "# $epair [NONE] --> @edirs\n";
		next;
	}
#	print STDERR "In TableS2:\n@stas\n";
#	print STDERR "Accessible:\n@stadowns\n";
	for(my $i=0;$i<@stas;$i++) {
		if (grep {$_ eq $stas[$i]} @stadowns) {
			next;
		} else {
			print OUT "## $epair   $stas[$i]\n";
		}
	}
}
close OUT;
# now see how many undownloaded
`echo ">>> doublets not accessiable:" >> $fout`;
`awk '{if (\$1=="#") print \$2}' $fout|sort -u|wc -l >> $fout`;
`echo ">>> stations of cases not accessiable:" >> $fout`;
`awk '{if (\$1=="##")print \$3}' $fout|wc -l >> $fout`;
`echo "they are:" >> $fout`;
`awk '{if (\$1=="##")print \$3}' $fout|sort -u >> $fout`;
