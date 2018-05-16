#!/usr/bin/perl -X
#6_frsr_proc_dax_raw.pl
#edge offset = +/- 6
# aerosol file
#nrec  yyyy MM dd hh mm ss lat        lon        shrat sog cog hdg pitch roll saz  sze sazrel szerel d_sun       d_ref    toa      amass kze      n      d       od   rayleigh ozone aod
#39683 2014 06 04 22 27 51 31.837375 134.285085  21.7  0.6 161 0   1.0    0.6 80.4 60.5 79.8    60.1  1.014450 0.999989  2009.2   2.029  0.973   1565.8 343.0  0.123  0.0616 0.0087  0.0526

# v4=do not scale until the end
# v5= Langleys, see v5 comments below

use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use POSIX;
use File::Basename;

$PROGRAMNAME = 'frsr_proc_dax_raw';
$VERSION = '5';

my $setupfile="0_setup_process.txt";
		# DATAPATH 
my $datapath = FindInfo($setupfile,'DATAPATH',':');
my $timeseriespath=$datapath.'/timeseries';
$setupfile=$datapath.'/process_info/su.txt';
		# START AND END TIMES
$str = FindInfo($setupfile,'STARTTIME');
my @k=split /[ ,]+/,$str;
$dtstart = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
$str = FindInfo($setupfile,'ENDTIME');
@k=split /[ ,]+/,$str;
$dtend = datesec($k[0],$k[1],$k[2],$k[3],$k[4],$k[5]);
printf "START %s   END %s\n",dtstr($dtstart), dtstr($dtend);

		# DEFINE VARIABLES
$ktest = 0;
use constant NO => 1;
use constant YES => 0;
use constant MISSING => -999;
use constant D2R => 0.01745329;
my $missing = -999;
my @Langley;  my @Lamp;

	# PROCESS_INFO_FRSR FILE
my $infofrsrfile = $datapath.'/process_info/frsr.txt';
print"FRSR INFORMATION FILE $infofrsrfile -- ";
if (! -f $infofrsrfile){print"DOES NOT EXIST. STOP\n"; exit 1}
print"EXISTS.\n"; 

$missing=-999;

		# shadowlimitaod
$shadowlimitaod=FindInfo($infofrsrfile,"AOD SHADOW LIMIT",':');
printf"AOD SHADOW LIMIT = $shadowlimitaod\n";

		# EDGE OFFSET
$edgeoffset = FindInfo($infofrsrfile,"EDGE INDEX OFFSET",':');
print"EDGE INDEX OFFSET = $edgeoffset\n";

$langleyflag = FindInfo($infofrsrfile,"LANGLEY FLAG");
print"LANGLEY FLAG = $langleyflag\n";

#=============================
# OPEN FRSR DA0 -- F0 
#=============================
$f0="$timeseriespath/da0raw.txt";
#print"INPUT DA0 FILE = $f0 -- ";
if( ! -f $f0 ) {print"INPUT DA0 FILE = $f0 DOES NOT EXIST. STOP.\n"; exit 1}
open F0,"$f0" or die;
	# TWO HEADER LINES
chomp($str=<F0>);
chomp($str=<F0>); 

#=============================
# OPEN OUTPUT Rx,  INPUT Fx  AOD -- Ax
#=============================
for($ic=1; $ic<=7; $ic++){
	$fn="$timeseriespath/da".$ic."rw.txt" ;
	#print"FRSR OUT FILE $fn\n";
	eval "open R".$ic.",\">\$fn\" or die;";
	eval "print R".$ic." \"nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal\\n\";";
	
	if($ic > 1){
		if($langleyflag==1){$fn="$timeseriespath/aodL".$ic."rw.txt"}
		else {$fn="$timeseriespath/aodC".$ic."rw.txt"}
		#print"OPEN AOD OUT FILE $i, $fn\n";
		eval "open A".$ic.",\">\$fn\" or die;";
		eval "print A".$ic." \"nrec yyyy MM dd hh mm ss lat lon shrat sog cog hdg pitch roll saz sze sazrel szerel d_sun d_ref toa amass kze n d od rayleigh ozone aod\\n\";";	
	}
	
	$fn="$timeseriespath/da".$ic."_flat.txt" ;
	if( ! -f $fn ) {print"FRSR INPUT FILE $fn -- DOES NOT EXIST. STOP.\n"; exit 1}
	eval "open F".$ic.",\"<\$fn\" or die;";
	eval "chomp(\$str=<F".$ic.">);"; 
	eval "chomp(\$str=<F".$ic.">);"; 
}

