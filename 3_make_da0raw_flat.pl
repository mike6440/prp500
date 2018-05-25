#!/usr/bin/perl -X
# wiprr.txt   Program 3_make_prp_raw_flat.pl,  Runtime 2015-07-08 (189) 22:18:56
# nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt
# 1 15.0 2.3 2015 06 29 17 00 03 39.9 84.1 406.6 -3.0 22.4 22.4 1.8 3.4 12.0 16.2

$PROGRAMNAME = $0;
$VERSION = '3';
$EDIT = '20180516T162856Z';
#v3 now works with raw_parse.txt

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
my $timeseriespath=FindInfo($setupfile,'TIMESERIESPATH');
print"TIMESERIESPATH = $timeseriespath.\n";
if ( ! -d $timeseriespath ) { 
	`mkdir $timeseriespath`;
	print"Create $timeseriespath\n";
}
		# IMAGEPATH
my $imagepath=FindInfo($setupfile,'IMAGEPATH');
print"IMAGEPATH = $imagepath.\n";
if ( ! -d $imagepath ) { 
	`mkdir $imagepath`;
	print"Create $imagepath\n";
}
	# RUN TIME SETUP FILE
$sufile=`ls -1 $datapath/data/data*/su*.txt | tail -1`;
chomp $sufile;
print"last setup file = $sufile\n";

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

	# PSP CAL
@x=FindLines($sufile,"% PSP CALIBRATION",1);
@y=split /[ \t]+/,$x[1];
@pspcal=($y[0], $y[1]); 
print"psp cal: @pspcal\n";
	# PIR CAL 
@x=FindLines($sufile,"% PIR CALIBRATION",1);
@y=split /[ \t]+/,$x[1];
@pircal=($y[0], $y[1]); 
print"pir cal: @pircal\n";

@x=FindLines($sufile,"% TCASE FIT",13);
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

	# OPEN FLAT FILE FOR WRITE -- DA0, DAG, DA1, DA2, DA3,...,DA7 xxy
$f = $timeseriespath.'/da0raw_flat.txt';
print"DA0 OUTPUT $f\n";
open FR,">$f" or die;
printf FR "$series, Program $PROGRAMNAME v$VERSION, Raw Radiation Measurements,  Runtime %s\n",dtstr(now,'short');
print FR "nrec shad shlim yyyy MM dd hh mm ss mode th sw lw pir tcase tdome pitch roll az batt\n";
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
	#print"SHADOWBAND FILTER$i $f\n";
	$cmd=sprintf"$series, Program $PROGRAMNAME v$VERSION,  Raw Sweep Measurements, Channel $i, Runtime %s",dtstr(now,'short');
	$cmd=sprintf"print F$i \"%s\\n\"",$cmd;
	#print"$cmd\n";
	eval $cmd;
	$cmd=sprintf("print F%d \"nrec  shad  shlim yyyy MM dd hh mm ss g s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23\\n\";",$i);
	eval $cmd;
}

	# OPEN RAW_PARSE.TXT
$rawparsefile="$timeseriespath/raw_parse.txt";
print"$rawparsefile";
open FIN,"$rawparsefile" or die;
print" OPEN\n";

