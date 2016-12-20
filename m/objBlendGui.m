function objBlendGui(m1,m2)

% OBJBLEND
  
%
% Usage: MODEL = OBJBLEND(MODEL1,MODEL2,[W],[OPTIONS])
%                OBJBLEND(MODEL1,MODEL2,[W],[OPTIONS])
%
% Blend (compute a weighted average of) two model objects.  
%
% INPUT MODELS AND WEIGHTS:
% =========================
% 
% With a scalar weight W (which has to be in 0-1), give weight W to
% MODEL1 and weight 1-W to MODEL2.
%
% With a two-vector weight W=[W1 W2], weight the models in proportions
% W1/(W1+W2) and W2/(W1+W2).
%
% If the weight is omitted, average the models (weights 0.5 and 0.5).
% 
% The input models (MODEL1 and MODEL2) are structures returned by the
% objMake*-functions.  Models with the same base shape (sphere, plane,
% torus...) can be blended.  Additionally, cylinders, surfaces of
% revolution, and extrusions can be blended.  The mesh resolution of
% the two models has to match.
%
% RETURNS:
% ========
% 
% A new model structure.  NOTE: At the moment, the returned model only
% contains the parameters of the first model.  These are also written
% into the obj-file comments.
% 
% OPTIONS:
% ========
% 
% FILENAME
% A single string giving the name of the file in which to
% save the model.  If a filename is set, the option 'save' (see below)
% is set to true.  Example: 
%   objBlend(m1,m2,.5,'blended.obj',...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is false, the
% model is not saved.  You might want to keep this as false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Set to true to save the model
% you want to keep.  Example: 
%   m = objBlend(...,'save',false,...)
% saves the model with the default filename.  The default filename is
% the shape of the first model, followed by the weight for each model,
% for example 'plane_080_020.obj' for a plane where the two weights
% are 0.8 and 0.2.
% 
%
% EXAMPLES:
% =========
%
% % Make models:
% m1 = objMakeNoise('sphere',[]);
% m2 = objMakeBump('sphere',[]);
%
% % Blend 50-50, save in 'sphere_050_050.obj':
% objBlend(m1,m2,'save',true)
%
% % Save the same model in 'blob.obj':
% objBlend(m1,m2,'blob.obj')
%
% % Weights 0.2 and 0.8, not saved:
% m = objBlend(m1,m2,0.2);
%
% % Weights again 0.2 and 0.8, save in 'blob.obj':
% m = objBlend(m1,m2,[4 16],'blob.obj');

% Copyright (C) 2015,2016 Toni Saarela
% 2015-04-03 - ts - first version
% 2015-05-14 - ts - eats cylinders; other minor tweaks
% 2015-05-14 - ts - devours tori, surfaces of revolution
%                   wrote help, added options, saving of model
% 2015-06-02 - ts - updated help; fixed a bug in setting default weights
% 2015-06-16 - ts - added handling of extrusions.  cylinders,
%                   revolutions, and extrusions can be blended.
%                   updated help
% 2016-01-21 - ts - append filename extension if needed
%                   improved handling of input args (weight)
%                   blend also model size, not only modulation
%                   calls objMakeVertices
% 2016-03-26 - ts - calls the renamed objSave (formerly objSaveModel)
% 2016-06-20 - ts - fixed handling empty weight vector
% 2016-09-23 - ts - allow blending worm with cylinder-like things

% Copyright (C) 2016 Toni Saarela
% 2016-12-16 - ts - first version
  
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
                          'Callback', {@importFromWorkSpace,thImport,1,fh,th,ah},...
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
                          'Callback', {@importFromWorkSpace,thImport,2,fh,th,ah},...
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

