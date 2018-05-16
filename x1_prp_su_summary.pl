#!/usr/bin/perl -X

$PROGRAMNAME = 'prp_su_summary';
$VERSION = '1';

use lib $ENV{MYLIB};
use perltools::MRutilities;
use perltools::MRtime;

my $setupfile="0_setup_process.txt";

		# DATAPATH 
my $datapath = FindInfo($setupfile,'DATAPATH',':');
print "DATAPATH = $datapath   ";
if ( ! -d $datapath ) { print"DOES NOT EXIST. STOP.\n"; exit 1}
else {print "EXISTS.\n"}

		# TIMESERIESPATH
my $timeseriespath=FindInfo($setupfile,"TIMESERIESPATH",":");
print"TIMESERIESPATH = $timeseriespath.\n";
if ( ! -d $timeseriespath ) { 
	`mkdir $timeseriespath`;
	print"Create $timeseriespath\n";
}
		# START AND END TIMES
$str = FindInfo($setupfile,'STARTTIME');
my @k=split /[ ,]+/,$str;
$dtstart = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
$dtstartday = datesec($k[0],$k[1],$k[2],0,0,0);
$startday = sprintf("%s",dtstr(datesec($k[0],$k[1],$k[2],0,0,0),'date'));
#printf"startday %s\n",$startday;
$str = FindInfo($setupfile,'ENDTIME');
@k=split /[ ,]+/,$str;
$dtend = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
printf "START %s   END %s\n",dtstr($dtstart), dtstr($dtend);

	# PC CLOCK ERROR
$timecorrect=FindInfo($setupfile,"TIME CORRECTION SEC");
print"TIME CORRECTION SEC=$timecorrect\n";

print"END OF SUMMARY REVIEW: $su_summary\n";
exit 0;
