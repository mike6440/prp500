global SERIES DATAPATH TIMESERIESPATH IMAGEPATH 
global LATRANGE LONRANGE TEMPRANGE STARTTIME ENDTIME


%trackplot(dt,lat,lon, LON, LAT),


if ~exist('da0f'),
	disp('LOAD MAT FILE')
	load(fullfile(TIMESERIESPATH,'da0_flat.mat'))
end
%nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt

	% INPUT VOLTAGE
dt=da0f.dt;
x=CleanSeries(da0f.batt,[0,50]);
ViewSeries(dt,x);
title(sprintf('%s   RAW INPUT VOLTAGE',SERIES));
xx=ScrubSeries(x);
str=sprintf('VOLTAGE IN mean=%.2f, stdev=%.2f',mean(xx),std(xx));
disp(str);
tx=text(0,0,str);set(tx,'units','normalized','position',[.05,.3]);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
saveas(gcf,fullfile(IMAGEPATH,'raw_Vin.png'),'png');
pause
close all

	% SW and LW
ViewSeries(da0f.dt,da0f.sw,da0f.lw);
title(sprintf('%s, RAW SW(blu), LW(red)',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_sw_lw.png'),'png');
pause
close all

	% TCASE AND TDOME
ViewSeries(da0f.dt,da0f.tcase,da0f.tdome);
title(sprintf('%s   RAW TCASE(blu), TDOME(red)',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_tcase_tdome.png'),'png');
pause
close all

	% TDOME-TCASE DIFFERENCE
ViewSeries(da0f.dt,da0f.tdome-da0f.tcase);
title(sprintf('%s   RAW TDOME - TCASE',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_tdome-tcase.png'),'png');
pause
close all

	% PITCH ROLL
dt=da0f.dt;
x=CleanSeries(da0f.pitch,[-90,inf]);
y=CleanSeries(da0f.roll,[-90,inf]);
ViewSeries(dt,x,y);
title(sprintf('%s   RAW PITCH(blue)  ROLL(red)',SERIES));
xx=ScrubSeries(x);
str=sprintf('pitch mean=%.2f, stdev=%.2f',mean(xx),std(xx));
disp(str);
tx=text(0,0,str);set(tx,'units','normalized','position',[.05,.9]);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
xx=ScrubSeries(y);
str=sprintf('roll mean=%.2f, stdev=%.2f',mean(xx),std(xx));
disp(str);
tx=text(0,0,str);set(tx,'units','normalized','position',[.05,.85]);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
saveas(gcf,fullfile(IMAGEPATH,'raw_pitch_roll.png'),'png');
pause
close all

	% MFR TEMPERATURE
dt=da0f.dt;
x=CleanSeries(da0f.th,[0,70]);
ViewSeries(dt,x);
title(sprintf('%s   RAW MFR HEAD TEMPERATURE',SERIES));
xx=ScrubSeries(x);
str=sprintf('MFR TEMPERATURE mean=%.2f, stdev=%.2f',mean(xx),std(xx));
disp(str);
tx=text(0,0,str);set(tx,'units','normalized','position',[.05,.3]);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
saveas(gcf,fullfile(IMAGEPATH,'raw_mfr_temp.png'),'png');
pause




return

