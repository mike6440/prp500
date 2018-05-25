#!/usr/bin/perl -X
# !! = todo

use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use POSIX;
use Getopt::Long;
use File::Basename;

$PROGRAMNAME = 'make_frsr_da0raw';
$VERSION = '1';

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
	# Calibration file
my $infofrsrfile = `last_su.pl`;
print"FRSR INFORMATION FILE $infofrsrfile -- ";
if (! -f $infofrsrfile){print"DOES NOT EXIST. STOP\n"; exit 1}
print"EXISTS.\n"; 
		# SOLFLUX
$str = FindInfo($setupfile,"SOLFLUX PARAMETERS");
print"SOLFLUX PARAMETERS:";
@solfluxparams=split(/[, ]+/,$str);
foreach(@solfluxparams){print"   $_"}
print"\n";
#=======================
#   GPS
#=======================
# During post processing we can use either a fixed position for a land deployment or 
# we can derive a position from a position file that was generated from a co-running
# DAQ program or from a supplement data file such as a SCS GPS raw file.  Special programs
# will be required for each different supplement file.
$FixedLocation = FindInfo($setupfile,"GPS FLAG");
if($FixedLocation == 1){
	$latfix=FindInfo($setupfile,"FIXED LAT",':');
	$lonfix=FindInfo($setupfile,"FIXED LON",':');
	$magvar=FindInfo($setupfile,"FIXED VAR",':');
	printf"USING FIXED LOCATION  LAT=%.6f   LON=%.6f   VAR=%.1f\n",$latfix,$lonfix,$magvar;
}
else {
	$fname = FindInfo($setupfile,"GPS DATA FILE NAME",':');
	$gpsfile = "$timeseriespath/$fname";
	print"GPS RAW FILE $gpsfile -- ";
	if (! -f $gpsfile){print"DOES NOT EXIST. STOP\n"; exit 1}
	print"EXISTS.\n"; 
	open S, $gpsfile or die("FAILS TO OPEN");
	chomp($str=<S>);  print"$str\n";
}

#=======================
# FIXED TILT
#=======================
# The user has an opportunity in post processing to either correct the tilt
# readings collected during the data collection or to substitute a new set
# of fixed tilt/azimuth fixed data.
$FixedTilt = FindInfo($setupfile,"TILT FIXED FLAG",':');
print "TILT FIXED FLAG = $FixedTilt\n";
if($FixedTilt == 1){
	$pitchfix=FindInfo($setupfile,"FIXED PITCH",':');
	$rollfix=FindInfo($setupfile,"FIXED ROLL",':');
	$azfix=FindInfo($setupfile,"FIXED HEADING",':');
	printf"USING FIXED TILT  pitch=%.1f   roll=%.1f   TRUE heading=%.1f\n",$pitchfix,$rollfix,$azfix;
} 
else {
	$pitchcorrection = FindInfo($setupfile,"PITCH CORRECTION",":");
	$rollcorrection = FindInfo($setupfile,"ROLL CORRECTION",":");
	print"TCM CORRECTIONS, pitch=$pitchcorrection, roll=$rollcorrection\n";
}
$missing=-999;
	# MFR TEMP LIMS
$theadmin=FindInfo($setupfile,"THEADMIN");
printf"THEADMIN = %.1f\n", $theadmin;
$theadmax=FindInfo($setupfile,"THEADMAX");
printf"THEADMAX = %.1f\n", $theadmax;
	# SHADOW PROCESS LIMIT
$shadowlimit=FindInfo($setupfile,"SHADOW THRESHOLD");
printf"shadowlimit = %.1f\n", $shadowlimit;

	# OUTPUT da0
	# nrec yyyy MM dd hh mm ss lat lon saz sze sw lw tcase tdome pitch roll az sog cog hdg sol_n sol_d
	#                                  deg deg w/m^2  C      C     deg deg  deg m/s m/s dg     w/m^2
my $outfile = "$timeseriespath/da0raw.txt";
open F, ">$outfile" or die;
print"OUTPUT RAW DA0 FILE: $outfile\n";
printf F "$PROGRAMNAME v$VERSION,  Runtime %s\n", dtstr(now);
print F "nrec shrat yyyy MM dd hh mm ss thead lat lon saz sze sw lw piru tcase tdome pitch roll az sog cog hdg sol_n sol_d\n";

