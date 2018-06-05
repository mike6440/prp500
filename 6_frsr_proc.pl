#!/usr/bin/perl -X
# da1--7: 	nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal

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

$PROGRAMNAME = $0;
$VERSION = '6';
$EDITDATE = "180527";

my $setupfile="0_setup_process.txt";
my $datapath = FindInfo($setupfile,'DATAPATH',':');
my $timeseriespath=FindInfo($setupfile,'TIMESERIESPATH');
	# RUN TIME SETUP FILE
$sufile=`ls -1 $datapath/data/data*/su*.txt | tail -1`;
chomp $sufile;
print"last setup file = $sufile\n";
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

$missing=-999;
		# shadowlimitaod
$shadowlimitaod=FindInfo($setupfile,"AOD SHADOW LIMIT",':');
printf"AOD SHADOW LIMIT = $shadowlimitaod\n";
		# EDGE OFFSET
$str = FindInfo($setupfile,"EDGE INDEX OFFSET",':');
print"EDGE INDEX OFFSET = $str\n";
my @edgeoffset = split /[, ]+/, $str;
# 
# $numberlangley = FindInfo($setupfile,"NUMBER LANGLY");
# print"NUMBER LANGLY = $numberlangley\n";
# 
# $langleyflag=FindInfo($setupfile,"LANGLEYFLAG");
# print"LANGLEYFLAG = $langleyflag\n";
# 
#=============================
# DATA FOR AOD COMPUTATION
#=============================
	# SOLAR DISTANCE RATIO
# $dt = 0.5 * ($dtstart+$dtend);
# printf"--> Dratio at time %s\n",dtstr($dt);
# @w = SunDistanceRatio( $dt );
# $Dratio = $w[0];
# $dt_I0 = datesec(2001,10,5,0,0,0);  # Thiullier
# @w = SunDistanceRatio( $dt_I0 );
# $Dratio_ref = $w[0];
# printf"--> SunDistanceRatio referenced to Thiullier2002 time: %s\n", dtstr($dt_I0,'ssv');
# printf"--> SOLAR DISTANCE RATIO Dratio=%.6f,   Dratio_ref=%.6f\n", $Dratio, $Dratio_ref;
# 		# TOA  I0(0:5) 
# @lines = FindLines($sufile, 'LOWER  CENTER  UPPER', 6);
# #foreach (@lines){print"  $_\n"} die;
# for ($i=1; $i<=6; $i++) {
# 	chomp($str=$lines[$i]);
# 	#print"line $i, $str\n";
# 	$str =~ s/^\s+//; $str =~ s/\s+$//;
# 	my @w = split(/[\s,]+/, $lines[$i]);
# 	push(@I0, $w[4]);
# 	push(@I0err, ($w[5]-$w[3])/2);
# }
# print"--> I0 = @I0\n";
# print"--> THIULLIER VALUES (W/m^2)
# #       I0=0    I0err\n";
# for ($i=0; $i<=5; $i++) {
# 	printf"     %.3f     %.3f \n", $I0[$i], $I0err[$i];
# }
# 
# 	# LAMP V0 -- correct for earth distance
# my @Lamp=();
# $str = FindInfo($setupfile,'LAMP V0',':');
# @w = split /[, ]+/,$str;
# foreach $x (@w){
# 	push @Lamp, $x * ( $Dratio_ref * $Dratio_ref ) / ( $Dratio * $Dratio );
# }
# print"Lamp = @Lamp\n";
# 
# 	# LANGLEY V0 -- correct for earth distance
# my @Langley=();
# $str = FindInfo($setupfile,'LANGLEY V0',':');
# @w = split /[, ]+/,$str;
# foreach $x (@w){
# 	push @Langley, $x * ( $Dratio_ref * $Dratio_ref ) / ( $Dratio * $Dratio );
# }
# print"Langley = @Langley\n";
# 
# if($langleyflag == 1) {@Vtoa=@Langley} else {@Vtoa=@Lamp};
# 
# print"         CHAN    lamp    langley     V0\n";
# for($i=0; $i<=5; $i++){printf "          %d    %.3f    %.3f    %.3f\n",$i+2, $Lamp[$i],$Langley[$i],$Vtoa[$i];};

