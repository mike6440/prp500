#!/usr/bin/perl -X
# read all $DATAPATH/furuno_mirai_prp/FurunoGPSGGA_20160222.raw
#         MM dd yyyy hh mm ss.sss $ID    hhmmss ddmm.mmmm h dddmm.mmmm h q ns pre  alt u he   u x x*
# in records 02/23/2016,00:50:08.422,$GPGGA,005008,3502.3425,N,13830.8727,E,1,19,0.6,31.0,M,35.1,M,,*73
# q=0 invalid, 1 good.    

$PROGRAMNAME = 'make_furuno_gps_flat';
$VERSION = '1';

use lib $ENV{MYLIB};
use perltools::MRutilities;
use perltools::MRtime;

my $setupfile="0_setup_process.txt";

my $str = FindInfo($setupfile,'GPS FLAG');
if($str == 1){
	$fixedpositionflag=1;
	$fixedlat=FindInfo($setupfile,'FIXED LAT');
	$fixedlon=FindInfo($setupfile,'FIXED LON');
	print"FIXED POSITION: lat=$fixedlat, lon=$fixedlon\n";
	exit 0;
} else {
	$fixedpositionflag=0;
	print"Use GPGGA files\n";
}
die;
		# DATAPATH 
my $datapath = FindInfo($setupfile,'DATAPATH',':');
print "DATAPATH = $datapath   ";
if ( ! -d $datapath ) { print"DOES NOT EXIST. STOP.\n"; exit 1}
else {print "EXISTS.\n"}
		# TIMESERIESPATH
my $timeseriespath=$datapath.'/timeseries';
print"TIMESERIESPATH = $timeseriespath.\n";
if ( ! -d $timeseriespath ) { 
	`mkdir $timeseriespath`;
	print"Create $timeseriespath\n";
}
		# INFOFILE 
my $infofile = FindInfo($setupfile,'INFOFILE',':');
print "INFOFILE = $infofile   ";
if ( ! -f $infofile ) { print"DOES NOT EXIST. STOP.\n"; exit 1}
else {print "EXISTS.\n"}
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


# OPEN FLAT FILE FOR WRITE -- GPGGA
$f = $timeseriespath.'/gpgga_flat.txt';
print"GPS OUTPUT $f\n";
open FR,">$f" or die;
printf FR "Read GPGGA   $PROGRAMNAME V$VERSION,  Runtime %s\n",dtstr(now);
print FR "nrec yyyy MM dd hh mm ss hhmmss lat lon q nsat pre alt he\n";
#         1 2016 02 23 00 50 09 005008 -35.03904 -138.51454  1 19 0.6 31.0 35.1
# LIST ALL PRPRAW DATA FILES

@w= `ls $datapath/archive/furuno_mirai_prp/FurunoGPSGGA_*.raw`;
#foreach (@w){chomp($str=$_); print"$str\n" }

#  PROCESS RAW FILES
if ($#w < 0 ) { print"Error, no raw files\n"; exit 1}

	# FIND THE FIRST RAW FILE 
foreach $frw (@w){
	chomp($frw);
	print"Raw file $jf = $w[$jf]\n";
	$dts=substr($frw,-10,6);
	print"File date = $dts\n";
	$dtfile = dtstr2dt($dts)+$timecorrect;
	printf"startday %s\n",dtstr($dtstartday,'date');
	if($dtfile >= $dtstartday){print"Start processing here.\n"; last}
	else{print"Reject this file.\n"; $jf++}
}
for($ifl=$jf; $ifl<=$#w; $ifl++){
	$frw=$w[$ifl];
	chomp($frw);
	$dts=substr($frw,-10,6);
	$dtfile = dtstr2dt($dts)+$pctimecorrect;
	if($dtfile > $dtend){last}
	else {
		print"OPEN $frw\n";
		open(FIN,$frw) or die;
		# READ EACH RECORD
		while (<FIN>) {
			chomp($str=$_);
			#print"string = $str\n";
			@s=split /[\/:\s,*]+/, $str;
			#$i=0;foreach(@s){print"$i, $_\n"; $i++}
			if( $s[6] =~ /GPGGA/ && $s[12] eq '1'){
				$str=substr $str,24,-3;
				#print"$str\n";
				$ch=NmeaChecksum($str);
				#print"ch=$ch\n";
				if($ch eq $s[19]){
					$dt=datesec($s[2],$s[0],$s[1],$s[3],$s[4],$s[5]);
					# TIME WINDOW
					if($dt > $dtend){last}
					if($dt >= $dtstart){
						$nrec++;
						$strx="$nrec";
						$strx=$strx.sprintf(" %s $s[7] %.5f %.5f ",dtstr($dt,'ssv'), dm2dg($s[8],$s[9]),dm2dg($s[10],$s[11]));
						$strx=$strx.' '.$s[12].' '.$s[13].' '.$s[14].' '.$s[15].' '.$s[17];
						#print"$strx\n"; die;
						print FR "$strx\n";
					}
				}
			}
		}
	}
}
close FR; close FG; 
exit 0;

#================================================================================
sub dm2dg
{
	my ($x1,$x2,$x3);
	$x1=$_[0];  $ns=$_[1];
	$x2=$x1-100*int($x1/100); #mins
	$x2=int($x1/100)+$x2/60;
	if($ns =~ /[ws]/i){$x2=-$x2}
	return $x2;
}