#  OPEN THE PRP_RAW FILE 
$da0file = "$timeseriespath/da0raw_flat.txt";
print"INPUT RAW FLAT FILE $da0file\n";
if (! -f $da0file){print"DOES NOT EXIST. STOP\n"; exit 1} 
open D, $da0file or die("FAILS TO OPEN");
chomp($str=<D>);
chomp($str=<D>);

my $nrec=0;
while(<D>) {
	chomp($str=$_);
	@w=split(/[ ]+/,$str);
	#$i=0; foreach(@w){print"$i  $_\n"; $i++} die;
		# SHADOW CHECK
	#if($w[1] >= $shadowlimit){
	if(1){								# for da0raw take all RR records
			# TIME CHECK
		$dt=datesec($w[3],$w[4],$w[5],$w[6],$w[7],$w[8]);
		if($dt >= $dtstart){
			$shrat=$w[1];
			$thead = $w[10];
				# HEAD TEMP CHECK
			if($thead >= $theadmin && $thead <= $theadmax){
					#===================
					# GPS OR FIXED LOCATION
					#===================
				if($FixedLocation == 1){
					$lat=$latfix;  $lon=$lonfix;
					$sog=0;  $cog=0;
				} 
				else {
						# SKIM THE GPS FILE FOR THE RIGHT TIME
						# FOR FIXED SITE USE PROCESS-INFO
					$dts=0;
					while($dts < $dt){
						chomp($str=<S>); $str =~ s/^\s+//;  @s=split(/[ ]+/,$str);
						#$i=0; foreach(@s){print"$i  $_\n"; $i++}
						$dts=datesec($s[1],$s[2],$s[3],$s[4],$s[5],$s[6]);
					}
					printf"da0 time = %s,  gps time = %s\n", dtstr($dt), dtstr($dts);
					die;
					if(abs($dt-$dts) > 120 ){
						$lat=$lon=$sog=$cog=$missing;
					} else {
						$lat=$s[7];  $lon=$s[8];  $sog=$s[9];  $cog=$s[10]; 
					}
				}
				
				# TILT - pitch, roll, tcmaz;
				# !! todo - allow an outside data file here
				if($FixedTilt==0){
					$pitch=$w[16]+$pitchcorrection;
					$roll=$w[17]+$rollcorrection;
					$tcmaz=$w[18]+$azcorrection;
				}
				else {
					$pitch=$pitchfix;
					$roll=$rollfix;
					$tcmaz=$azfix;
				}
				
				# RAD
				$sw = $w[11];
				$lw = $w[12];
				$pir = $w[13];
				$tc = $w[14];
				$td = $w[15];
				
				#============
				#  DERIVED VARIABLES
				#============
				($saz,$ze,$ze0) = Ephem($lat, $lon, $dt);
				($In,$Id) = solflux($ze,@solfluxparams);
				#printf"solar az=%.1f, zenith=%.1f, Corrected zenith=%.1f\n",$saz,$ze,$ze0;
				#printf"Theoretical Solflux  sw direct=%.1f, diffuse=%.1f\n",$In, $Id;
			
				#==============
				# OUTPUT FILE
				#print F "nrec shrat yyyy MM dd hh mm ss thead lat lon saz sze sw lw piru tcase tdome pitch roll az sog cog hdg sol_n sol_d\n";
				#==============
				$str=sprintf "$w[0] $shrat %s  %.1f  %.6f %.6f  %.1f %.1f  %.2f %.2f  %.2f  %.2f  %.2f  %.1f  %.1f  %.1f  %.1f  %.1f  %.1f  %.1f  %.1f",
					dtstr($dt,'ssv'), $thead, $lat,$lon,$saz,$ze,$sw,$lw,$pir,$tc,$td,$pitch,
					$roll,$tcmaz,$sog,$cog,$hdg,$In,$Id;
				print F "$str\n";
				$nrec++;
			}
		}
	}
	if($dt > $dtend ){last}
}

close F; close D;  close S; close T;

exit 0;

