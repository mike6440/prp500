#!/usr/bin/perl -X
# Typical decode strings
# HIGH NO SHADOW
# 0                  1 2    3                          8                   11
# 20180513T030958Z ##1 0.0 -5.0 3.0 356.0 4.92 -31.64 228.39 228.45 53.41 50.98
# 12             14                                20                  23
# 378.81 503.17 -5.0 3.0 356.5  4.75 -31.95 228.39 228.47 51.39 49.10 378.81
# 24     25                    30                  35                    40 
# 503.46 1.5 2.3 9.0 10.0 12.0 5.0 9.0 8.0 1.0 8.0 10.0 13.0 5.0 9.0 8.0 1.0##
# HIGH SHADOW
# 20180513T214520Z ##1 39.9 -6.0 3.0 356.5 17.54 -33.06 176.57 176.80 30.98 28.84 
# 378.83 504.57 -6.0 3.0 357.4  18.17 -33.13 176.57 176.80 32.12 29.89 378.81 
# 504.47 95.5 2.3 
# 1899.0 1418.0 1552.0 1670.0 2208.0 2458.0 1927.0
# 1907.0 1428.0 1560.0 1676.0 2219.0 2467.0 1934.0 
# 1901 1896 1896 1889 1908 1896 1895 1892 1433 
# 283 155 157 181 992 1904 1941 1932 1931 1931 1939 1923 1902 1902 1425 1417 1422 
# 1407 1429 1413 1402 1392 1074 218 123 116 136 701 1375 1406 1394 1388 1390 1410
#  1421 1415 1426 1556 1550 1552 1543 1563 1547 1539 1533 1133 176 84 83 101 797 
#  1528 1554 1544 1540 1542 1559 1560 1550 1557 1673 1667 1668 1661 1680 1666 1658 
#  1655 1197 165 63 61 84 873 1653 1681 1670 1667 1669 1683 1680 1668 1673 2212 2204
#   2207 2202 2227 2211 2205 2202 1601 223 87 87 117 1159 2209 2244 2230 2226 2227 
#   2244 2237 2215 2215 2462 2455 2454 2445 2469 2456 2456 2454 1857 399 249 254 
#   291 1348 2494 2537 2525 2524 2526 2530 2496 2462 2462 1931 1924 1925 1918 1939 
# 1929 1929 1928 1481 324 194 197 229 1023 1955 1996 1986 1985 1988 1991 1963 1933 
# 1932##
#LOW
#20180513T031120Z ##0 20.7 -5.0 3.0 356.5 4.86 -33.93 228.56 229.00 51.73 
#49.33 378.75 442.19 -5.0 3.0 356.7  4.86 -34.01 228.56 229.04 48.72 46.54
# 378.75 442.35##

# $str=shift();
# $str=~s/[#\n\r]+//g;
# print"STRING: $str\n";
# @r=split /[\s]+/g,$str;
# $i=0; foreach $rx (@r){print"$i, $rx\n";$i++}
# 	# Mode 0==low, 1=high no shadow, 2=high shadow
# $Mode=-1;
# if($#r==40 && $r[1]==1){$Mode=1}
# elsif($#r==40 && $r[1]==0){$Mode=0}
# elsif($#r==201 && $r[1]==1){$Mode=2}
# else{print"0";exit 0}
# 
# print"Mode $Mode, WIPRR\n";
# $dt=dtstr2dt($r[0]);
# printf"%s\n",dtstr($dt,'csv');
# exit 0;





$PROGRAMNAME = $0;
$VERSION = '1';
$EDIT = '20180515T215451Z';

#====================
# PRE-DECLARE SUBROUTINES
#====================
use lib $ENV{MYLIB};
use perltools::MRutilities;
use perltools::MRtime;
use perltools::MRradiation;
use perltools::MRstatistics;

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
$sufile=`ls -1 $datapath/data/data*/su*.txt | tail -1`;
chomp $sufile;
print"last setup file = $sufile\n";
	# SERIES
$series=FindInfo($setupfile,'SERIES');
	# STARTTIME
$str = FindInfo($setupfile,'STARTTIME');
my @k=split /[ ,]+/,$str;
$dtstart = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
$dtstartday = datesec($k[0],$k[1],$k[2],0,0,0);
	# ENDTIME
$str = FindInfo($setupfile,'ENDTIME');
@k=split /[ ,]+/,$str;
$dtend = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
printf "START %s   END %s\n",dtstr($dtstart), dtstr($dtend);
	# PC CLOCK ERROR
$timecorrect=FindInfo($setupfile,"TIME CORRECTION SEC");
print"TIME CORRECTION SEC = $timecorrect\n";

$ShadowRatioThreshold = FindInfo($setupfile,'SHADOW THRESHOLD');
print"ShadowRatioThreshold $ShadowRatioThreshold\n";

#$sufile= FindInfo($setupfile,'PRPRX FILE');
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
@battcal=split /[ \t]+/,$x[11];
print"battery coefs: @battcal\n";
	# OUT FILE
