%chan=6;
%lgly=1;
cmd=sprintf('filename=''%s/Langley%d-chan%d.txt'';',TIMESERIESPATH,lgly,chan);
eval(cmd)
arrayname='ly';
ReadRTimeSeries
am=1./cos(ly.sze*pi/180);
lg=log(ly.normal);
ix=find(am>=2);
size(ix)
lg=lg(ix);
am=am(ix);
close all
plot(am,lg,'r.','markersize',8);
cmd=sprintf('saveas(gcf,''%s/ly%d-%d_am_v_lg.pdf'',''pdf'');',IMAGEPATH,lgly,chan);
eval(cmd);
p=polyfit(am,lg,1);
lg0=polyval(p,1);
v0 = exp(lg0)