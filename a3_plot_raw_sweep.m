% PLOT A SWEEP

global DATAPATH IMAGEPATH TIMESERIESPATH

chan=input('Enter channel number: ');
%chan=7;
str=sprintf('da%d',chan);
if ~exist(str),
	cmd=sprintf('load %s/da%d.mat;',TIMESERIESPATH,chan);
	disp(cmd); eval(cmd);
end
cmd=sprintf('d=da%d; clear da%d;',chan,chan);
disp(cmd); eval(cmd);

fprintf('start %s,   end %s.  Specify time (csv):\n',dtstr(d.dt(1),'csv'),dtstr(d.dt(end),'csv'))
str=input('CSV time: ','s');
cmd=sprintf('dts=datenum(%s);',str);
disp(cmd); eval(cmd);  fprintf('You selected %s\n',dtstr(dts,'csv'));

	%===============
	% choose first sweep after input time
	%===============
ix=find(d.dt > dts);
dt=d.dt(ix(1));
ix=ix(1);
fprintf('First sweep at %s\n',dtstr(dt,'csv'));
dt = d.dt(ix);
tstr=sprintf('Chan %d, Sweep %d, %s',chan,ix,dtstr(dt));

	% FILL SWEEP ARRAY
sw = NaN * ones(10,23);
for i=1:10,
	for j=1:23,
		cmd=sprintf('sw(%d,%d) = d.s%d(%d);',i,j,j,ix+i-1);
		eval(cmd);
	end
end

fg=figure('position',[20,50,1000,700],...
	'papersize',[7.5,5.2],'paperposition',[.4,.3,6.8,4.6]);
hold on
ij=[1:23];
for j=1:10,
pl = plot(ij,sw(j,:),'.b','markersize',10);
pl2 = plot(ij,sw(j,:),'-');
plot(7,sw(j,7),'or','markersize',10,'markerfacecolor','r')
plot(12,sw(j,12),'or','markersize',10,'markerfacecolor','r')
plot(16,sw(j,16),'or','markersize',10,'markerfacecolor','r')
end
grid
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
txt=title(tstr);
str=sprintf('Shadow ratio = %.1f',d.shad);
txt=text(0,0,str);
set(txt,'
cmd=sprintf('saveas(gcf,''%s/sweep_chan%d_%d_%s.png'',''png'')',IMAGEPATH,chan,ix,dtstr(d.dt(ix),'short'));
disp(cmd); eval(cmd);

%
%set(gca,'fontname','arial','fontweight','bold','fontsize',14);
%str=sprintf('FRSR 1-MIN SWEEP: %s', dtstr(da3av.dt(k0),'short'));
%tx=title(str);
%xlabel('Bin Number');
%ylabel('Signal');
%grid
%
%plname=fullfile(REPORTPATH,'img','sweeps.png');
%cmd=sprintf('saveas(gcf,''%s'',''png'');',plname);
%disp(cmd);   eval(cmd)
