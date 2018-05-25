#!/usr/bin/perl

use lib "/Users/rmr/Dropbox/swmain/perl";
use perltools::MRutilities;

my $setupfile="0_setup_process.txt";
my $datapath = FindInfo($setupfile,'DATAPATH',':').'/data';
$cmd=sprintf("find %s -name su_*.txt -print",$datapath);
@w=`$cmd`;
chomp($str=$w[$#w]);
print $str;
exit;

