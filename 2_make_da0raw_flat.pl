#!/usr/bin/perl -X
# wiprr.txt   Program 3_make_prp_raw_flat.pl,  Runtime 2015-07-08 (189) 22:18:56
# nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt
# 1 15.0 2.3 2015 06 29 17 00 03 39.9 84.1 406.6 -3.0 22.4 22.4 1.8 3.4 12.0 16.2

$PROGRAMNAME = 'prp_su_summary';
$VERSION = '1';
$EDIT = '20170630T162501Z';

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
my $timeseriespath=$datapath.'/timeseries';
print"TIMESERIESPATH = $timeseriespath.\n";
if ( ! -d $timeseriespath ) { 
	`mkdir $timeseriespath`;
	print"Create $timeseriespath\n";
}
	# RUN TIME SETUP FILE
#ls -1 /Users/rmr/data/prp/prp11/170630_prp11_burnin/archive/data/data*/su*.txt | tail -1
$sufile=`ls -1 $datapath/archive/data/data*/su*.txt | tail -1`;
chomp $sufile;
print"last setup file = $sufile\n";
print"Continue...\n";
	# SERIES
$series=FindInfo($setupfile,'SERIES');
	# START AND END TIMES
$str = FindInfo($setupfile,'STARTTIME');
my @k=split /[ ,]+/,$str;
$dtstart = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
$dtstartday = datesec($k[0],$k[1],$k[2],0,0,0);

$str = FindInfo($setupfile,'ENDTIME');
@k=split /[ ,]+/,$str;
$dtend = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
printf "START %s   END %s\n",dtstr($dtstart), dtstr($dtend);
	# PC CLOCK ERROR
$timecorrect=FindInfo($setupfile,"TIME CORRECTION SEC");
print"TIME CORRECTION SEC = $timecorrect\n";


$prprxfile= FindInfo($setupfile,'PRPRX FILE');
	# PSP CAL
@x=FindLines($prprxfile,"% PSP CALIBRATION",1);
@y=split /[ \t]+/,$x[1];
@pspcal=($y[0], $y[1]); 
print"psp cal: @pspcal\n";

	# PIR CAL 
@x=FindLines($prprxfile,"% PIR CALIBRATION",1);
@y=split /[ \t]+/,$x[1];
@pircal=($y[0], $y[1]); 
print"pir cal: @pircal\n";

@x=FindLines($prprxfile,"% TCASE FIT",13);
	# CASE
@y=split /[ \t]+/,$x[1];
@casecal=($y[0], $y[1], $y[2], $y[3]); 
print"tcase cal: @casecal\n";
	# DOME
@y=split /[ \t]+/,$x[3];
@domecal=($y[0], $y[1], $y[2], $y[3]); 
print"tdome cal: @domecal\n";
	# % K COEFFICIANT
$Kcoefficient = $x[5];
print"K coef: $Kcoefficient\n";

	# SIGMA
$sigma = $x[7];
print"sigma: $sigma\n";

	# EPSILON
$epsilon = $x[9];
print"epsilon: $epsilon\n";

	# BATTERY
@y=split /[ \t]+/,$x[11];
print"battery coefs: @y\n";

# OPEN FLAT FILE FOR WRITE -- DA0, DAG, DA1, DA2, DA3,...,DA7 
$f = $timeseriespath.'/da0raw_flat.txt';
print"DA0 OUTPUT $f\n";
open FR,">$f" or die;
printf FR "$series, Program $PROGRAMNAME v$VERSION, Raw Radiation Measurements,  Runtime %s\n",dtstr(now,'short');
print FR "nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt\n";
# GLOBALS
$f = $timeseriespath.'/dag_flat.txt';
open FG,">$f" or die;
print"GLOBAL RAW $f\n";
printf FG "$series, Program $PROGRAMNAME v$VERSION,  Raw Global Measurements, Runtime %s\n",dtstr(now,'short');
print FG "nrec yyyy MM dd hh mm ss shad g1 g2 g3 g4 g5 g6 g7\n";
# CHANNELS
for($i=1; $i<=7; $i++){
	$cmd=sprintf("\$f = \$timeseriespath.\'/da%d_flat.txt\';",$i);
	eval $cmd;
	$cmd=sprintf("open F%d,\">$f\" or die;",$i); eval $cmd;
	print"SHADOWBAND FILTER$i $f\n";
	$cmd=sprintf"$series, Program $PROGRAMNAME v$VERSION,  Raw Sweep Measurements, Channel $i, Runtime %s",dtstr(now,'short');
	$cmd=sprintf"print F$i \"%s\\n\"",$cmd;
	print"$cmd\n";
	eval $cmd;
	$cmd=sprintf("print F%d \"nrec  shad  shlim yyyy MM dd hh mm ss g s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23\\n\";",$i);
	eval $cmd;
}

