global SERIES DATAPATH TIMESERIESPATH IMAGEPATH 
global LATRANGE LONRANGE TEMPRANGE STARTTIME ENDTIME


if ~exist('gps'),
	load(fullfile(TIMESERIESPATH,'gpgga_flat.mat'));
end
%nrec yyyy MM dd hh mm ss hhmmss lat lon q nsat pre alt he
dt=gps.dt;
lat=CleanSeries(gps.lat,[-45,50]);
lon=CleanSeries(gps.lon,[-180,360]);
ViewSeries(dt,lat);
title(sprintf('%s   LATITUDE',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_latitude.png'),'png');
pause
close all
ViewSeries(dt,lon);
title(sprintf('%s   LONGITUDE',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_longitude.png'),'png');
pause
close all
return
trackplot(dt,lat,lon,[25,37],[125,140]);
return


%function trackplot(dt,lat,lon, LON, LAT),


if ~exist('da0rw'),
	load(fullfile(TIMESERIESPATH,'da0raw_flat.mat'))
end
%nrec shad shlim yyyy MM dd hh mm ss th sw lw pir tcase tdome pitch roll az batt

	% INPUT VOLTAGE
dt=da0rw.dt;
x=CleanSeries(da0rw.batt,[0,50]);
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
ViewSeries(da0rw.dt,da0rw.sw,da0rw.lw);
title(sprintf('%s, RAW SW(blu), LW(red)',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_sw_lw.png'),'png');
pause
close all

	% TCASE AND TDOME
ViewSeries(da0rw.dt,da0rw.tcase,da0rw.tdome);
title(sprintf('%s   RAW TCASE(blu), TDOME(red)',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_tcase_tdome.png'),'png');
pause
close all

	% TDOME-TCASE DIFFERENCE
ViewSeries(da0rw.dt,da0rw.tdome-da0rw.tcase);
title(sprintf('%s   RAW TDOME - TCASE',SERIES));
saveas(gcf,fullfile(IMAGEPATH,'raw_tdome-tcase.png'),'png');
pause
close all

	% PITCH ROLL
dt=da0rw.dt;
x=CleanSeries(da0rw.pitch,[-90,inf]);
y=CleanSeries(da0rw.roll,[-90,inf]);
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
dt=da0rw.dt;
x=CleanSeries(da0rw.th,[0,70]);
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

