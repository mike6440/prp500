%                     --------------------------------------------------
% Matlab program       a0_setup.m     editdate: 180524
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
global GPSFIXEDFLAG FIXEDLAT FIXEDLON
global FIXEDTILTFLAG FIXEDPITCH FIXEDROLL FIXEDHEADING PITCHCORR ROLLCORR HDGCORR
global SHRATCLEAR

		% PROPER FILES/FOLDERS DEFINED
SETUPFILE = '0_setup_process.txt';
fprintf('setupfile = %s\n',SETUPFILE);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH');
fprintf('DATAPATH = %s\n',DATAPATH);

	% CAL DATA FILE
dpath=[DATAPATH,'/data'];
cmd=sprintf('find %s -name su_*.txt -print',dpath);
[a,b]=system(cmd);
c=strsplit(b);
SUFILE=c{end-1};
disp(['Cal data: ',SUFILE]);

	%=====================
	% PROCESS PARAMETERS
	%=====================
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

GPSFIXEDFLAG = str2num(FindInfo(SETUPFILE,'GPS FIXED FLAG'));
fprintf('GPSFIXEDFLAG %d\n',GPSFIXEDFLAG)
if GPSFIXEDFLAG==1,
	FIXEDLAT = str2num(FindInfo(SETUPFILE,'FIXED LAT',':'));
	fprintf('FIXEDLAT=%.6f\n',FIXEDLAT)
	FIXEDLON = str2num(FindInfo(SETUPFILE,'FIXED LON',':'));
	fprintf('FIXEDLON=%.6f\n',FIXEDLON)
end

%		CLEAR SKY SHADOW RATIO LIMIT: 40
SHRATCLEAR = str2num(FindInfo(SETUPFILE,'SHADOW THRESHOLD'));
fprintf('CLEAR SKY SHADOW RATIO = %.1f\n',SHRATCLEAR);

	%=====================
	% CALIBRATION PARAMETERS
	%=====================
FIXEDTILTFLAG = str2num(FindInfo(SUFILE,'FIXED TILT FLAG',':'));
fprintf('FIXEDTILTFLAG=%d\n',FIXEDTILTFLAG)
if FIXEDTILTFLAG == 1,
	FIXEDPITCH = str2num(FindInfo(SUFILE,'TCM FIXED PITCH',':'));
	fprintf('FIXEDPITCH=%.1f\n',FIXEDPITCH)
	FIXEDROLL = str2num(FindInfo(SUFILE,'TCM FIXED ROLL',':'));
	fprintf('FIXEDROLL=%.1f\n',FIXEDROLL)
	FIXEDHEADING = str2num(FindInfo(SUFILE,'TCM FIXED HEADING',':'));
	fprintf('FIXEDHEADING=%.1f\n',FIXEDHEADING)
	PITCHCORR=0; ROLLCORR=0; HDGCORR=0;
else
	PITCHCORR = str2num(FindInfo(SUFILE,'TCM PITCH CORRECTION'));
	ROLLCORR = str2num(FindInfo(SUFILE,'TCM ROLL CORRECTION'));
	HDGCORR = str2num(FindInfo(SUFILE,'TCM HEADING CORRECTION'));
end
fprintf('pitchcorr = %.1f, rollcorr = %.1f, hdgcorr = %.1f\n',PITCHCORR,ROLLCORR,HDGCORR);

return