# LIST ALL PRPRAW DATA FILES
@w= `ls $datapath/archive/data/data*/prp_raw*.txt`;
foreach (@w){chomp($str=$_); print"$str\n" }

#  PROCESS RAW FILES
if ($#w < 0 ) { print"Error, no raw files\n"; exit 1}

	# FIND THE FIRST RAW FILE 
foreach $frw (@w){
	chomp($frw);
	print"Raw file $jf = $w[$jf]\n";
	$dts=substr($frw,-12,8);
	print"File date = $dts\n";
	$dtfile = datesec(substr($dts,0,4),substr($dts,4,2),substr($dts,6,2),0,0,0);
	$dtfile = $dtfile+$timecorrect;
	printf"Start day %s\n",dtstr($dtstartday,'short');
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
			#print"test string=$str\n";
			@s=split /[\s,*]+/, $str;
			#$i=0;foreach(@s){print"$i, $_\n"; $i++}
			# ===== WIPRR =========================
			#   0         1           2 3    4   5   6      7      8       9   10   11  12  13   14   15
			# $WIPRR,20150802T153707Z,0,40.1,0.0,10,98.37,390.81,-17.24,19.85,19.92,6.8,9.4,90.5,11.7*74
			# output da0
			#  0    1    2    3    4  5  6  7  8  9  10 11 12  13    14    15    16   17 18
			# nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt		
			if( $s[0] =~ "WIPRR"){ 
				$dt=dtstr2dt($s[1]);
				# TIME WINDOW
				if($dt > $dtend){last}
				if($dt >= $dtstart){
					$nrec++;
					$strx="$nrec";
					if($s[2] == 0){$strx="$strx 0 0"}else{$strx="$strx $s[4] $s[5]"}
					$shadlim = $s[5];
					$strx=$strx.sprintf(" %s",dtstr($dt,'ssv'))." $s[3]";
				
					$strx="$strx $s[6] $s[7] $s[8] $s[9] $s[10] $s[11] $s[12] $s[13] $s[14]";
				
					print FR "$strx\n";
				}
			}
			# ===== WIPRG =========================
			#   0         1           2     3    4      5     6     7     8     9    10 
			# $WIPRG,20150803T213247Z,15.4,437.0,387.0,524.0,690.5,814.0,659.0,472.5*43
			# output dag
			#  0    1    2    3    4  5  6  7  8  9  10 11 12  13    14    15    16   17 18
			# nrec shad shlim yyyy MM dd hh mm ss 		
			if( $s[0] =~ "WIPRG"){ 
				$dt=dtstr2dt($s[1]);
				# TIME WINDOW
				if($dt > $dtend){last}
				if($dt >= $dtstart){
					$strx="$nrec $s[2] $shadlim ";
					$strx=sprintf("$strx %s",dtstr($dt,'ssv'));
					$strx="$strx $s[3] $s[4] $s[5] $s[6] $s[7] $s[8] $s[9]";
					@g = split/[\s]+/,$strx;
					print FG "$strx\n";
				}
			}
		
			# ===== WIPR1 =========================
			#   0         1           2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24
			#$WIPR1,20150803T213247Z,508,509,511,512,514,514,513,510,502,481,202,142,141,209,486,507,511,508,506,513,520,526,537*1F
			# OUT FILE
			# wipr1.txt   Program 3_make_prp_raw_flat.pl,  Runtime 2015-07-08 (189) 22:18:56
			# nrec  shad  shlim yyyy MM dd hh mm ss g s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23
			# 1 15.0 2.3 2015 06 29 17 00 03 324.5 324 324 325 322 319 318 318 317 269 84 76 76 162 312 312 312 312 312 314 315 314 313 317
			for($j=1; $j<=7; $j++){
				$str="WIPR$j";
				$cmd="\$F=F$j";
				eval($cmd);
				if( $s[0] =~ $str){ 
					$dt=dtstr2dt($s[1]);
					# TIME WINDOW
					if($dt > $dtend){last}
					if($dt >= $dtstart){
						$strx="$nrec $g[1] $g[2] ";
						$strx=sprintf("$strx %s",dtstr($dt,'ssv'));
						$strx="$strx $s[3]";
						for($i=2; $i<=24; $i++){
							$strx = "$strx $s[$i]";
						}
						print $F "$strx\n";
					}
				}
			}
		}
	}
}
close FR; close FG; 
#close F1; close F2; close F3; close F4; close F5; close F6; close F7; 
exit 0;


exit;