#=============================
# DATA FOR AOD COMPUTATION
#=============================
my @lines=(); my @I0=(); my @I0err=(); 
my @w=();

	# SOLAR DISTANCE RATIO
$dt = 0.5 * ($dtstart+$dtend);
printf"--> Dratio at time %s\n",dtstr($dt);
@w = SunDistanceRatio( $dt );
$Dratio = $w[0];
$dt_I0 = datesec(2001,10,5,0,0,0);  # Thiullier
@w = SunDistanceRatio( $dt_I0 );
$Dratio_ref = $w[0];
printf"--> SunDistanceRatio referenced to Thiullier2002 time: %s\n", dtstr($dt_I0,'ssv');
printf"--> SOLAR DISTANCE RATIO Dratio=%.6f,   Dratio_ref=%.6f\n", $Dratio, $Dratio_ref;

		# TOA  I0(0:5) 
@lines = FindLines($infofrsrfile, 'LOWER  CENTER  UPPER', 6);
#foreach (@lines){print"  $_\n"}
for ($i=1; $i<=6; $i++) {
	chomp($str=$lines[$i]);
	#print"line $i, $str\n";
	$str =~ s/^\s+//; $str =~ s/\s+$//;
	my @w = split(/[\s,]+/, $lines[$i]);
	push(@I0, $w[4]);
	push(@I0err, ($w[5]-$w[3])/2);
}
#print"--> I0 = @I0\n";
#print"--> THIULLIER VALUES (W/m^2)
#       I0=0    I0err\n";
for ($i=0; $i<=5; $i++) {
	printf"     %.3f     %.3f \n", $I0[$i], $I0err[$i];
}

# LANGLEY FLAG: 0
# LANGLEY V0: tbd--1593.5, 774.6, 574.7, 332.7, 354.9,191
# LAMP V0: 3083.7,2714.2, 2983.4, 3563.2, 3755.8, 6472.1
	# LANGLEY(0:5) -- already corrected for solar-earth distance
my @Langley=();
$str = FindInfo($infofrsrfile,'LANGLEY V0',':');
@w = split /[, ]+/,$str;
foreach $x (@w){push @Langley,$x}
print"Langley = @Langley\n";

	# LAMP(0:5) -- correct for earth distance
my @Lamp=();
$str = FindInfo($infofrsrfile,'LAMP V0',':');
@w = split /[, ]+/,$str;
foreach $x (@w){
	push @Lamp, $x * ( $Dratio_ref * $Dratio_ref ) / ( $Dratio * $Dratio );
}
#print"Lamp = @Lamp\n";

if($langleyflag == 1) {@Vtoa=@Langley} else {@Vtoa=@Lamp};

print"    TOA  CHAN    lamp    langley     V0\n";
for($i=0; $i<=5; $i++){printf "          %d    %.3f    %.3f    %.3f\n",$i+2, $Lamp[$i],$Langley[$i],$Vtoa[$i];};

$prprxfile=$datapath.'/process_info/prprx_11_1506.txt';


# GET THE HEAD CALIBRATION NUMBERS
@headcal1=(); @headcal2=();
@lines=FindLines($prprxfile,'HEAD CALIBRATION CONSTANTS, MFR HEAD',7);
#foreach (@lines){print"  $_\n"}
for($i=1; $i<=7; $i++){
	chomp($str=$lines[$i]);
	$str =~ s/^\s+//; $str =~ s/\s+$//;
	@w=split /[ ]+/, $str;
	push(@headcal1,$w[0]);
	push(@headcal2,$w[1]);
}
# print"--> HEAD CALIBRATION 
#      CHAN   GAIN     OFFSET\n";
# for($i=0; $i<=6; $i++){printf "     %d, %.4e,  %.4e\n",$i+1, $headcal1[$i], $headcal2[$i];};

