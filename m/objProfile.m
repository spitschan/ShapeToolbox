function [x1,y1] = objProfile(profiletype,npoints,xscale,yscale,connect,interp)

% OBJPROFILE
%

% Copyright (C) 2016 Toni Saarela
% 2016-05-27 - ts - first version
% 2016-05-28 - ts - polar, improvements, input args
% 2016-05-30 - ts - renamed
% 2016-06-10 - ts - rewritten; implemented moving and deleting points
%                   (lacks polar profile now)
% 2016-06-12 - ts - implemented 'connecting' the ends of the curve
%                   added option for linear interpolation
% 2016-06-14 - ts - started implementing polar, not finished
% 2016-06-17 - ts - option to change axis scale

% TODO:
% Implement polar
% Options as name-value pairs
% Implement 'snap-to-grid'
% Unify variable names across callback functions:
%  - x and xdat etc

if ~nargin || isempty(profiletype)
  profiletype = 'linear';
end

if nargin<2 || isempty(npoints)
  npoints = 64;
end

if nargin<3 || isempty(xscale)
  xscale = 2;
end

if nargin<4 || isempty(yscale)
  yscale = 2*pi;
end

connect_explicit_false = false;
if nargin<5 || isempty(connect)
  connect = false;
elseif ~connect
  connect_explicit_false = true;
end

if nargin<6 || isempty(interp)
   interp = 'spline';
end

if ~any(strcmp({'spline','linear'},interp))
  error('Invalid interpolation type.  Use ''spline'' or ''linear''.');
end

fh = figure;
ah = gca;
switch profiletype
  case 'linear'
    xlim = [0 xscale];
    ylim = [0 yscale];
    axis equal
    set(ah,'XLim',xlim,'YLim',ylim);
    hold on

    if nargin<5 || isempty(connect)
      connect = false;
    end
    
    y = ylim;
    x = xscale/2*[1 1];
    
    y1 = linspace(0,yscale,npoints);
    x1 = interp1(y,x,y1,'spline');
    
    hsmooth = plot(x1,y1,'r-');
    hdat = plot(x,y,'ob','MarkerFaceColor','b');
    drawnow
    
  case 'polar'
    xlim = [-xscale xscale];
    ylim = [-xscale xscale];
    y = [0 pi/2 pi 3*pi/2];
    x = [1 1 1 1];
    hsmooth = [];
    hdat = polar(y,x,'ob');
    set(hdat,'MarkerFaceColor','b');
    set(ah,'XLim',xlim,'YLim',ylim);
    set(ah,'RTick',xscale);
    axis equal
    hold on
    if ~connect_explicit_false
      connect = true;
    end
end

%------------------------------------------------------------
fprintf('Click to add new points, hit enter to quit.\n');
fprintf('Drag to move points.\n');
fprintf('Drag outside axes to delete points.\n');
fprintf('Hit + or - to change the scale of axis.\n');
fprintf('Hit ''r'' if the graph does not refresh automatically.\n');
if exist('OCTAVE_VERSION'), fflush(stdout); end
%------------------------------------------------------------


setappdata(fh,'h',hdat);
setappdata(fh,'hsmooth',hsmooth);

hlate = plot(-100,-100,'ob','MarkerFaceColor','b');
setappdata(fh,'hlatest',hlate);

hmove = plot(-100,-100,'o','MarkerSize',8,...
               'MarkerEdgeColor',[.7 .7 .7],...
               'MarkerFaceColor',[.7 .7 .7]);
setappdata(fh,'hmovepoint',hmove);

setappdata(fh,'npoints',npoints);
setappdata(fh,'connect',connect);
setappdata(fh,'interp',interp);

set(gcf,'windowbuttondownfcn',@starttrackmouse);
set(gcf,'keypressfcn',@keyfunc);

set(0,'userdata',false)
waitfor(0,'userdata',true);

x1 = get(hsmooth,'xdata');

end

