function objBlendGui(m1,m2)

% OBJBLENDGUI
  
% Usage: OBJBLENDGUI([MODEL1],[MODEL2])
%
% Blend (compute a weighted average of) two model
% objects---rudimentary GUI version.
%
% SEE ALSO:
% objBlend
  
% Copyright (C) 2016, 2017 Toni Saarela
% 2016-12-16 - ts - first version
% 2017-05-28 - ts - fixed a bug in model importing: send only the
%                    relevant handle to the importing function, not
%                    both
% 2017-06-04 - ts - cleaned help (was basically the objBlend help).
  
% TODO:
% - reset view button
  
  if ~nargin
    m1 = [];
  end
  if nargin<2
    m2 = [];
  end
  
  w = .5;
  fontsize = 8;

  scrsize = get(0,'ScreenSize');
  scrsize = scrsize(3:4) - scrsize(1:2) + 1;
  
  figsize = [910 430];

  fposy = scrsize(2)/2 - figsize(2)/2;
  fposx = scrsize(1)/2 - figsize(1)/2;

  fh = figure('Color','white',...
              'Units','pixels',...
              'Menubar','none',...
              'NumberTitle','Off',...
              'Name','Blender (awaiting for Blender lawsuit)');
  
  pos = [fposx(1) fposy(1) figsize];
  set(fh,'Position',pos);
  
  ah(1) = axes('Units','pixels','Position',[ 40 140 250 250],'Visible','Off');
  ah(2) = axes('Units','pixels','Position',[330 140 250 250],'Visible','Off');
  ah(3) = axes('Units','pixels','Position',[620 140 250 250],'Visible','Off');
  
  th = uicontrol('Style','text',...
                 'Position',[440 95 30 20],...
                 'HorizontalAlignment','center',...
                 'String',num2str(w),...
                 'FontSize',fontsize);
  
  sh = uicontrol('Style', 'slider',...
                 'Min',0,'Max',1,'Value',w,...
                 'Position', [330 70 250 20],...
                 'Callback', {@updateWeight,fh,th,ah(2)}); 
  

  if ~isempty(m1) && ~isempty(m2)
    mblend = objBlend(m1,m2,1-w);
  else
    mblend = [];
  end
  
  setappdata(fh,'weight',w);
  setappdata(fh,'m1',m1);
  setappdata(fh,'mblend',mblend);
  setappdata(fh,'m2',m2);
  
  resetView([],[],fh,ah);

  bh = uicontrol('Style', 'pushbutton',...
                 'String', 'Reset views',...
                 'Position', [40 20 100 20],...
                 'Callback', {@resetView,fh,ah},...
                 'FontSize',fontsize);  
    
  
  thImport(1) = uicontrol('Style','edit',...
                          'Position',[40 45 95 20],...
                          'HorizontalAlignment','left',...
                          'String','',...
                          'Callback', {@importFromWorkSpace,[],1,fh,th,ah},...
                          'FontSize',fontsize);
  
  bhImport(1) = uicontrol('Style', 'pushbutton',...
                          'String', 'Import from workspace',...
                          'Position', [140 45 150 20],...
                          'Callback', {@importFromWorkSpace,thImport(1),1,fh,th,ah},...
                          'FontSize',fontsize);  
  
  thImport(2) = uicontrol('Style','edit',...
                          'Position',[620 45 95 20],...
                          'HorizontalAlignment','left',...
                          'String','',...
                          'Callback', {@importFromWorkSpace,[],2,fh,th,ah},...
                          'FontSize',fontsize);
  
  bhImport(2) = uicontrol('Style', 'pushbutton',...
                          'String', 'Import from workspace',...
                          'Position', [720 45 150 20],...
                          'Callback', {@importFromWorkSpace,thImport(2),2,fh,th,ah},...
                          'FontSize',fontsize);  
  
  
  thExport = uicontrol('Style','edit',...
                       'Position',[330 45 95 20],...
                       'HorizontalAlignment','left',...
                       'String','mblend',...
                       'Callback', {@exportToWorkSpace,[],fh},...
                       'FontSize',fontsize);
  
  bhExport = uicontrol('Style', 'pushbutton',...
                       'String', 'Export to workspace',...
                       'Position', [430 45 150 20],...
                       'Callback', {@exportToWorkSpace,thExport,fh},...
                       'FontSize',fontsize);  
  
  thSave = uicontrol('Style','edit',...
                     'Position',[330 20 95 20],...
                     'HorizontalAlignment','left',...
                     'String','model.obj',...
                     'Callback', {@saveModel,[],fh},...
                     'FontSize',fontsize);
  
  bhSave = uicontrol('Style', 'pushbutton',...
                     'String', 'Save .obj file',...
                     'Position', [430 20 150 20],...
                     'Callback', {@saveModel,thSave,fh},...
                     'FontSize',fontsize);  
  
  
end

function updateWeight(src,event,fh,th,ah)
  w = get(src,'Value');
  setappdata(fh,'weight',w);
  updateBlend([],[],fh,th,ah);
end

function updateBlend(src,event,fh,th,ah)
  m1 = getappdata(fh,'m1');
  m2 = getappdata(fh,'m2');
  % mblend = getappdata(fh,'mblend');
  w = getappdata(fh,'weight');
  if ~isempty(m1) && ~isempty(m2)
    mblend = objBlend(m1,m2,1-w);
    axes(ah);
    try
      objShow(mblend,[],get(ah,'CameraPosition'));
    catch
      objShow(mblend);
    end
  else
    mblend = [];
  end
  set(th,'String',num2str(1-w));
  setappdata(fh,'mblend',mblend);
end

function resetView(src,event,fh,ah)
  m1 = getappdata(fh,'m1');
  m2 = getappdata(fh,'m2');
  mblend = getappdata(fh,'mblend');

  if ~isempty(m1)
    axes(ah(1));
    objShow(m1);
  end
  if ~isempty(mblend)
    axes(ah(2));
    objShow(mblend);
  end  
  if ~isempty(m2)
    axes(ah(3));
    objShow(m2);
  end
end

function exportToWorkSpace(src,event,th,fh)
  if isempty(th)
    h = src;
  else
    h = th;
  end
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  varname = get(h,'String');
  m = getappdata(fh,'mblend');
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
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  filename = get(h,'String');
  if isempty(regexp(filename,'\.obj$'))
    filename = [filename,'.obj'];
  end
  m = getappdata(fh,'mblend');
  m.filename = filename;
  objSave(m);
  pause(.2);
  set(h,'BackgroundColor',bgcol);  
end

function importFromWorkSpace(src,event,th,idx,fh,thw,ah)
  if isempty(th)
    h = src;
  else
    h = th;
  end
  bgcol = get(h,'BackgroundColor');
  set(h,'BackgroundColor',[.2 .8 .2]);
  varname = get(h,'String');

  m = evalin('base',varname);
  setappdata(fh,sprintf('m%d',idx),m);
  updateBlend([],[],fh,thw,ah);
  resetView([],[],fh,ah);
  pause(.2);
  set(h,'BackgroundColor',bgcol);  
end

