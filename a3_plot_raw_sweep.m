% PLOT A SWEEP

global DATAPATH IMAGEPATH TIMESERIESPATH

chan=7;
ix=9000;
str=sprintf('d%drw',chan);
%if ~exist(str),
	cmd=sprintf('load %s/da%d_flat.mat; d=d%drw;',TIMESERIESPATH,chan,chan);
	disp(cmd); eval(cmd);
%end

	% FIND INDEX TO A CLEAR TIME
%if exist('d2rw'), d=d2rw; clear d2rw; end
%ix = find(d.shad>50);
%ix=ix(1);

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
plot(8,sw(j,8),'or','markersize',10,'markerfacecolor','r')
plot(12,sw(j,12),'or','markersize',10,'markerfacecolor','r')
plot(16,sw(j,16),'or','markersize',10,'markerfacecolor','r')
end
grid
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
txt=title(tstr);

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
