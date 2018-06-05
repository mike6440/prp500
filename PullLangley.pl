#!/usr/bin/perl -X
# see !! for setting
use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use perltools::LineFit;

$PROGRAMNAME = $0;
$VERSION = '1';
$EDITDATE = "180528";

my $setupfile="0_setup_process.txt";
my $timeseriespath=FindInfo($setupfile,'TIMESERIESPATH');

#=============================
$langleynumber=1;  #!!
$str="ly1 2018,05,21,23,17,03  2018,05,22,01,38,12";  #!!
# ly1 2018,05,21,23,17,03  2018,05,22,01,38,12
# ly3 2018,05,22,15,40,00  2018,05,22,18,32,51
# ly4 2018,05,22,22,02,07  2018,05,23,01,37,27
# ly6 2018,05,23,22,26,49  2018,05,24,00,43,12
# ly7 2018,05,27,22,17,00  2018,05,28,01,46,46

@a=split /[ ,]+/,$str;
$dt1=datesec($a[1],$a[2],$a[3],$a[4],$a[5],$a[6]); 
$dt2=datesec($a[7],$a[8],$a[9],$a[10],$a[11],$a[12]); 
printf("Langley $langleynumber, %s  %s\n",dtstr($dt1),dtstr($dt2));
#===============================

$chan=7; ## !!
# INPUT DA2
# 0    1    2  3  4  5  6  7   8   9   10  11    12     13   14   15   16    17     18      19
# nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal
# 1434 2018 05 19 18 46 23  47.649620 -122.313120  32.1 143.1  22.6  969.0   2141.0 2181.0 2161.0   1192.0 2332.0 1140.0 1192.0
$cmd=sprintf("open D, \"%s/da%d.txt\" or die;",$timeseriespath,$chan);
print"$cmd\n";
eval $cmd;
# OUTPUT
$fn=sprintf("%s/Langley%d-chan%d.txt",$timeseriespath,$langleynumber,$chan);
print"OPEN OUT $fn\n";
open L, ">$fn" or die;

my $pi=3.14159265359;
my $d2r=$pi/180;
my @am; my @lg;
$str=<D>; print L $str;
$str=<D>; print L $str;
while(<D>){
	chomp($str=$_);
	@a=split /[ ]+/,$str;
	$dt=datesec($a[1],$a[2],$a[3],$a[4],$a[5],$a[6]);
	$am= 1 / cos($a[9]*$d2r);
	if($am >= 2){
		push(@am,$am);
		$lg=log($a[19]);
		push(@lg,$lg);
	}
	if($dt > $dt2){last}
	if($dt >= $dt1){print L "$str\n"}
}
close D; close L;

print"Number am>2: $#am, $#lg\n";
print"\a\aDone\n";
exit;
