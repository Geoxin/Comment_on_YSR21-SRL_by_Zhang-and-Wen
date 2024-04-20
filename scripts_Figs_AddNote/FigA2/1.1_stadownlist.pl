#!/usr/bin/env perl
# output list for download: to get station info.
# 2024-04-11 zx
use strict;
use warnings;
our $ccsv = "../YSR21_clcerr.csv";
our $rcsv = "../YSR23_relocation.csv";

# event pairs in YSR23-errata
our @epairs = split /\n/, `awk '{if (\$1!="#") print \$0}' $ccsv|awk -F"," '{print \$2}'|sort -u|awk '{if (\$1!="") print \$0}'`;
foreach my $epair (@epairs) {
	# stations of clrerr
	my @stas = split /\n/, `awk -F"," '{if (\$2=="$epair") print \$1}' $ccsv`;
	my $nsta = scalar(@stas);
	my @nets = split /\n/, `awk -F"," '{if (\$2=="$epair") print \$1}' $ccsv|awk -F"." '{print \$1}'|sort -u`;
	if ($nsta>0) {
		print STDERR "# $epair [$nsta]\n";
		# dir
		my $edir = "data_$epair.$nsta";
		`mkdir $edir`;

		# evn infos
		my $fevn = "events_$epair.$nsta.csv";
		my ($nr) = split /\n/, `awk -F"," '{if (\$1=="$epair") print NR}' $rcsv`;
#		print STDERR ">>> $nr\n";
		die "[ERROR] NO evn-info for $epair!\n" if (!defined $nr);
		my ($date1,$time1,$la1,$lo1,$dep1,$mag1) = split " ", `awk -F"," '{if (NR==$nr) print \$6,\$7,\$8,\$9,\$10,\$11}' $rcsv`;
		my ($date2,$time2,$la2,$lo2,$dep2,$mag2) = split " ", `awk -F"," '{if (NR==$nr+1) print \$6,\$7,\$8,\$9,\$10,\$11}' $rcsv`;
		my ($yy1,$mm1,$dd1) = split /\//, $date1;
		my ($yy2,$mm2,$dd2) = split /\//, $date2;
		open(EOUT,"> $fevn");
		print EOUT "time, latitude, longitude, depth, depthUnits, magnitude, magnitudeType\n";
		printf EOUT "%sT%sZ, %8.3f, %8.3f, %6.2f, KILOMETER, %4.1f, mwc\n","$yy1$mm1$dd1",$time1,$la1,$lo1,$dep1,$mag1;
		printf EOUT "%sT%sZ, %8.3f, %8.3f, %6.2f, KILOMETER, %4.1f, mwc\n","$yy2$mm2$dd2",$time2,$la2,$lo2,$dep2,$mag2;
		close EOUT;
		`mv $fevn $edir`;
		# downxml
		my $fxml = "download.xml";
		`cp lib_downSOD/download-1.xml $edir/$fxml`;
		chdir $edir;
		`perl -pi -e "s/csvfile/$fevn/gi" $fxml`;
		open(XOUT,">> $fxml");
		for(my $i=0;$i<@nets;$i++) {
			print XOUT "             <networkCode>$nets[$i]</networkCode>\n";
		}
		print XOUT "         </networkOR>\n";
		print XOUT "         <stationOR>\n";
		for(my $i=0;$i<@stas;$i++) {
			my ($net,$sta) = split /\./, $stas[$i];
			print XOUT "             <stationCode>$sta</stationCode>\n";
		}
		close XOUT;
		chdir "..";
		`cat lib_downSOD/download-2.xml >> $edir/$fxml`;
	}
}
