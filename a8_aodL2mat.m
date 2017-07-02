
clear
global DATAPATH TIMESERIESPATH
for ich=2:7,
	cmd=sprintf('filename=''%s/aodL%drw.txt'';',TIMESERIESPATH,ich);
	disp(cmd); eval(cmd);
	cmd=sprintf('arrayname=''a%dLrw'';',ich);
	disp(cmd); eval(cmd);
	ReadRTimeSeries;
	cmd=sprintf('save %s/aodL%drw.mat a%dLrw;',TIMESERIESPATH,ich,ich);
	disp(cmd); eval(cmd);
end