%------------------------------------------------------------
% Callback functions below.

function keyfunc(src,data)
  switch data.Key
    case 'return'
      %setappdata(src,'abort',true);
      %fprintf('Enter pressed.\n');
      set(gcf,'windowbuttondownfcn','');
      set(gcf,'windowbuttonupfcn','');
      set(0,'userdata',true);
    case 'plus'
      xlim = get(gca,'XLim');
      xlim(2) = xlim(2) + .5;
      set(gca,'XLim',xlim);
      drawnow
    case 'minus'
      xlim = get(gca,'XLim');
      xlim(2) = xlim(2) - .5;
      set(gca,'XLim',xlim);
      drawnow
    case 'r'
      drawnow
  end
end

function starttrackmouse(src,data)
  h = getappdata(src,'h');
  x = get(h,'xdata');
  y = get(h,'ydata');
  pos = get(gca,'currentpoint');
  dist = sqrt((x-pos(1,1)).^2+(y-pos(1,2)).^2);
  if min(dist)<.2
    idx = find(dist==min(dist));
    xtmp = x(idx);
    ytmp = y(idx);
    hmove = getappdata(src,'hmovepoint');
    set(hmove,'xdata',xtmp,'ydata',ytmp);
    setappdata(src,'newpoint',false);
    setappdata(src,'hmovepoint',hmove);
    setappdata(src,'idx',idx);
  else
    setappdata(src,'newpoint',true);
  end
  set(src,'windowbuttonupfcn',@endtrackmouse);
  set(src,'windowbuttonmotionfcn',@plotpoint);
end

function endtrackmouse(src,data)
  set(src,'windowbuttonmotionfcn','');

  htmp = getappdata(src,'hmovepoint');
  set(htmp,'xdata',[],'ydata',[]);

  htmp = getappdata(src,'hlatest');
  set(htmp,'xdata',[],'ydata',[]);

  con = getappdata(src,'connect');

  h = getappdata(src,'h');
  xdat = get(h,'xdata');
  ydat = get(h,'ydata');
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  pos = get(gca,'currentpoint');
  x = pos(1,1);
  y = pos(1,2);
  offlimits = false;
  if (x<xlim(1) || x>xlim(2)) || (y<ylim(1) || y>ylim(2))
    offlimits = true;
  end
  if getappdata(src,'newpoint') && ~offlimits
    [ydat,idx] = sort([ydat y]);
    xdat = [xdat x];
    xdat = xdat(idx);
  else
    idx = getappdata(src,'idx');
    if offlimits
      if idx>1 && idx<length(xdat)
        xdat(idx) = [];
        ydat(idx) = [];
      end
    else
      if idx>1 && idx<length(ydat)
        ydat(idx) = y;
      end
      xdat(idx) = x;
      if con && idx==1
        xdat(end) = xdat(1); 
      elseif con && idx==length(xdat)
        xdat(1) = xdat(end);
      end
    end
  end
  set(h,'xdata',xdat,'ydata',ydat);

  h = getappdata(src,'hsmooth');
  npts = getappdata(src,'npoints');
  interp = getappdata(src,'interp');
  y1 = get(h,'ydata');

  if con
     xdat = [xdat(1:(end-1)) xdat xdat(2:end)];
     ydat = [ydat(1:(end-1))-ydat(end) ydat ydat(2:end)+ydat(end)];
     y1 = [y1(1:(end-1))-y1(end) y1 y1(2:end)+y1(end)];
     x1 = interp1(ydat,xdat,y1,interp);
     x1 = x1(npts:(2*npts-1));
  else
    x1 = interp1(ydat,xdat,y1,interp);
  end
  set(h,'xdata',x1);

  %pause(.1);
  drawnow; drawnow; drawnow

end

function plotpoint(src,event)
  h = getappdata(src,'hlatest');
  pos = get(gca,'currentpoint');
  set(h,'xdata',pos(1,1),'ydata',pos(1,2));
  drawnow
end
