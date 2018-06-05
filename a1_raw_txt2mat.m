global SERIES DATAPATH TIMESERIESPATH IMAGEPATH 
global LATRANGE LONRANGE TEMPRANGE STARTTIME ENDTIME
global GPSFIXEDFLAG FIXEDLAT FIXEDLON
global FIXEDTILTFLAG FIXEDPITCH FIXEDROLL FIXEDHEADING PITCHCORR ROLLCORR HDGCORR
global SHRATCLEAR

	% DA0_FLAT
filename=fullfile(TIMESERIESPATH,'da0_flat.txt');
arrayname='da0f';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'da0raw_flat.mat');
cmd=sprintf('save %s da0f',sv);
disp(cmd); eval(cmd);
	% DA0
filename=fullfile(TIMESERIESPATH,'da0.txt');
arrayname='da0';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'da0.mat');
cmd=sprintf('save %s da0',sv);
disp(cmd); eval(cmd);

	% DAx_FLAT
for iqxx=1:7,
	fprintf('iqxx=%d\n',iqxx);
	filename=sprintf('%s/da%d_flat.txt',TIMESERIESPATH,iqxx);
	arrayname=sprintf('da%d',iqxx);
	ReadRTimeSeries
	sv=sprintf('%s/da%d.mat',TIMESERIESPATH,iqxx);
	disp(sv);
	cmd=sprintf('save %s %s',sv,arrayname);
	disp(cmd); eval(cmd);
end
return


	% GPS GGA
if GPSFIXEDFLAG > 0, 
	disp('FIXED POSITION');
else
	filename=fullfile(TIMESERIESPATH,'gpgga_flat.txt');
	arrayname='gps';
	%ReadRTimeSeries
	sv=fullfile(TIMESERIESPATH,'gpgga_flat.mat');
	cmd=sprintf('save %s gps',sv);
	disp(cmd); %eval(cmd);
end
	% DAG_FLAT
filename=fullfile(TIMESERIESPATH,'dag_flat.txt');
arrayname='grw';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'dag_flat.mat');
cmd=sprintf('save %s grw',sv);
disp(cmd); eval(cmd);


