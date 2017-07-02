clear
a0_setup_process_sweeps
	% GPS GGA
filename=fullfile(TIMESERIESPATH,'gpgga_flat.txt');
arrayname='gps';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'gpgga_flat.mat');
cmd=sprintf('save %s gps',sv);
disp(cmd); eval(cmd);
return
	% DA0RAW_FLAT
filename=fullfile(TIMESERIESPATH,'da0raw_flat.txt');
arrayname='da0rw';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'da0raw_flat.mat');
cmd=sprintf('save %s da0rw',sv);
disp(cmd); eval(cmd);
	% DAG_FLAT
filename=fullfile(TIMESERIESPATH,'dag_flat.txt');
arrayname='grw';
ReadRTimeSeries
sv=fullfile(TIMESERIESPATH,'dag_flat.mat');
cmd=sprintf('save %s grw',sv);
disp(cmd); eval(cmd);
	% DAx_FLAT
for iq=1:7,
	filename=sprintf('%s/da%d_flat.txt',TIMESERIESPATH,iq)
	arrayname=sprintf('d%drw',iq);
	ReadRTimeSeries
	sv=fullfile(TIMESERIESPATH,sprintf('da%d_flat.mat',iq));
	cmd=sprintf('save %s d%drw',sv,iq);
	disp(cmd); eval(cmd);
end