# GET THE HEAD CALIBRATION NUMBERS
# @headcal1=(); @headcal2=();
# @lines=FindLines($sufile,'HEAD CALIBRATION CONSTANTS, MFR HEAD',7);
# # foreach (@lines){print"  $_\n"} die;
# for($i=1; $i<=7; $i++){
# 	chomp($str=$lines[$i]);
# 	$str =~ s/^\s+//; $str =~ s/\s+$//;
# 	@w=split /[ ]+/, $str;
# 	push(@headcal1,$w[0]);
# 	push(@headcal2,$w[1]);
# }
# print"--> HEAD CALIBRATION 
#      CHAN   GAIN     OFFSET\n";
# for($i=0; $i<=6; $i++){printf "     %d, %.4e,  %.4e\n",$i+1, $headcal1[$i], $headcal2[$i];};
#=====================
# INPUT FILES
#=====================
#-----------------------
# OPEN INPUT DA0 -- F0 
#  0    1    2    3  4  5  6  7  8     9         10           11    12    13     14
# nrec shrat yyyy MM dd hh mm ss thead lat       lon          saz   sze   sw     lw 
# 50   2.3   2018 05 19 16 20 21 36.1  47.649620 -122.313120  101.3 53.0  157.47 354.42
#    15      16     17     18    19   20    21   22   23   24     25
#    piru    tcase  tdome  pitch roll az    sog  cog  hdg  sol_n  sol_d
#    -30.80  16.86  17.22  0.0   1.0  36.5  0.0  0.0  0.0  888.4  32.1
#-----------------------
$f0="$timeseriespath/da0.txt";
print"INPUT DA0 FILE = $f0\n";
if( ! -f $f0 ) {print"DOES NOT EXIST. STOP.\n"; exit 1}

#------------------------
#  OPEN DAX_FLAT TO READ
#-----------------------
for($ic=1; $ic<=7; $ic++){	
	$cmd=sprintf("open F%d,\"%s/da%d_flat.txt\" or die;",$ic,$timeseriespath,$ic);
	print"$cmd\n";
	eval $cmd;
	eval "\$str=<F$ic>; \$str=<F$ic>;"; 
}

#=============================
# OPEN OUTPUT Rx,  INPUT Fx  AOD -- Ax
#=============================
for($ic=2; $ic<=7; $ic++){
	$fn="$timeseriespath/da".$ic.".txt" ;
	print"FRSR OUT FILE $fn\n";
	eval "open R".$ic.",\">\$fn\" or die;";
	eval "print R".$ic."\"Program $0, Edit $EDITDATE, Runtime \".dtstr(now,'short').\"\n\";";
	eval "print R".$ic." \"nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal\\n\";";
# 	$fnx="$timeseriespath/aod".$ic.".txt" ;
# 	print"AOD OUT FILE $fnx\n";
# 	eval "open A".$ic.",\">\$fnx\" or die;";
# 	eval "print A".$ic."\"Program $0, Edit $EDITDATE, Runtime \".dtstr(now,'short').\"\n\";";
# 	eval "print A".$ic." \"nrec yyyy MM dd hh mm ss lat lon shadow sog cog hdg pitch roll saz sze sazrel szerel d_sun d_ref toa amass kze n d od rayleigh ozone aod\\n\";";
}
#=============================
# OPEN FRSR DA0 -- F0 
#  0    1    2    3  4  5  6  7  8     9         10           11    12    13     14
# nrec shrat yyyy MM dd hh mm ss thead lat       lon          saz   sze   sw     lw 
# 50   2.3   2018 05 19 16 20 21 36.1  47.649620 -122.313120  101.3 53.0  157.47 354.42
#    15      16     17     18    19   20    21   22   23   24     25
#    piru    tcase  tdome  pitch roll az    sog  cog  hdg  sol_n  sol_d
#    -30.80  16.86  17.22  0.0   1.0  36.5  0.0  0.0  0.0  888.4  32.1
open F0,"$f0" or die;
	# TWO HEADER LINES
