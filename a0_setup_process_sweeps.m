%                     --------------------------------------------------
% Matlab program       a0_setup_prp_process.m     editdate: 2014 05 15
%                     --------------------------------------------------
% Prepares the matlab workspace for prp and frsr processing.
%
%--------------------------------------
%BEFORE RUNNING
%--------------------------------------
%1. Run PERL programs 0-6 completely. Run with '?' parameter and follow instructions.
%2. Be sure the matlab path includes the rmrtools folder of matlab scripts.
%

clear
clear global

global SERIES DATAPATH TIMESERIESPATH IMAGEPATH 
global LATRANGE LONRANGE TEMPRANGE STARTTIME ENDTIME

%global PRPMODULES PRPRAWMODULES
%global STARTTIME ENDTIME AVGTIME MATPATH
%global REPORTPATH
%global SHRATCLEAR SHRATSTDCLEAR  % we compute x=100*shratstd/shrat. a nominalized value.  We only accept dta where x<SHRATSTDCLEAR.
%global GPSFIXEDFLAG FIXEDLAT FIXEDLON
%global TILTFIXEDFLAG FIXEDPITCH FIXEDROLL FIXEDHEADING PITCHCORR  ROLLCORR


		% PROPER FILES/FOLDERS DEFINED
SETUPFILE = '0_setup_process.txt';
fprintf('setupfile = %s\n',SETUPFILE);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH');
fprintf('DATAPATH = %s\n',DATAPATH);

SETUPFILE = fullfile(DATAPATH,'process_info','su.txt');
fprintf('setupfile = %s\n',SETUPFILE);

SERIES = FindInfo(SETUPFILE,'SERIES');
fprintf('SERIES = %s\n',SERIES);

TIMESERIESPATH = fullfile(DATAPATH,'timeseries');
fprintf('TIMESERIESPATH = %s\n',TIMESERIESPATH);

IMAGEPATH = fullfile(DATAPATH,'images');
fprintf('IMAGEPATH = %s\n',IMAGEPATH);

str=FindInfo(SETUPFILE,'LATRANGE');
c=textscan(str,'%f,%f');
LATRANGE=[c{1};c{2}];

str=FindInfo(SETUPFILE,'LONRANGE');
c=textscan(str,'%f,%f');
LONRANGE=[c{1};c{2}];

str=FindInfo(SETUPFILE,'TEMPRANGE');
c=textscan(str,'%f,%f');
TEMPRANGE=[c{1};c{2}];

str = FindInfo(SETUPFILE, 'STARTTIME');
cmd=sprintf('STARTTIME=datenum(%s);', str);
eval(cmd);
fprintf('STARTTIME = %s\n',dtstr(STARTTIME));

str = FindInfo(SETUPFILE, 'ENDTIME');
cmd=sprintf('ENDTIME=datenum(%s);', str);
eval(cmd);
fprintf('ENDTIME = %s\n',dtstr(ENDTIME));


%SUFILE = fullfile(DATAPATH,'process_info','su.txt');
%fprintf('SETUP FILE = %s\n', SUFILE);
%
%FRSRINFO = fullfile(DATAPATH,'process_info','frsr.txt');
%fprintf('FRSR INFO FILE = %s\n', FRSRINFO);
%
%
%GPSFIXEDFLAG = str2num(FindInfo(SUFILE,'GPS FIXED FLAG',':'));
%fprintf('GPSFIXEDFLAG=%d\n',GPSFIXEDFLAG)
%if GPSFIXEDFLAG == 1,
%	FIXEDLAT = str2num(FindInfo(SUFILE,'FIXED LATITUDE',':'));
%	fprintf('FIXEDLAT=%.6f\n',FIXEDLAT)
%	FIXEDLON = str2num(FindInfo(SUFILE,'FIXED LONGITUDE',':'));
%	fprintf('FIXEDLON=%.6f\n',FIXEDLON)
%end
%
%TILTFIXEDFLAG = str2num(FindInfo(SUFILE,'TILT FIXED FLAG',':'));
%fprintf('TILTFIXEDFLAG=%d\n',TILTFIXEDFLAG)
%if TILTFIXEDFLAG == 1,
%	FIXEDPITCH = str2num(FindInfo(SUFILE,'FIXED PITCH',':'));
%	fprintf('FIXEDPITCH=%.1f\n',FIXEDPITCH)
%	FIXEDROLL = str2num(FindInfo(SUFILE,'FIXED ROLL',':'));
%	fprintf('FIXEDROLL=%.1f\n',FIXEDROLL)
%	FIXEDHEADING = str2num(FindInfo(SUFILE,'FIXED HEADING',':'));
%	fprintf('FIXEDHEADING=%.1f\n',FIXEDHEADING)
%	PITCHCORR=0; ROLLCORR=0;
%else
%	PITCHCORR = str2num(FindInfo(SUFILE,'PITCH CORRECTION',':'));
%	ROLLCORR = str2num(FindInfo(SUFILE,'ROLL CORRECTION',':'));
%end
%fprintf('pitchcorr = %.1f,   rollcorr = %.1f\n',PITCHCORR,ROLLCORR);

return

x =FindInfo(INFOFILE,'STARTTIME',':');
eval(['STARTTIME = datenum(',x,');']);
[y,M,d,h,m,s]=datevec(STARTTIME);
STARTTIME=datenum(y,M,d,h,m,0);
fprintf('starttime=%s\n',dtstr(STARTTIME))

x =FindInfo(INFOFILE,'ENDTIME',':');
eval(['ENDTIME = datenum(',x,');']);
[y,M,d,h,m,s]=datevec(ENDTIME);
ENDTIME=datenum(y,M,d,h,m,0);
fprintf('endtime=%s\n',dtstr(ENDTIME))


%		CLEAR SKY SHADOW RATIO LIMIT: 40
str = FindInfo(FRSRINFO,'CLEAR SKY SHADOW RATIO LIMIT',':');
SHRATCLEAR = str2num(str);
fprintf('CLEAR SKY SHADOW RATIO = %.1f\n',SHRATCLEAR);

return

