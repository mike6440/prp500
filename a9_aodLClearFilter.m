
	% LOAD AOD DATA
global TIMESERIESPATH
if ~exist('a2Lrw','var') 
	disp('LOAD AOD FILES');
	for ich=2:7,
		cmd=sprintf('load %s/aodL%drw.mat',TIMESERIESPATH,ich);
		disp(cmd); eval(cmd);
	end
end

for ich=2:6;
	cmd=sprintf('dt=a%dLrw.dt; aod=a%dLrw.aod;',ich,ich); disp(cmd); eval(cmd);

		% FILTER 1 - REMOVE HIGH VALUES
	ix=find(aod<0.4);
	if length(ix) <= 0, disp('FILTER 1 REMOVES ALL AOD''s'); return; end
	dt=dt(ix); aod=aod(ix);

		% FILTER 2 - STDEV
		% Divide the time into 10-min increments
	dv=10; % minutes
	[y,M,d,h,m,s]=datevec(dt(1)); dt1=datenum(y,M,d,h,dv*fix(m/dv),0);
	[y,M,d,h,m,s]=datevec(dt(end)); dt2=datenum(y,M,d,h,dv*fix(m/dv),0)+1/(1440/dv);
	dtf=[dt1:1/(1440/dv):dt2]';

	eval(sprintf('tf%d=[]; af%d=[];  afstd%d=[]; nstd%d=[];',ich,ich,ich,ich));
		% FOR EACH TIME INCREMENT
	for it=1:length(dtf)-1,
			% end points
		dta=dtf(it); dtb=dtf(it+1);
			% all points in the time increment
		ixf=find(dt>=dta & dt < dtb);
			% each segment with some points
		if length(ixf) >= 80 & std(aod(ixf)) < .01,
			eval(sprintf('nstd%d=[nstd%d; length(ixf)];',ich,ich)); 
			eval(sprintf('afstd%d=[afstd%d; std(aod(ixf))];',ich,ich));  
			cmd=sprintf('af%d=[af%d; mean(aod(ixf))];',ich,ich); eval(cmd);  
			eval(sprintf('tf%d=[tf%d; dta];',ich,ich));
		end
	end 
	
	eval(sprintf('plot(tf%d,af%d,''ob'');',ich,ich));
	grid; datetick
	set(gca,'fontname','arial','fontweight','bold','fontsize',12,'ylim',[0,0.3]);
	eval(sprintf('tx=title(''sgp14-aod%dLrw-filtered'');',ich));
	set(gca,'ylim',[0,0.2]);
	cmd=sprintf('saveas(gcf,''%s/images/sgp14-aod%dLrw-filtered.png'',''png'');',DATAPATH,ich);
	close
end

README=str2mat(...
'These are time series of aod values < 0.4 and with 10-min stdev < 0.01.',...
'  tf = datenum of each sample, chans 2,3,4,5,6.',...
'  af = mean aod in the 10-min segment.');

cmd=sprintf('save %s/aod_best.mat  README tf2 tf3 tf4 tf5 tf6 af2 af3 af4 af5 af6',TIMESERIESPATH);
disp(cmd); eval(cmd);
 

	% SUMMARY PLOT
close all
plot(tf2,af2,'ok');grid; hold on; datetick
plot(tf3,af3,'ob');
plot(tf4,af4,'or');
plot(tf5,af5,'og');
plot(tf6,af6,'oc');
set(gca,'fontname','arial','fontweight','bold','fontsize',12,'ylim',[0,0.3]);
set(gca,'fontname','arial','fontweight','bold','fontsize',12,'ylim',[0,0.2]);
title('sgp14 best aod 416(k) 503(b) 613(r) 673(g) 872(c)')
xlabel('UTC DATE'); ylabel('AOD')
cmd=sprintf('saveas(gcf,''%s/sgp14_aod_clear.png'',''png'')',IMAGEPATH);
disp(cmd); eval(cmd);

return
 
