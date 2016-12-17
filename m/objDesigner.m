function objDesigner()
  
% OBJDESIGNER
%
% Usage: objDesigner()
  
% 2016-12-12 - ts - first version
% 2016-12-13 - ts - second first version
% 2016-12-14 - ts - included the revolution/extrusion profiles
%                   included more perturbation types
  
% TODO
% print current parameters / command to produce the shape
% set filename and save in gui
% load existing / saved model to gui
% when loading, get default parameters for all perturbations and shapes
  
  fontsize = 8;
  
  scrsize = get(0,'ScreenSize');
  scrsize = scrsize(3:4) - scrsize(1:2) + 1;
  
  figsize = [300 600; ...   % prm
             300 380; ...   % preview
             380 720];      % profile

  fposy = scrsize(2) - 100 - figsize(:,2)';
  fposx = scrsize(1)/2 + [0 350 -410] - figsize(:,1)'/2;
  
  lines = [560:-10:20];
  
  %------------------------------------------------------------
  % Preview window

  fhPreview = figure('Color','white',...
                    'Units','pixels',...
                    'Menubar','none',...
                    'NumberTitle','Off',...
                    'Name','Preview');
  % pos = get(fhPreview,'Position');
  % pos(3:4) = siz(:)';
  pos = [fposx(2) fposy(2) figsize(2,:)];
  set(fhPreview,'Position',pos);
  
  ahPreview = axes('Units','pixels','Position',[20 100 260 260]);

  
  %------------------------------------------------------------
  % Shape / parameter window

  fhPrm = figure('Color','white',...
                 'Units','pixels',...
                 'Menubar','none',...
                 'NumberTitle','Off',...
                 'Name','objDesigner');
  % pos = get(fhPrm,'Position');
  % pos(3:4) = siz(:)';
  pos = [fposx(1) fposy(1) figsize(1,:)];
  set(fhPrm,'Position',pos);

  %------------------------------------------------------------
  % Revolution / extrusion profile window
  
  fhCurve = figure('Color','white',...
                   'Units','pixels',...
                   'Menubar','none',...
                   'NumberTitle','Off',...
                   'Name','Profile');
  % pos = get(fhCurve,'Position');
  % pos(3:4) = siz(:)';
  pos = [fposx(3) fposy(3) figsize(3,:)];
  set(fhCurve,'Position',pos);
  
  ahCurve(1) = axes('Units','pixels','Position',[30 290 200 400]);
  ahCurve(2) = axes('Units','pixels','Position',[30  30 200 200]);
  
  %------------------------------------------------------------
  %------------------------------------------------------------
  % Default values for perturbation parameters and input boxes
  
  figure(fhPrm);
  
  % Sine
  hPrm.sine.header(1) = uicontrol('Style','text',...
                                  'Position',[20 lines(7)+5 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Carrier parameters');
  x = [20 60 100 140 180];
  labels = {'Freq','Ori','Ph','Ampl','Grp'};
  tooltip = {'Frequency','Orientation','Phase','Amplitude','Group'};
  y = lines(9);
  for ii = 1:length(labels)
    hPrm.sine.label(1,ii) = uicontrol('Style','text',...
                                      'Position',[x(ii) y 30 20],...
                                      'FontSize',8,...
                                      'String',labels{ii},...
                                      'TooltipString',tooltip{ii});
  end
  vals = [8 0 0 .1 0; 0 0 0 0 0; 0 0 0 0 0];
  y = lines(11:3:17);
  for ii = 1:size(vals,1)
    for jj = 1:size(vals,2)
      hPrm.sine.carr(ii,jj) = uicontrol('Style', 'edit',...
                                        'Position', [x(jj) y(ii) 30 20],...
                                        'String',num2str(vals(ii,jj)),...
                                        'TooltipString',tooltip{jj});
    end
  end
  
  hPrm.sine.reset.carr = uicontrol('Style', 'pushbutton',...
                                   'String', 'Reset',...
                                   'FontSize',8,...
                                   'Position', [20 lines(20) 50 20],...
                                   'Callback', {@resetPrm,hPrm.sine.carr,'sine','carr'},...
                                   'TooltipString','Reset to default values.');
  
  
  hPrm.sine.header(2) = uicontrol('Style','text',...
                                  'Position',[20 lines(23) 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Modulator parameters');
  y = lines(25);
  for ii = 1:length(labels)
    hPrm.sine.label(2,ii) = uicontrol('Style','text',...
                                      'Position',[x(ii) y 30 20],...
                                      'FontSize',8,...
                                      'String',labels{ii},...
                                      'TooltipString',tooltip{ii});
  end  
  vals = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0];
  y = lines(27:3:33);
  for ii = 1:size(vals,1)
    for jj = 1:size(vals,2)
      hPrm.sine.mod(ii,jj) = uicontrol('Style', 'edit',...
                                       'Position', [x(jj) y(ii) 30 20],...
                                       'String',num2str(vals(ii,jj)),...
                                       'TooltipString',tooltip{jj});
    end
  end
  
  hPrm.sine.reset.mod = uicontrol('Style', 'pushbutton',...
                                  'String', 'Reset',...
                                  'FontSize',8,...
                                  'Position', [20 lines(36) 50 20],...
                                  'Callback', {@resetPrm,hPrm.sine.mod,'sine','mod'},...
                                  'TooltipString','Reset to default values.');
  
  set(hPrm.sine.header,'Visible','Off');
  set(hPrm.sine.label,'Visible','Off');
  set(hPrm.sine.reset.carr,'Visible','Off');
  set(hPrm.sine.reset.mod,'Visible','Off');
  set(hPrm.sine.carr,'Visible','Off');
  set(hPrm.sine.mod,'Visible','Off');
  
  
  % Noise
  hPrm.noise.header(1) = uicontrol('Style','text',...
                                  'Position',[20 lines(7)+5 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Carrier parameters');
  x = [20 60 100 140 180 220];
  labels = {'Freq','BW','Ori','BW','Ampl','Grp'};
  tooltip = {'Frequency','Frequency bandwidth',...
             'Orientation','Orientation bandwidth',...
             'Amplitude','Group'};
  y = lines(9);
  for ii = 1:length(labels)
    hPrm.noise.label(1,ii) = uicontrol('Style','text',...
                                      'Position',[x(ii) y 30 20],...
                                      'FontSize',8,...
                                      'String',labels{ii},...
                                       'TooltipString',tooltip{jj});
  end
  vals = [8 1 0 30 .1 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
  y = lines(11:3:17);
  for ii = 1:size(vals,1)
    for jj = 1:size(vals,2)
      hPrm.noise.carr(ii,jj) = uicontrol('Style', 'edit',...
                                         'Position', [x(jj) y(ii) 30 20],...
                                         'String',num2str(vals(ii,jj)),...
                                         'TooltipString',tooltip{jj});
    end
  end
  
  hPrm.noise.reset.carr = uicontrol('Style', 'pushbutton',...
                                    'String', 'Reset',...
                                    'FontSize',8,...
                                    'Position', [20 lines(20) 50 20],...
                                    'Callback', {@resetPrm,hPrm.noise.carr,'noise','carr'},...
                                    'TooltipString','Reset to default values.');
  

  hPrm.noise.header(2) = uicontrol('Style','text',...
                                  'Position',[20 lines(23) 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Modulator parameters');
  labels = {'Freq','Ori','Ph','Ampl','Grp',''};
  tooltip = {'Frequency','Orientation','Phase','Amplitude','Group',''};
  y = lines(25);
  for ii = 1:length(labels)
    hPrm.noise.label(2,ii) = uicontrol('Style','text',...
                                      'Position',[x(ii) y 30 20],...
                                      'FontSize',8,...
                                      'String',labels{ii},...
                                       'TooltipString',tooltip{ii});
  end  
  vals = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0];
  y = lines(27:3:33);
  for ii = 1:size(vals,1)
    for jj = 1:size(vals,2)
      hPrm.noise.mod(ii,jj) = uicontrol('Style', 'edit',...
                                        'Position', [x(jj) y(ii) 30 20],...
                                        'String',num2str(vals(ii,jj)),...
                                        'TooltipString',tooltip{jj});
    end
  end

  hPrm.noise.reset.mod = uicontrol('Style', 'pushbutton',...
                                   'String', 'Reset',...
                                   'FontSize',8,...
                                   'Position', [20 lines(36) 50 20],...
                                   'Callback', {@resetPrm,hPrm.noise.mod,'noise','mod'},...
                                   'TooltipString','Reset to default values.');

  set(hPrm.noise.header,'Visible','Off');
  set(hPrm.noise.label,'Visible','Off');
  set(hPrm.noise.reset.carr,'Visible','Off');
  set(hPrm.noise.reset.mod,'Visible','Off');
  set(hPrm.noise.carr,'Visible','Off');
  set(hPrm.noise.mod,'Visible','Off');
  
  % Bumps
  hPrm.bump.header(1) = uicontrol('Style','text',...
                                  'Position',[20 lines(7)+5 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Bump parameters');
  x = [20 60 100];
  labels = {'N','Size','Ampl'};
  tooltip = {'Number of bumps/dents',...
             'Size; space constant of Gaussian',...
             'Amplitude. Negative values give dents'};

  y = lines(9);
  for ii = 1:length(labels)
    hPrm.bump.label(1,ii) = uicontrol('Style','text',...
                                      'Position',[x(ii) y 30 20],...
                                      'FontSize',8,...
                                      'String',labels{ii},...
                                      'TooltipString',tooltip{ii});
  end 
  
  vals = [20 pi/12 .1; 0 0 0; 0 0 0];
  y = lines(11:3:17);
  for ii = 1:length(y)
    for jj = 1:length(x)
      hPrm.bump.prm(ii,jj) = uicontrol('Style', 'edit',...
                                       'Position', [x(jj) y(ii) 30 20],...
                                       'String',num2str(vals(ii,jj)),...
                                       'TooltipString',tooltip{jj});
    end
  end
    
  hPrm.bump.reset.prm = uicontrol('Style', 'pushbutton',...
                                  'String', 'Reset',...
                                  'FontSize',8,...
                                  'Position', [20 lines(20) 50 20],...
                                  'Callback', {@resetPrm,hPrm.bump.prm,'bump','prm'},...
                                  'TooltipString','Reset to default values');
                                  
  set(hPrm.bump.header,'Visible','Off');
  set(hPrm.bump.label,'Visible','Off');
  set(hPrm.bump.reset.prm,'Visible','Off');
  set(hPrm.bump.prm,'Visible','Off');
  
  % Custom
  hPrm.custom.header(1) = uicontrol('Style','text',...
                                  'Position',[20 lines(7)+5 200 20],...
                                  'HorizontalAlignment','left',...
                                  'String','Custom parameters');
  x = 20;
  labels = {'Function from file',...
            'Arguments';...
            'Anonymous function (@)',...
            'Arguments';...
            'Matrix from workspace',...
            'Amplitude';...
            'Image file',...
            'Amplitude'};
  tooltip = {'Name of the function',...
             'Function input arguments as vector';...
             'Define anonymous function',...
             'Input arguments as a vector';...
             sprintf('Name of matrix to use as height map.\nThe matrix variable has to be in current Matlab workspace.'),...
             'Amplitude (scaling of height map)';...
             'Name of image file to use as height map',...
             'Amplitude (scaling of height map)'};
  
  y = lines([9 17 25 33]);
  for ii = 1:length(labels)
    hPrm.custom.label(ii,1) = uicontrol('Style','text',...
                                        'Position',[x y(ii) 250 20],...
                                        'FontSize',8,...
                                        'HorizontalAlignment','left',...
                                        'String',labels{ii,1},...
                                        'TooltipString',tooltip{ii,1});
  end 
  
  wdt = [250 250 250 165; 155 155 155 155];
  x = [20 105];
  y = lines([11 19 27 35]);
  for ii = 1:length(y)
    for jj = 1:2
      hPrm.custom.prm(ii,jj) = uicontrol('Style', 'edit',...
                                         'Position', [x(jj) y(ii)-(jj-1)*25 wdt(jj,ii) 20],...
                                         'HorizontalAlignment','left',...
                                         'String','',...
                                         'TooltipString',tooltip{ii,jj});
    end
    
    hPrm.custom.label(ii,2) = uicontrol('Style','text',...
                                        'Position',[20 y(ii)-25 80 20],...
                                        'FontSize',8,...
                                        'HorizontalAlignment','left',...
                                        'String',labels{ii,2},...
                                        'TooltipString',tooltip{ii,2});
  end
  
  hPrm.custom.selectfile = uicontrol('Style', 'pushbutton',...
                                     'String', 'Select file',...
                                     'FontSize',8,...
                                     'Position', [190 lines(35) 80 20],...
                                     'Callback', {@selectFile,hPrm.custom.prm(4)});
  
  hPrm.custom.reset.prm = uicontrol('Style', 'pushbutton',...
                                    'String', 'Reset',...
                                    'FontSize',8,...
                                    'Position', [20 lines(40) 50 20],...
                                    'Callback', {@resetPrm,hPrm.custom.prm,'custom','prm'},...
                                    'TooltipString','Reset to default values (empty)');
  
  set(hPrm.custom.header,'Visible','Off');
  set(hPrm.custom.label,'Visible','Off');
  set(hPrm.custom.reset.prm,'Visible','Off');
  set(hPrm.custom.selectfile,'Visible','Off');
  set(hPrm.custom.prm,'Visible','Off');
  
  % Checkboxes for combining perturbations
  
  hPrm.combine.label(ii,1) = uicontrol('Style','text',...
                                       'Position',[20 lines(43) 250 20],...
                                       'FontSize',10,...
                                       'HorizontalAlignment','left',...
                                       'String','Combine perturbations:',...
                                       'TooltipString','Currently active perturbation always shown.');
  % These HAVE TO BE IN THE SAME ORDER as in the pull-down menu.
  % Don't fuck this up.
  labels = {'sine','noise','bump','custom'};
  y = lines([45 47 49 51]);
  for ii = 1:length(labels)
    hPrm.combine.box(ii) = uicontrol('Style','checkbox',...
                                     'String',labels{ii},...
                                     'Position',[20 y(ii) 80 18],...
                                     'Value',0,...    
                                     'FontSize',8,...
                                     'TooltipString','');
  end
  
  %------------------------------------------------------------
  %------------------------------------------------------------
  % Profiles for revolution and extrusion

  figure(fhCurve);
  
  npoints = [64 64];
  
  xscale = 2;
  yscale = pi;
  connect = false;
  interp = 'spline';

  %------------------------------------------------------------
  % Set up things for the revolution curve
  axes(ahCurve(1));
  xlim = [-xscale xscale];
  ylim = [-yscale yscale];
  axis equal
  set(ahCurve(1),'XLim',xlim,'YLim',ylim,'Box','On');
  title('Revolution profile','FontWeight','normal','Fontsize',10);
  hold on

  y = ylim;
  x = xscale/2*[1 1];
  
  y1 = linspace(-yscale,yscale,npoints(1));
  x1 = interp1(y,x,y1,'spline');

  hsmooth_orig(1,1) = plot(x1,y1,'Visible','Off');
  hdat_orig(1,1) = plot(x,y,'Visible','Off');
  hsmooth_orig(1,2) = plot(-x1,y1,'Visible','Off');
  hdat_orig(1,2) = plot(-x,y,'Visible','Off');
  
  hsmooth(1,1) = plot(x1,y1,'r-');
  hdat(1,1) = plot(x,y,'ob','MarkerFaceColor','b');
  hsmooth(1,2) = plot(-x1,y1,'-','Color',[1 .8 .8]);
  hdat(1,2) = plot(-x,y,'o','MarkerFaceColor',[.8 .8 1],'MarkerEdgeColor',[.8 .8 1]);
  drawnow
  
  % End setting up for revolution  profile 
  %------------------------------------------------------------
  % Set up things for the revolution curve
  
  axes(ahCurve(2));
  xlim = [-xscale xscale];
  ylim = [-xscale xscale];
  th = [0 pi/2 pi 3*pi/2];
  r = [1 1 1 1];
  [x,y] = pol2cart(th,r);
  %hsmooth = [];
  
  if false % isoctave
    hdat = polar(y,x,'ob');
    ah = gca;
    set(hdat,'MarkerFaceColor','b');
    set(ahCurve,'XLim',xlim,'YLim',ylim);
    set(ahCurve,'RTick',xscale);
    axis equal
    hold on      
  else
    % polarplot exists only in Matlab 2016a and later Put here code that
    % works in older versions.  This is similar to Octave code, but
    % Matlab's polar doesn't support RLim, for instance.  You have to
    % hack the axis limit by plotting an invisible point at the wanted
    % distance.
    
    plot(0,0,'ok','MarkerFaceColor','k');
    hold on    

    
    %set(hdat,'MarkerFaceColor','b');
    set(ahCurve(2),'XLim',xlim,'YLim',ylim);
    %set(ah,'RTick',xscale);
    axis equal

    % Add one point to y1 to make it wrap around.  In
    % objMake*-functions the faces do the wrapping, so remember
    % to drop the final point here before returning.
    th = atan2(y,x);
    th(th<0) = th(th<0) + 2*pi;
    r = sqrt(x.^2+y.^2);
    th1 = linspace(0,2*pi,npoints(2)+1);
    % r1 = interp1([th 2*pi],[r r(1)],th1,'spline');
    r1 = interp1([th 2*pi],1./([r r(1)]).^2,th1,'spline');
    r1 = 1 ./ r1.^.5;
    [x1,y1] = pol2cart(th1,r1);
    

    
    hsmooth_orig(2,1) = plot(x1,y1,'Visible','Off');
    hdat_orig(2,1) = plot(x,y,'Visible','Off');
    hsmooth(2,1) = plot(x1,y1,'r-');
    hdat(2,1) = plot(x,y,'ob','MarkerFaceColor','b');
    drawnow
    
    %keyboard
    
  end
  title('Extrusion profile','FontWeight','normal','Fontsize',10);  

  % End setting up for extrusion / polar profile
  %------------------------------------------------------------
  % Set app data for the profiles
  
  %setappdata(fhCurve,'profiletype',profiletype);
  setappdata(fhCurve,'h_orig',hdat_orig);
  setappdata(fhCurve,'hsmooth_orig',hsmooth_orig);

  setappdata(fhCurve,'h',hdat);
  setappdata(fhCurve,'hsmooth',hsmooth);
  
  setappdata(ahCurve(1),'profiletype','linear');
  setappdata(ahCurve(2),'profiletype','polar');

  axes(ahCurve(1));
  hlate(1) = plot(-100,-100,'ob','MarkerFaceColor','b');
  axes(ahCurve(2));
  hlate(2) = plot(-100,-100,'ob','MarkerFaceColor','b');
  setappdata(fhCurve,'hlatest',hlate);

  axes(ahCurve(1));
  hmove(1) = plot(-100,-100,'o','MarkerSize',8,...
                  'MarkerEdgeColor',[.7 .7 .7],...
                  'MarkerFaceColor',[.7 .7 .7]);
  axes(ahCurve(2));
  hmove(2) = plot(-100,-100,'o','MarkerSize',8,...
                  'MarkerEdgeColor',[.7 .7 .7],...
                  'MarkerFaceColor',[.7 .7 .7]);
  setappdata(fhCurve,'hmovepoint',hmove);

  setappdata(fhCurve,'npoints',npoints);
  setappdata(fhCurve,'connect',connect);
  setappdata(fhCurve,'interp',interp);
  setappdata(fhCurve,'rdata',r1);
  setappdata(fhCurve,'rdata_orig',r1);
  setappdata(fhCurve,'usercurve',true);
  setappdata(fhCurve,'useecurve',true);

  set(fhCurve,'windowbuttondownfcn',@starttrackmouse);
  set(fhCurve,'keypressfcn',@keyfunc);
  
  

  %------------------------------------------------------------
  % Set up other controls for profiles
  
  figure(fhCurve);
  hUseCurve(1) = uicontrol('Style', 'checkbox',...
                           'Position', [250 630 100 20],...
                           'String','Use profile',...
                           'FontSize',8,...
                           'Value', 1,...
                           'Tag','1',...
                           'Enable','Off',...
                           'TooltipString','Uncheck to ignore profile curve',...
                           'Callback', {@toggleCurve,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});
  
  hUseCurve(2) = uicontrol('Style', 'checkbox',...
                           'Position', [250 210 100 20],...
                           'String','Use profile',...
                           'FontSize',8,...
                           'Value', 1,...
                           'Tag','2',...
                           'Enable','Off',...
                           'TooltipString','Uncheck to ignore profile curve',...
                           'Callback', {@toggleCurve,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});

  hResetCurve(1) = uicontrol('Style', 'pushbutton',...
                             'Position', [250 600 60 20],...
                             'Tag','1',...
                             'FontSize',8,...
                             'String','Reset',...
                             'TooltipString','Reset the curve to default',...
                             'Callback', {@resetCurve,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});

  hResetCurve(2) = uicontrol('Style', 'pushbutton',...
                             'Position', [250 180 60 20],...
                             'Tag','2',...
                             'FontSize',8,...
                             'String','Reset',...
                             'TooltipString','Reset the curve to default',...
                             'Callback', {@resetCurve,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});  

  hExportCurve(1) = uicontrol('Style','edit',...
                              'Position',[250 570 130 20],...
                              'HorizontalAlignment','left',...
                              'String','rcurve',...
                              'TooltipString','Give a variable name for the curve',...
                              'Callback', {@exportCurveToWorkSpace,'linear',[],fhCurve},...
                              'FontSize',fontsize);
  
  hExportCurveLabel(1) = uicontrol('Style', 'pushbutton',...
                                   'String', 'Export to workspace',...
                                   'TooltipString','Export the curve',...
                                   'Position', [250 545 130 20],...
                                   'Callback', {@exportCurveToWorkSpace,'linear',hExportCurve(1),fhCurve},...
                                   'FontSize',fontsize);    
    
  hExportCurve(2) = uicontrol('Style','edit',...
                              'Position',[250 150 130 20],...
                              'HorizontalAlignment','left',...
                              'String','ecurve',...
                              'TooltipString','Give a variable name for the curve',...
                              'Callback', {@exportCurveToWorkSpace,'polar',[],fhCurve},...
                              'FontSize',fontsize);
  
  hExportCurveLabel(2) = uicontrol('Style', 'pushbutton',...
                                   'String', 'Export to workspace',...
                                   'TooltipString','Export the curve',...
                                   'Position', [250 125 130 20],...
                                   'Callback', {@exportCurveToWorkSpace,'polar',hExportCurve(2),fhCurve},...
                                   'FontSize',fontsize);    
  
  %------------------------------------------------------------
  %------------------------------------------------------------
  % Main controls for parameter window (perturbation parameter
  % input set up further above).
  
  figure(fhPrm);
  setappdata(fhPrm,'shape','sphere');
  setappdata(fhPrm,'perturbation','none');
  
  uicontrol('Style','text',...
            'Position',[120 lines(1) 100 20],...
            'HorizontalAlignment','left',...
            'String','Perturbation');  

  uicontrol('Style','text',...
            'Position',[20 lines(1) 100 20],...
            'HorizontalAlignment','left',...
            'String','Shape');  
  
  hPerturbation = uicontrol('Style', 'popupmenu',...
                            'String', {'none','sine','noise','bump','custom'},...
                            'Position', [120 lines(3) 100 20],...
                            'Callback', {@updatePerturbation,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});
  
  hShape = uicontrol('Style', 'popupmenu',...
                     'String', {'sphere','plane','cylinder','torus','disk','revolution','extrusion'},...
                     'Position', [20 lines(3) 100 20],...
                     'Callback', {@updateShape,fhPrm,fhCurve,fhPreview,hPrm,hUseCurve,ahPreview});
  %                     'Callback', {@updateShape,hPerturbation,hPrm,ahPreview});
  
  hUpdate = uicontrol('Style', 'pushbutton',...
                      'String', 'Update',...
                      'FontSize',8,...
                      'Position', [20 lines(end) 50 20],...
                      'Callback', {@updatePrm,fhPrm,fhCurve,fhPreview,hPrm,ahPreview});
  %                      'Callback', {@updatePrm,hShape,hPerturbation,hPrm,ahPreview});
  
  %------------------------------------------------------------
  %------------------------------------------------------------
  % Controls for the preview window
  
  figure(fhPreview);
  
  hToggleAxes = uicontrol('Style', 'checkbox',...
                          'Position', [20 70 115 20],...
                          'String','Show axes',...
                          'FontSize',fontsize,...
                          'Value', 0,...
                          'Callback', {@toggleAxes,ahPreview});  
  
  
  bhResetView = uicontrol('Style', 'pushbutton',...
                          'String', 'Reset view',...
                          'TooltipString','Reset to default view',...
                          'Position', [150 70 130 20],...
                          'Callback', {@resetView,fhPreview,ahPreview},...
                          'FontSize',fontsize);    
  
  thExportLabel = uicontrol('Style','text',...
                            'Position',[20 45 55 20],...
                            'HorizontalAlignment','left',...
                            'String','Variable',...
                            'FontSize',fontsize);
  
  thExport = uicontrol('Style','edit',...
                       'Position',[85 45 60 20],...
                       'HorizontalAlignment','left',...
                       'String','model',...
                       'TooltipString','Give a variable name for the model structure',...
                       'Callback', {@exportToWorkSpace,[],fhPreview},...
                       'FontSize',fontsize);
  
  bhExport = uicontrol('Style', 'pushbutton',...
                       'String', 'Export to workspace',...
                       'TooltipString','Export the model structure to Matlab workspace',...
                       'Position', [150 45 130 20],...
                       'Callback', {@exportToWorkSpace,thExport,fhPreview},...
                       'FontSize',fontsize);  
  
  thSaveLabel = uicontrol('Style','text',...
                          'Position',[20 20 55 20],...
                          'HorizontalAlignment','left',...
                          'String','Filename',...
                          'FontSize',fontsize);
  
  thSave = uicontrol('Style','edit',...
                     'Position',[85 20 60 20],...
                     'HorizontalAlignment','left',...
                     'String','model',...
                     'TooltipString','Give a file name to save to',...
                     'Callback', {@saveModel,[],fhPreview},...
                     'FontSize',fontsize);
  
  bhSave = uicontrol('Style', 'pushbutton',...
                     'String', 'Save .obj file',...
                     'TooltipString','Save the model to a Wavefront obj file',...
                     'Position', [150 20 130 20],...
                     'Callback', {@saveModel,thSave,fhPreview},...
                     'FontSize',fontsize);  

  %------------------------------------------------------------
  % Switch to the main window and update parameters, forcing the
  % drawing of default shape.
  
  
  % updatePerturbation([],[],fhPrm,hPrm,ahPreview);
  updatePrm([],[],fhPrm,fhCurve,fhPreview,hPrm,ahPreview);
  % updatePrm([],[],hShape,hPerturbation,hPrm,ahPreview);

  resetView([],[],fhPreview,ahPreview);
  
  
  figure(fhPrm);
    
  % m = objMakeNoise('sphere');
  % axes(ahPreview);
  % objShow(m); 
  
end % End main program

%------------------------------------------------------------
%------------------------------------------------------------
% Functions hereafter

% Callback functions sort of mainly pertaining to the main window

function updatePerturbation(src,event,fhPrm,fhCurve,fhPreview,hPrm,ahPreview)
  
  shape = getappdata(fhPrm,'shape');
  
  p = get(src,'value');
  perturbations = get(src,'String');
  perturbation = perturbations{p};
  
  set(hPrm.sine.header,'Visible','Off');
  set(hPrm.sine.label,'Visible','Off');
  set(hPrm.sine.reset.carr,'Visible','Off');
  set(hPrm.sine.reset.mod,'Visible','Off');
  set(hPrm.sine.carr,'Visible','Off');
  set(hPrm.sine.mod,'Visible','Off');
  
  set(hPrm.noise.header,'Visible','Off');
  set(hPrm.noise.label,'Visible','Off');
  set(hPrm.noise.reset.carr,'Visible','Off');
  set(hPrm.noise.reset.mod,'Visible','Off');
  set(hPrm.noise.carr,'Visible','Off');
  set(hPrm.noise.mod,'Visible','Off');  
  
  set(hPrm.bump.header,'Visible','Off');
  set(hPrm.bump.label,'Visible','Off');
  set(hPrm.bump.reset.prm,'Visible','Off');
  set(hPrm.bump.prm,'Visible','Off');
  
  set(hPrm.custom.header,'Visible','Off');
  set(hPrm.custom.label,'Visible','Off');
  set(hPrm.custom.reset.prm,'Visible','Off');
  set(hPrm.custom.selectfile,'Visible','Off');
  set(hPrm.custom.prm,'Visible','Off');
  
  switch perturbation
    case 'none'
      setappdata(fhPrm,'perturbation','none');
    case 'sine'
      setappdata(fhPrm,'perturbation','sine');
      set(hPrm.sine.header,'Visible','On');
      set(hPrm.sine.label,'Visible','On');
      set(hPrm.sine.reset.carr,'Visible','On');
      set(hPrm.sine.reset.mod,'Visible','On');
      set(hPrm.sine.carr,'Visible','On');
      set(hPrm.sine.mod,'Visible','On');
    case 'noise'
      setappdata(fhPrm,'perturbation','noise');
      set(hPrm.noise.header,'Visible','On');
      set(hPrm.noise.label,'Visible','On');
      set(hPrm.noise.reset.carr,'Visible','On');
      set(hPrm.noise.reset.mod,'Visible','On');
      set(hPrm.noise.carr,'Visible','On');
      set(hPrm.noise.mod,'Visible','On');   
    case 'bump'
      if ~strcmp(shape,'torus')
        setappdata(fhPrm,'perturbation','bump');
        set(hPrm.bump.header,'Visible','On');
        set(hPrm.bump.label,'Visible','On');
        set(hPrm.bump.reset.prm,'Visible','On');
        set(hPrm.bump.prm,'Visible','On');
      end
    case 'custom'
      setappdata(fhPrm,'perturbation','custom');
      set(hPrm.custom.header,'Visible','On');
      set(hPrm.custom.label,'Visible','On');
      set(hPrm.custom.reset.prm,'Visible','On');
      set(hPrm.custom.selectfile,'Visible','On');
      set(hPrm.custom.prm,'Visible','On');
  end
  
  updatePrm([],[],fhPrm,fhCurve,fhPreview,hPrm,ahPreview);
  
end
  
function updateShape(src,event,fhPrm,fhCurve,fhPreview,hPrm,hUseCurve,ah)
  s = get(src,'value');
  shapes = get(src,'String');
  shape = shapes{s};
  setappdata(fhPrm,'shape',shape);
  
  switch shape
    case 'revolution'
      setappdata(fhCurve,'usercurve',true);
      set(hUseCurve(1),'Enable','Off');
      set(hUseCurve(2),'Enable','On');
    case 'extrusion'
      setappdata(fhCurve,'useecurve',true);
      set(hUseCurve(1),'Enable','On');
      set(hUseCurve(2),'Enable','Off');
    otherwise
      set(hUseCurve(1),'Enable','Off');
      set(hUseCurve(2),'Enable','Off');
  end  
  updatePrm([],[],fhPrm,fhCurve,fhPreview,hPrm,ah);
end

% function updateShape(src,event,hPerturbation,hPrm,ah)
%   updatePrm([],[],src,hPerturbation,hPrm,ah);
% end

% function updatePrm(src,event,hShape,hPerturbation,hPrm,ah)
%   s = get(hShape,'value');
%   shapes = get(hShape,'String');
%   shape = shapes{s};

%   p = get(hPerturbation,'value');
%   perturbations = get(hPerturbation,'String');
%   perturbation = perturbations{p};
  
function updatePrm(src,event,fhPrm,fhCurve,fhPreview,hPrm,ah)
  shape = getappdata(fhPrm,'shape');
  
  args = {};
  switch shape
    case {'revolution','extrusion'}
      usercurve = getappdata(fhCurve,'usercurve');
      useecurve = getappdata(fhCurve,'useecurve');
      if usercurve
        hsmooth = getappdata(fhCurve,'hsmooth');
        rcurve = get(hsmooth(1,1),'xdata');
        args = {'rcurve',rcurve,args{:}};
      end
      if useecurve
        ecurve = getappdata(fhCurve,'rdata');
        args = {'ecurve',ecurve,args{:}};
      end
  end
  
  m = objMakePlain(shape,args{:});
  
  thisperturbation = getappdata(fhPrm,'perturbation');
  perturbations = {};
  
  for pp = 1:length(hPrm.combine.box)
    usepert = get(hPrm.combine.box(pp),'Value');
    if usepert
      perturbations = {perturbations{:},get(hPrm.combine.box(pp),'String')};
    end
  end
  
  if ~strcmp(thisperturbation,'none') && ~ismember(thisperturbation,perturbations)
    perturbations = {perturbations{:},thisperturbation};
  end
    
  if ~isempty(perturbations)
    for pp = 1:length(perturbations)
      perturbation = perturbations{pp};
      prm = [];
      mprm = [];
      switch perturbation
        case {'sine','noise'}
          for ii = 1:size(hPrm.(perturbation).carr,1)
            for jj = 1:size(hPrm.(perturbation).carr,2)
              prm(ii,jj) = str2num(get(hPrm.(perturbation).carr(ii,jj),'String'));
            end
          end
          for ii = 1:size(hPrm.(perturbation).mod,1)
            for jj = 1:size(hPrm.(perturbation).mod,2)
              mprm(ii,jj) = str2num(get(hPrm.(perturbation).mod(ii,jj),'String'));
            end
          end
          idx = all(prm==0,2);
          if all(idx)
            prm = zeros(1,size(prm,2));
          else
            prm(idx,:) = [];
          end
          idx = all(mprm==0,2);
          mprm(idx,:) = [];
        case 'bump'
          for ii = 1:size(hPrm.(perturbation).prm,1)
            for jj = 1:size(hPrm.(perturbation).prm,2)
              prm(ii,jj) = str2num(get(hPrm.(perturbation).prm(ii,jj),'String'));
            end
          end
        case 'custom'
          customprm = {};
          f = {};
          customtype = [];
          n = 1;
          for ii = 1:size(hPrm.(perturbation).prm,1)
            f{n} = get(hPrm.(perturbation).prm(ii,1),'String');
            customprm{n} = str2num(get(hPrm.(perturbation).prm(ii,2),'String'));
            if ~isempty(customprm{n})
              customtype = [customtype ii];
              n = n + 1;
            end
          end
      end % switch
      
      switch perturbation
        % case 'none'
        %   m = objMakePlain(shape,args{:});
        case 'sine'
          m = objMakeSine(m,prm,mprm);
        case 'noise'
          m = objMakeNoise(m,prm,mprm);
        case 'bump'
          m = objMakeBump(m,prm);
        case 'custom'
          for ii = 1:length(customtype)
            switch customtype(ii)
              case 1
                m = objMakeCustom(m,eval(sprintf('@%s',f{ii})),customprm{ii});
              case 2
                m = objMakeCustom(m,eval(f{ii}),customprm{ii});
              case 3
                M = evalin('base',f{ii});
                m = objMakeCustom(m,M,customprm{ii});
              case 4
                m = objMakeCustom(m,f{ii},customprm{ii});
            end
          end
      end %switch
    end % looping over perturbations
  end % is perturbations not empty
  axes(ah);
  try
    objShow(m,[],get(ah,'CameraPosition'));
  catch
    objShow(m);
  end
  setappdata(fhPreview,'model',m);
end

function selectFile(src,event,hPrm)
  [filename,filepath] = uigetfile(...
      {'*.tiff;*.jpg;*.jpeg,*.png','Image files (*.tiff;*.jpg;*.jpeg,*.png)';...
       '*.*','All Files (*.*)'},...
      'Select image to use as height map');
  set(hPrm,'String',fullfile(filepath,filename));
% ,hPrm.custom.prm(4)

end
  
function resetPrm(src,event,hPrm,perturbation,type)
  switch perturbation
    case 'sine'
      switch type
        case 'carr'
          vals = [8 .1 0 0 0; 0 0 0 0 0; 0 0 0 0 0];
        case 'mod'
          vals = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0];
      end
    case 'noise'
      switch type
        case 'carr'
          vals = [8 1 0 30 .1 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
        case 'mod'
          vals = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0];
      end
    case 'bump'
      vals = [20 .1 pi/12; 0 0 0; 0 0 0];
  end

  if strcmp(perturbation,'custom')
    for ii = 1:size(hPrm,1)
      for jj = 1:size(hPrm,2)
        set(hPrm(ii,jj),'String','');
      end
    end
    return
  end
  
  for ii = 1:size(hPrm,1)
    for jj = 1:size(hPrm,2)
      set(hPrm(ii,jj),'String',num2str(vals(ii,jj)));
    end
  end
end

%------------------------------------------------------------
% Callback functions for profiles


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
  
  profiletype = getappdata(gca,'profiletype');
  pidx = strmatch(profiletype,{'linear','polar'});
  
  h = getappdata(src,'h');
  x = get(h(pidx,1),'xdata');
  y = get(h(pidx,1),'ydata');
  pos = get(gca,'currentpoint');
  dist = sqrt((x-pos(1,1)).^2+(y-pos(1,2)).^2);
  if min(dist)<.2
    idx = find(dist==min(dist));
    xtmp = x(idx);
    ytmp = y(idx);
    hmove = getappdata(src,'hmovepoint');
    set(hmove(pidx),'xdata',xtmp,'ydata',ytmp);
    setappdata(src,'newpoint',false);
    setappdata(src,'hmovepoint',hmove);
    setappdata(src,'idx',idx);
  else
    setappdata(src,'newpoint',true);
  end
  switch profiletype
    case 'linear'
      set(src,'windowbuttonupfcn',@endtrackmouse);
    case 'polar'
      set(src,'windowbuttonupfcn',@endtrackmousepolar);
  end      
  set(src,'windowbuttonmotionfcn',@plotpoint);
end


function endtrackmouse(src,data)
  set(src,'windowbuttonmotionfcn','');

  htmp = getappdata(src,'hmovepoint');
  set(htmp(1),'xdata',[],'ydata',[]);

  htmp = getappdata(src,'hlatest');
  set(htmp(1),'xdata',[],'ydata',[]);

  profiletype = getappdata(src,'profiletype');
  con = getappdata(src,'connect');

  h = getappdata(src,'h');
  xdat = get(h(1,1),'xdata');
  ydat = get(h(1,1),'ydata');
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
  set(h(1,1),'xdata',xdat,'ydata',ydat);
  set(h(1,2),'xdata',-xdat,'ydata',ydat);
  
  h = getappdata(src,'hsmooth');
  npts = getappdata(src,'npoints');
  interp = getappdata(src,'interp');
  x1 = get(h(1,1),'xdata');
  y1 = get(h(1,1),'ydata');

  
  if con
    xdat = [xdat(1:(end-1)) xdat xdat(2:end)];
    ydat = [ydat(1:(end-1))-ydat(end) ydat ydat(2:end)+ydat(end)];
    y1 = [y1(1:(end-1))-y1(end) y1 y1(2:end)+y1(end)];
    x1 = interp1(ydat,xdat,y1,interp);
    x1 = x1(npts(1):(2*npts(1)-1));
  else
    x1 = interp1(ydat,xdat,y1,interp);
  end
  
  set(h(1,1),'xdata',x1);
  set(h(1,2),'xdata',-x1);

  %pause(.1);
  drawnow; drawnow; drawnow

end


function endtrackmousepolar(src,data)
  set(src,'windowbuttonmotionfcn','');

  htmp = getappdata(src,'hmovepoint');
  set(htmp(2),'xdata',[],'ydata',[]);

  htmp = getappdata(src,'hlatest');
  set(htmp(2),'xdata',[],'ydata',[]);

  profiletype = getappdata(src,'profiletype');
  con = getappdata(src,'connect');

  h = getappdata(src,'h');
  xdat = get(h(2,1),'xdata');
  ydat = get(h(2,1),'ydata');
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
    ydat = [ydat y];
    xdat = [xdat x];
    thdat = atan2(ydat,xdat);
    thdat(thdat<0) = thdat(thdat<0) + 2*pi;
    rdat = sqrt(xdat.^2+ydat.^2);
    [thdat,idx] = sort([thdat]);
    rdat = rdat(idx);
    [xdat,ydat] = pol2cart(thdat,rdat);
  else
    idx = getappdata(src,'idx');
    if offlimits
      if idx>1 && idx<length(xdat)
        xdat(idx) = [];
        ydat(idx) = [];
      end
    else
      if idx~=1
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
  set(h(2,1),'xdata',xdat,'ydata',ydat);

  h = getappdata(src,'hsmooth');
  npts = getappdata(src,'npoints');
  interp = getappdata(src,'interp');
  %x1 = get(h(1),'xdata');
  %y1 = get(h(1),'ydata');
  

  th1 = linspace(0,2*pi,npts(2)+1);
  
  thdat = atan2(ydat,xdat);
  thdat(thdat<0) = thdat(thdat<0) + 2*pi;
  rdat = sqrt(xdat.^2+ydat.^2);

  % Works:
  % r1 = interp1([thdat 2*pi],[rdat rdat(1)],th1,'spline');
  % [x1,y1] = pol2cart(th1,r1);
  
  % Works now also:
  th1 = [th1(1:end-1) 2*pi+th1(1:end-1) 4*pi+th1];
  % r1 = interp1([thdat 2*pi+thdat 4*pi+thdat],...
  %              [rdat rdat rdat],...
  %              th1,...
  %              'spline');  
  r1 = interp1([thdat 2*pi+thdat 4*pi+thdat],...
               1./([rdat rdat rdat]).^2,...
               th1,...
               'spline');  
  r1 = real(1 ./ r1.^.5);
  th1 = th1(npts(2):(2*npts(2)));
  r1 = r1(npts(2):(2*npts(2)));
  
  [x1,y1] = pol2cart(th1,r1);
  
  
  
  set(h(2,1),'xdata',x1);
  set(h(2,1),'ydata',y1);
  setappdata(src,'rdata',r1);
  


  %pause(.1);
  drawnow; drawnow; drawnow

end


function plotpoint(src,event)
  profiletype = getappdata(gca,'profiletype');
  idx = strmatch(profiletype,{'linear','polar'});
  
  h = getappdata(src,'hlatest');
  pos = get(gca,'currentpoint');
  set(h(idx),'xdata',pos(1,1),'ydata',pos(1,2));
  drawnow
end

function toggleCurve(src,event,fhPrm,fhCurve,fhPreview,hPrm,ahPreview)
  usecurve = get(src,'Value');
  which = str2num(get(src,'Tag'));
  if which==1
    setappdata(fhCurve,'usercurve',usecurve);
  else
    setappdata(fhCurve,'useecurve',usecurve);    
  end
  % if usecurve
    
  % end
  updatePrm([],[],fhPrm,fhCurve,fhPreview,hPrm,ahPreview);
  
end

function resetCurve(src,event,fhPrm,fhCurve,fhPreview,hPrm,ahPreview)
  idx = str2num(get(src,'Tag'));

  h0 = getappdata(fhCurve,'h_orig');
  h1 = getappdata(fhCurve,'h');
  
  set(h1(idx,1),'xdata',get(h0(idx,1),'xdata'));
  set(h1(idx,1),'ydata',get(h0(idx,1),'ydata'));
  
  if idx==1
    set(h1(idx,2),'xdata',get(h0(idx,2),'xdata'));  
    set(h1(idx,2),'ydata',get(h0(idx,2),'ydata'));  
  else
    rdata = getappdata(fhCurve,'rdata_orig');
    setappdata(fhCurve,'rdata',rdata);
  end
  
  h0 = getappdata(fhCurve,'hsmooth_orig');
  h1 = getappdata(fhCurve,'hsmooth');

  set(h1(idx,1),'xdata',get(h0(idx,1),'xdata'));
  set(h1(idx,1),'ydata',get(h0(idx,1),'ydata'));

  if idx==1
    set(h1(idx,2),'xdata',get(h0(idx,2),'xdata'));  
    set(h1(idx,2),'ydata',get(h0(idx,2),'ydata'));  
  end
  
  updatePrm([],[],fhPrm,fhCurve,fhPreview,hPrm,ahPreview);
  
end

function exportCurveToWorkSpace(src,event,curvetype,th,fh)
  if isempty(th)
    h = src;
  else
    h = th;
  end
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  varname = get(h,'String');
  switch curvetype
    case 'linear'
      hdat = getappdata(fh,'hsmooth');
      curve = get(hdat(1,1),'xdata');
    case 'polar'
      curve = getappdata(fh,'rdata'); 
  end
  assignin('base',varname,curve);
  pause(.2);
  set(h,'BackgroundColor',bgcol);
end

% Functions for preview window


function exportToWorkSpace(src,event,th,fh)
  if isempty(th)
    h = src;
  else
    h = th;
  end
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  varname = get(h,'String');
  m = getappdata(fh,'model');
  assignin('base',varname,m);
  pause(.2);
  set(h,'BackgroundColor',bgcol);
end

function saveModel(src,event,th,fh)
  if isempty(th)
    h = src;
  else
    h = th;
  end  
  filename = get(h,'String');
  if isempty(regexp(filename,'\.obj$'))
    filename = [filename,'.obj'];
  end
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  m = getappdata(fh,'model');
  m.filename = filename;
  objSave(m);
  pause(.2);
  set(h,'BackgroundColor',bgcol);
end

function resetView(src,event,fh,ah)
  m = getappdata(fh,'model');
  showaxes = get(ah,'Visible');
  axes(ah);
  objShow(m);
  if strcmp(lower(showaxes),'on')
    set(ah,'Visible','On');
    xlabel('x');
    ylabel('z');
    zlabel('y');    
  end
end

function toggleAxes(src,event,ah)
  show = get(src,'Value');
  if show
    set(ah,'Visible','On');
    xlabel('x');
    ylabel('z');
    zlabel('y');
  else
    set(ah,'Visible','Off');
  end
end