$rawoutfile=sprintf"$timeseriespath/raw_parse.txt",$dt[0],$dt[1],$dt[2];
open F,">$rawoutfile" or die;
print F "WIPRR yyyy MM dd hh mm ss M Thd shad shadlim sw lw pir tcase tdome batt
 WIPRG yyyy MM dd hh mm ss shad g1 g2 g3 g4 g5 g6 g7
 WIPR1 yyyy MM dd hh mm ss shad s1 s2 ... s12 ... s23\n";

# OPEN FLAT FILE FOR WRITE -- DA0, DAG, DA1, DA2, DA3,...,DA7 
# $f = $timeseriespath.'/da0raw_flat.txt';
# print"DA0 OUTPUT $f\n";
# open FR,">$f" or die;
# printf FR "$series, Program $PROGRAMNAME v$VERSION, Raw Radiation Measurements,  Runtime %s\n",dtstr(now,'short');
# print FR "nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt\n";
# # GLOBALS
# $f = $timeseriespath.'/dag_flat.txt';
# open FG,">$f" or die;
# print"GLOBAL RAW $f\n";
# printf FG "$series, Program $PROGRAMNAME v$VERSION,  Raw Global Measurements, Runtime %s\n",dtstr(now,'short');
# print FG "nrec yyyy MM dd hh mm ss shad g1 g2 g3 g4 g5 g6 g7\n";
# # CHANNELS
# for($i=1; $i<=7; $i++){
# 	$cmd=sprintf("\$f = \$timeseriespath.\'/da%d_flat.txt\';",$i);
# 	eval $cmd;
# 	$cmd=sprintf("open F%d,\">$f\" or die;",$i); eval $cmd;
# 	#print"SHADOWBAND FILTER$i $f\n";
# 	$cmd=sprintf"$series, Program $PROGRAMNAME v$VERSION,  Raw Sweep Measurements, Channel $i, Runtime %s",dtstr(now,'short');
# 	$cmd=sprintf"print F$i \"%s\\n\"",$cmd;
# 	#print"$cmd\n";
# 	eval $cmd;
# 	$cmd=sprintf("print F%d \"nrec  shad  shlim yyyy MM dd hh mm ss g s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23\\n\";",$i);
# 	eval $cmd;
# }
# 
	# LIST ALL PRPDECODE FILES