while(<FIN>){
	chomp($str=$_);
		# Remove leading zeros
	$str =~ s/^\s+//;
	# ===== WIPRR ========================
	#   0   1    2  3  4  5  6  7  8   9    10       11   12      13    14    15    16     17   18  19
	#WIPRR  yyyy MM dd hh mm ss M Thd  shad shadlim sw   lw      pir   tcase tdome pitch  roll az  batt
	#$WIPRR,2018,05,14,00,03,39, 1,40.7,48.1,10,     6.57,361.14,-32.09,17.90,18.15,-5.0,  3.0, 356.3,0.0*7A
	if($str =~ /\$WIPRR/){
		#print"string=$str\n";
		@s=split /[\s,*]+/, $str;
		#$i=0;foreach(@s){print"$i, $_\n"; $i++}die;
		$dt=datesec($s[1],$s[2],$s[3],$s[4],$s[5],$s[6]);
		# TIME WINDOW
		if($dt > $dtend){last}
		if($dt >= $dtstart){
			$nrec++;
       #print FR "nrec shad shlim yyyy MM dd hh mm ss mode th sw lw pir tcase tdome pitch roll az batt\n";
			$strx="$nrec";
			if($s[7] == 0){$strx="$strx 0 0"}else{$strx="$strx $s[9] $s[10]"}
			$strx=$strx.sprintf(" %s",dtstr($dt,'ssv'));
			$strx="$strx $s[7] $s[8] $s[11] $s[12] $s[13] $s[14] $s[15] $s[16] $s[17] $s[18] $s[19]";		
			print FR "$strx\n";
		}
	}
	# ===== WIPRG =========================
	#  0     1    2  3  4  5  6   7   8   9   10  11   12  13  14
	#  WIPRG yyyy MM dd hh mm ss shad g1  g2  g3  g4   g5  g6  g7 
	# $WIPRG,2018,05,13,03,10,04,1.4, 0.0,9.0,9.0,12.5,4.5,9.0,7.5*68
	if($str =~ /\$WIPRG/){
		#print"global string=$str\n"; die;
		@p=split /[\s,*]+/, $str;
		$dt=datesec($p[1],$p[2],$p[3],$p[4],$p[5],$p[6]);
		# TIME WINDOW
		if($dt > $dtend){last}
		if($dt >= $dtstart){
			#print FG "nrec yyyy MM dd hh mm ss shad g1 g2 g3 g4 g5 g6 g7\n";
			$strx="$nrec ";
			$strx=sprintf("$strx %s ",dtstr($dt,'ssv'));
			$strx="$strx $p[7] $p[8] $p[9] $p[10] $p[11] $p[12] $p[13] $p[14]";
			print FG "$strx\n";
		}
	}

	# ===== WIPR1 =========================
	#0      1    2  3  4  5  6  7   8   9   10  11  12  13  14  15  16  17  18 19 20 21  22  23  24  25  26  27 28 29 30 chk
    #$WIPR1,2018,05,13,16,16,10,8.5,229,233,240,241,239,236,235,235,235,185,94,94,94,109,227,245,246,246,246,0,0,0,0*0F
	# OUT FILE
	# wipr1.txt   Program 3_make_prp_raw_flat.pl,  Runtime 2015-07-08 (189) 22:18:56
	# nrec  shad  shlim yyyy MM dd hh mm ss g s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23
	# 1 15.0 2.3 2015 06 29 17 00 03 324.5 324 324 325 322 319 318 318 317 269 84 76 76 162 312 312 312 312 312 314 315 314 313 317
	for($j=1; $j<=7; $j++){
		$strx="\\\$WIPR$j";
		if($str =~ /$strx/){
			#print"sweep string=$str\n"; 
			@q=split /[\s,*]+/, $str;
			#$ii=0; foreach $qx (@q){print"$ii $x\n";$ii++} die;
			$dt=datesec($q[1],$q[2],$q[3],$q[4],$q[5],$q[6]);
			$cmd="\$F=F$j";
			eval($cmd);
				# TIME WINDOW
			if($dt > $dtend){last}
			if($dt >= $dtstart){
				$strx="$nrec $p[7] $s[10] ";
				$strx=sprintf("$strx %s",dtstr($dt,'ssv'));
				$strx="$strx $p[7+$j]";
				for($i=8; $i<=30; $i++){
					$strx = "$strx $q[$i]";
				}
				print $F "$strx\n";
# 				print"$strx\n"; die;
			}
		}
	}
}
close FR; close FG; 
#close F1; close F2; close F3; close F4; close F5; close F6; close F7; 
exit 0;


exit;