$day0=0;

# READ EACH RECORD OF FRSR DA0 FILE 
#nrec shrat yyyy MM dd hh mm ss thead lat lon saz sze sw lw piru tcase tdome pitch roll az sog cog hdg sol_n sol_d
while(<F0>){
	chomp($str=$_); 
	@w0=split/[\s]+/,$str;
	#$ix=0; foreach(@w0){print"$ix, $w0[$ix]\n"; $ix++;}
	$nrec=$w0[0];

	$dt0=datesec($w0[2],$w0[3],$w0[4],$w0[5],$w0[6],$w0[7]);
	if($w0[4] != $day0){print"day $w0[4]\n"; $day0=$w0[4]}
	
	$shrat=$w0[1];
	$lat=$w0[9];
	$lon=$w0[10];
	$sz=$w0[12];
	$saz=$w0[11];
	$pitch=$w0[18];
	$roll=$w0[19];
	$sog=$w0[21];
	$cog=$w0[22];
	$hdg=$w0[23];
	$sol_n=$w0[24];
	$sol_d=$w0[25];

	# SOLAR DATA FOR AOD CALCULATIONS
	# SZ, SAZ, PITCH, ROLL ==>> SZREL, SAZREL
	($szrel,$sazrel) = RelativeSolarVector ( $sz, $saz, $hdg, $pitch, $roll);
	#printf"--> RelativeSolarVector ( saz=$saz, sz=$sz, hdg=$hdg, pitch=$pitch, roll=$roll) = (szrel=%.2f, sazrel=%.2f)\n",$szrel, $sazrel;
	
	#=============
	# CHANNELS 1--7 
	#=============
	for($ic=2; $ic<=7; $ic++){  #test
	
		# OUTPUT FILE == R
		eval "open R,\">>\$fn{R".$ic."}\" or die;";
		print R "testing for  chan $ic\n";
		#close R;

		# SYNCHRONIZE
		do {
			eval "chomp(\$str=<F".$ic.">);"; 
			@a = split /[ ]+/,$str;
			$dt=datesec($a[3],$a[4],$a[5],$a[6],$a[7],$a[8]);
		} while ($dt<$dt0);
		#$ix=0; foreach(@a){print"test $ix, $a[$ix]\n"; $ix++;}
		$global=$a[9];
		#printf"--> GLOBAL = %.3f\n",$global;

		$i1=10; $i2=32;
		# MINIMUM
		$x=1e6;  my $imin;
		for($ix=$i1; $ix<=$i2; $ix++){
			if($a[$ix]>0 && $a[$ix] < $x){$x=$a[$ix]; $imin=$ix}
		}
		#print"--> MINIMUM: INDEX = $imin, SHADOW = $x\n";
		$shadow=$x;
		
		# EDGE VALUES
		$edge=-999;
		$ied1=$imin-$edgeoffset;   $ied2=$imin+$edgeoffset;
		if($ied1<$i1){ $ed1=-999; } else { $ed1=$a[$ied1]; }
		if($ied2>$i2) { $ed2=-999; } else { $ed2=$a[$ied2];}
		$x=$i=0; if($ed1>0){$x+=$ed1; $i++;}  if($ed2>0){$x+=$ed2; $i++;} 
		if($i<=0){
			$ix=0; foreach(@a){print"test $ix, $a[$ix]\n"; $ix++;}
			print"--> Edge problem: ied=($ied1,$ied2),  ed1=$ed1, ed2=$ed2\n";
			exit 1;
		} else {
			$edge = $x / $i;
			#print"--> EDGE: ied=($ied1,$ied2),  ed1=$ed1, ed2=$ed2, edge=$edge\n";
		}
		
		# NORMAL, DIFFUSE, 
		$horiz = $edge - $shadow;
		$diffuse = $global - $horiz;
		$normal = $horiz / cos( $szrel * D2R );
		#printf"--> IRRADIANCES: HORIZ = %.3f,   DIFFUSE = %.3f,   NORMAL = %.3f\n",$horiz,$diffuse,$normal;
		
		#=============
		# WRITE RAD RECORD
		#=============
		#"nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal\\n\";",$i;
		$str=sprintf"%d %s  %.6f %.6f  %.1f %.1f  %.1f  %.1f   %.1f %.1f %.1f   %.4f %.4f %.4f %.4f",
			$nrec,dtstr($dt0,'ssv'),$lat,$lon,$sz,$saz,$shrat,$shadow,$ed1,$ed2,$edge,$horiz,$global,$diffuse,$normal;
		# PRINT STRING see line 
		eval "print R".$ic." \"\$str\\n\";";
		#print"--> $str\n";

		#===============
		# AOD   $ic = 2-7
		#===============
		if ( $ic >= 2 &&  $sz < 90 && $sz > 0 
			&& $saz >= 0 && $saz <= 360   && $lat > -90 && $lat <= 90 
			&& $hdg >= 0 && $hdg < 360 && $normal > 0 ) {								

					# RAYLEIGH AOD, input chan 2-7
			my $rayleigh = aod_rayleigh( $ic );
			##print"--> RAYLEIGH = $rayleigh\n";

					# OZONE ( input ichan =1-6 )
			my ($ozone, $dob) = aod_ozone( $dt, $lat, $ic );
			##printf"--> OZONE %.4f   DOBSON %.4f\n",$ozone, $dob;

					# ATM MASS
			my $amass = AtmMass($sz);
			##printf"--> ZENITH ANGLE %.1f   	ATMOS MASS %.3f\n", $sz, $amass;

					# kze, local ze correction (input ichan 2-7)
			my $kze = ZeError($infofrsrfile, $szrel, $sazrel, $ic);
			if($kze > 0) { $normalc = $normal / $kze }
			##printf"--> NORMAL CORRECTION %.4f   UNCORRECTED %.4f,  CORRECTED %.4f \n",$kze, $normal, $normalc;

			# OD TOTAL
			##printf"--> COMPUTE OD: NORMAL(corr) %.4f  AMASS %.4f   VTOA %.4f\n", $normalc, $amass, $Vtoa[$ic-2];
			$od = (log($Vtoa[$ic-2]) - log($normalc) ) / $amass;
			##printf"--> TOTAL OD: %.4f\n", $od;

			# AOD
			my $aod = $od - $rayleigh - $ozone;							
			##printf"--> AOD:  %.4f\n", $aod;

					# OUTPUT LINE
			# "nrec yyyy MM dd hh mm ss lat lon shrat sog cog hdg pitch roll saz sze sazrel szerel 
			$str= sprintf("%d %s %.6f %.6f  %.1f  %.1f %.0f %.0f   %.1f %.1f %.1f %.1f %.1f %.1f  ",
				$nrec,dtstr($dt0,'ssv'),$lat,$lon,$shrat,$sog,$cog,$hdg,$pitch,$roll,$saz,$sz,$sazrel,$szrel);

			# d_sun d_ref toa 
			$str=$str.sprintf"  %.6f %.6f  %.1f  ",$Dratio, $Dratio_ref, $Vtoa;

			# amass, kze, n, d, od rayleigh ozone aod_f
			$str=$str.sprintf" %.3f  %.3f   %.1f %.1f  %.3f  %.4f %.4f  %.4f",$amass, $kze, $normalc, $diffuse, $od, $rayleigh, $ozone, $aod; 

			# PRINT STRING see line 
			eval sprintf("print A%d \"$str\\n\"", $ic); 
			#print"--> nrec yyyy MM dd hh mm ss lat lon shadow sog cog hdg pitch roll saz sze sazrel szerel d_sun d_ref toa amass kze n d od rayleigh ozone aod\n";
			#print"--> A$ic -- $str\n";
		}
	}
}
for($ic=1; $ic<=7; $ic++){
	eval "close R".$ic.";";
	eval "close A".$ic.";";
}	
exit 0;