@w= `ls $datapath/data/data*/prpdecode*.txt`;
#foreach (@w){chomp($str=$_); print"$str\n" } die;
if ($#w < 0 ) { print"Error, no raw files\n"; exit 1}
	#  PROCESS RAW FILES
	# FIND THE FIRST RAW FILE 
foreach $frw (@w){
	chomp($frw);
	print"OPEN $frw\n";
	open(FIN,$frw) or die;
	# READ EACH RECORD
	while (<FIN>) {
		chomp($str=$_);
		$str=~s/[#\n\r]+//g;
# 		print"STRING: $str\n";
		@r=split /[\s]+/g,$str;
		#$i=0; foreach $rx (@r){print"$i, $rx\n";$i++} die;
			# Mode 0==low, 1=high no shadow, 2=high shadow
		$Mode=-1;
		if($#r==40 && $r[1]==1){$Mode=1}
		elsif($#r==40 && $r[1]==0){$Mode=0}
		elsif($#r==201 && $r[1]==1){$Mode=2}
		else{$ibad++}

# 		print"Mode $Mode, WIPRR\n";
		$dt=dtstr2dt($r[0]);
# 		printf"%s\n",dtstr($dt,'csv');
		$record{mode}=$r[1];
		$record{thead}=$r[2];
		if($Mode>0){$record{shadow}=$r[25]}else{$record{shadow}=0}
	
			# pitch and roll av[0],av[1]
		for($i=3; $i<=4; $i++){
			$n=0; $x=0;
			if($r[$i]>-20 && $r[$i]<20){
				$n++; $x=$r[$i];
			}
			if($r[$i+11]>-20 && $r[$i+11]<20){
				$n++; $x+=$r[$i+11];
			}
			if($n==0){$x=$missing} else{$x=$x/$n}
			push @av,$x;
		}
			# azimuth av[2]
		$i=5;
			$n=0; $x=0;
			if($r[$i]>=0 && $r[$i]<=360){
				$n++; $x=$r[$i];
			}
			if($r[$i+11]>=0 && $r[$i+11]<=360){
				$n++; $x+=$r[$i+11];
			}
			if($n==0){$x=$missing} else{$x=$x/$n}
			push @av,$x;	
			# 16 bit ADC    av[3]...av[10]
		for($i=6; $i<=13; $i++){
			$n=0; $x=0;
			if($r[$i]>-100 && $r[$i]<4000){
				$n++; $x=$r[$i];
			}
			if($r[$i+11]>-100 && $r[$i+11]<4000){
				$n++; $x+=$r[$i+11];
			}
			if($n==0){$x=$missing} else{$x=$x/$n}
			push @av,$x;
		}
		#$i=0; foreach(@av){printf"debug:%3d %.3f\n",$i,$_; $i++}die;
	
		if($fixedtiltflag == 0){
			%record=(%record,
				p => $av[0]+$pitchcorrection,
				r => $av[1]+$rollcorrection,
				az => $av[2]+$headingcorrection,
			);
		}
		else {
			%record=(%record,
				p => $fixedpitch+0.0001,
				r => $fixedroll+0.0001,
				az => $fixedheading+0.0001
			);
		}
		%record=(%record,
			psp => $av[3],
			pirv => $av[4],
			case => $av[5],
			dome => $av[6],
			batt => $av[10]*$battcal[0]+$battcal[1],
			sw => $av[3]*$pspcal[0]+$pspcal[1],
			pir => $av[4]*$pircal[0]+$pircal[1]
		);
			# T CASE
		if($av[5]<=0){$record{case}=$missing;}
		else {
			$x=log($av[5]);
			$y=$casecal[0]*$x*$x*$x + $casecal[1]*$x*$x + $casecal[2]*$x + $casecal[3];
			if($y<=0){
				$record{tcase}=$missing;
			}else{
				$record{tcase} = 1/$y -273.15;
			}
		}
			# T DOME
		if($av[6]<=0){$record{dome}=$missing;}
		else {
			$x=log($av[6]);
			$y=$domecal[0]*$x*$x*$x + $domecal[1]*$x*$x + $domecal[2]*$x + $domecal[3];
			if($y<=0){
				$record{tdome}=$missing;
			}else{
				$record{tdome} = 1/$y -273.15;
			}
		}
	
		@x = ComputeLongwave($record{pir},$record{tcase},$record{tdome},$Kcoefficient,$sigma,$epsilon,$missing);
		$record{lw}=$x[0];
	
# 		printf"mode = %d\n", $record{mode};
# 		printf"Thead = %.2f\n", $record{thead};
# 		printf"pitch=%.2f\n",$record{p};
# 		printf"roll=%.2f\n",$record{r};
# 		printf"heading=%.2f\n",$record{az};
# 		printf"psp=%.2f  %.2f\n",$record{psp}, $record{sw};
# 		printf"pir=%.2f   %.2f\n",$record{pirv}, $record{pir};
# 		printf"case=%.2f   %.2f\n",$record{case}, $record{tcase};
# 		printf"dome=%.2f   %.2f\n",$record{dome}, $record{tdome};
# 		printf"lw = %.2f\n", $record{lw};
# 		printf"batt=%.2f\n",$record{batt};
			# WIPRR -- PRP BASIC DATA

#$WIPRR,2018,05,14,00,03,15,1,40.8,44.7,10,6.57,361.14,-32.09,17.90,18.15,-5.0,3.0,356.3,13.8*4B
		$str=sprintf"\$WIPRR,%s,%d,%.1f,%.1f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.1f,%.1f,%.1f,%.1f*",
		dtstr($dt,'csv'),$record{mode},$record{thead},$record{shadow},$ShadowRatioThreshold,$record{sw},$record{lw},
		$record{pir},$record{tcase},$record{tdome},$record{p},$record{r},$record{az},$record{batt};
		$str=$str.NmeaChecksum($str);
		print F "$str\n";
		
			# WIPRG -- GLOBAL
		if ( $Mode > 0 ) {
			for($i=27; $i<=33; $i++){
				$n=0; $x=0;
				if($r[$i]>0 && $r[$i]<4000){
					$n++; $x=$r[$i];
				}
				if($r[$i+7]>0 && $r[$i+7]<4000){
					$n++; $x+=$r[$i+7];
				}
				if($n==0){$x=$missing} else{$x=$x/$n}
				$cmd=sprintf"\$record{g%d}=\$x;",$i-26;
				eval $cmd;
			}
				# PRINT OUT
			$str=sprintf"\$WIPRG,%s,%.1f",dtstr($dt,'csv'),$record{shadow};
			for($i=1; $i<=7; $i++){
				$cmd=sprintf"\$str=\$str.sprintf\",%%.1f\",\$record{g%d};",$i;
				#print"cmd = $cmd\n";
				eval $cmd;
			}
			$str=$str."*";
			$str=$str.NmeaChecksum($str);
			print F " $str\n";		
		}
		
			# SWEEPS
		if ( $Mode > 1 ) {
			$i0=41;
			for( $i=1; $i<=7; $i++) {
				$str="\$WIPR".sprintf"%d,%s,%.1f",$i,dtstr($dt,'csv'),$record{shadow};
				for($j=1; $j<=23; $j++){
					$cmd = sprintf("\$record\{a%d%02d\} = \$r\[%d\];",$i,$j,$i0);
					$i0++;
					#print"$cmd\n";
					eval($cmd);
					$cmd=sprintf"\$str=\$str.sprintf\",%%d\",\$record{a%d%02d};",$i,$j;
					#print"$cmd\n";
					eval $cmd;
				}
				$str=$str."*";
				$str=$str.NmeaChecksum($str);
				print F " $str\n";
				#print " $str\n";  #-->> PRINT WIPR1...WIPR7
			}
		}
	}
}
close FR; close FG; 
#close F1; close F2; close F3; close F4; close F5; close F6; close F7; 
exit 0;


exit;

