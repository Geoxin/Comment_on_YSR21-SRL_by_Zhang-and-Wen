#!/usr/bin/env perl
# cycle: downSOD
# 2024-04-11 zx
use strict;
use warnings;
# data not downloaded
my $list = "List_todown";
my $todo = 0;
open(TODO,"> $list");
foreach my $dir (glob "data_*_*.*") {
	my @sacs = split /\n/, `ls $dir/Event_*/*sac`;
	if (@sacs==0) {
		print TODO "$dir\n";
		$todo++;
	}
}
close TODO;

my $num = 3;
$num=$todo if($todo<$num);

for(my $i=0;$i<$num;$i++) {
	my $rpl = "run_downSOD.$i.pl";
	`cp lib_downSOD/sub_downSOD.pl $rpl`;
	`perl -pi -e "s/IIII/$i/gi" $rpl`;
	`perl -pi -e "s/NNNN/$num/gi" $rpl`;
}