chomp($str=<F0>);
chomp($str=<F0>); 
my $nread;
	# SEARCH FOR SHRAT >= shadowlimitaod
while(<F0>){
	$nread++;
	chomp($str=$_); 
	@w0=split/[\s]+/,$str;
	#$ix=0; foreach(@w0){print"$ix, $w0[$ix]\n"; $ix++;} die;
	if($w0[1] >= $shadowlimitaod){
		if($nread % 1000 == 0){print"$str\n"}
		#$ix=0; foreach(@w0){print"$ix, $w0[$ix]\n"; $ix++;} die;
		$nrec0=$w0[0];
		$shrat=$w0[1];
		$lat=$w0[9];
		$lon=$w0[10];
		$sz=$w0[12];
		$saz=$w0[11];

		# SOLAR DATA FOR AOD CALCULATIONS
		# SZ, SAZ, PITCH, ROLL ==>> SZREL, SAZREL
#		($szrel,$sazrel) = RelativeSolarVector ( $sz, $saz, $hdg, $pitch, $roll);
		#printf"--> RelativeSolarVector ( saz=$saz, sz=$sz, hdg=$hdg, pitch=$pitch, roll=$roll) = (szrel=%.2f, sazrel=%.2f)\n",$szrel, $sazrel;

		#=============
		# CHANNELS F1--F7 
		#=============
		for($ic=1; $ic<=7; $ic++){  #test
			# SYNCHRONIZE
			do {
				$cmd = sprintf "\$str=<F%d>;",$ic ;
				#print"$cmd\n"; 
				eval $cmd;
				chomp($str); #print"$str\n";
				@a = split /[ ]+/,$str;
				#print"nrec=$a[0]\n";
			} while ($a[0]<$nrec0);
			#print"$ic, Found $ix, $str\n";
			$dt0=datesec($w0[2],$w0[3],$w0[4],$w0[5],$w0[6],$w0[7]);
			#printf"dt0 = %s\n",dtstr($dt0);
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
			$ied1=$imin-$edgeoffset[0];   $ied2=$imin+$edgeoffset[1];
			if($ied1<$i1){ $ed1=-999; } else { $ed1=$a[$ied1]; }
			if($ied2>$i2) { $ed2=-999; } else { $ed2=$a[$ied2];}
			$x=$i=0; if($ed1>0){$x+=$ed1; $i++;}  if($ed2>0){$x+=$ed2; $i++;} 
			if($i<=0){
				#print"$str\n";
				#print"--> Edge problem: ied=($ied1,$ied2),  ed1=$ed1, ed2=$ed2\n";
			} else {
				$edge = $x / $i;
				#print"--> SHADOW: $shadow, EDGE: ied=($ied1,$ied2),  ed1=$ed1, ed2=$ed2, edge=$edge\n";
				# NORMAL, DIFFUSE, 
				$horiz = $edge - $shadow;
				$diffuse = $global - $horiz;
				$normal = $horiz / cos( $szrel * D2R );
				#printf"--> IRRADIANCES: HORIZ = %.3f,   DIFFUSE = %.3f,   NORMAL = %.3f\n",$horiz,$diffuse,$normal;
				#=============
				# WRITE RAD RECORD
				#=============
				#"nrec yyyy MM dd hh mm ss lat lon sze saz shrat shadow edg1 edg2 edge horiz global diffuse normal\\n\";",$i;
				$str=sprintf"%d %s  %.6f %.6f  %.1f %.1f  %.1f  %.1f   %.1f %.1f %.1f   %.1f %.1f %.1f %.1f",
					$nrec0,dtstr($dt0,'ssv'),$lat,$lon,$sz,$saz,$shrat,$shadow,$ed1,$ed2,$edge,$horiz,$global,$diffuse,$normal;
				# PRINT STRING see line 
				eval "print R".$ic." \"\$str\\n\";";
				#print"--> $str\n";
			}
		}
	}
}
close F0;
for($ic=1; $ic<=7; $ic++){
	eval "close R".$ic.";";
}
print "\aDone\n";	
exit 0;

