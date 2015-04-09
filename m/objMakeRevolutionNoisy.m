function solid = objMakeRevolutionNoisy(curve,nprm,varargin)

% OBJMAKEREVOLUTIONNOISY
%
% Usage: solid = objMakeRevolutionNoisy(curve,nprm,[OPTIONS])
%
% Note: if modifying an existing model, the first input argument (the
% curve) is ignored.  Just leave it empty.


% Copyright (C) 2015 Toni Saarela
% 2015-04-05 - ts - first version

%--------------------------------------------------

ncurve = length(curve);
m = ncurve;
n = ncurve;

if nargin<2 || isempty(nprm)
  nprm = [8 1 0 45 .1 0];
end

[nncomp,ncol] = size(nprm);

if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material...
mprm  = [];
nmcomp = 0;
filename = 'revolutionnoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';
comp_normals = false;
dosave = true;
new_model = true;

% Number of vertices in the two directions, default values
%m = 256;
%n = 256;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
   mprm = modpar{1};
end

% Set default values to modulator parameters as needed
if ~isempty(mprm)
  [nmcomp,ncol] = size(mprm);
  switch ncol
    case 1
      mprm = [mprm ones(nncomp,1)*[.1 0 0 0]];
    case 2
      mprm = [mprm zeros(nncomp,3)];
    case 3
      mprm = [mprm zeros(nncomp,2)];
    case 4
      mprm = [mprm zeros(nncomp,1)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

if ~isempty(par)
   ii = 1;
   while ii<=length(par)
     if ischar(par{ii})
       switch lower(par{ii})
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             m = par{ii}(1);
             n = par{ii}(2);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             mtlfilename = par{ii}{1};
             mtlname = par{ii}{2};
           else
             error('No value or a bad value given for option ''material''.');
           end
         case 'rms'
           use_rms = true;
         case 'normals'
           if ii<length(par) && (isnumeric(par{ii+1}) || islogical(par{ii+1}))
             ii = ii + 1;
             comp_normals = par{ii};
           else
             error('No value or a bad value given for option ''normals''.');
           end
         case 'save'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             dosave = par{ii};
           else
             error('No value or a bad value given for option ''save''.');
           end              
         case 'model'
           if ii<length(par) && isstruct(par{ii+1})
             ii = ii + 1;
             solid = par{ii};
             new_model = false;
           else
             error('No value or a bad value given for option ''model''.');
           end
         otherwise
           filename = par{ii};
       end
     end
     ii = ii + 1;
   end
end
  
% Add file name extension if needed
if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

%--------------------------------------------
% Vertices 

if new_model
  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 
  
  [Theta,Y] = meshgrid(theta,y);

  if ncurve~=m
    curve = interp1(linspace(0,1,ncurve),curve,linspace(0,1,m));
  end
  
  %R = r*repmat(curve(:)',[n 1])';
  R = r * repmat(curve(:),[1 n]);

else
  curve = solid.curve;
  m = solid.m;
  n = solid.n;
  Theta = reshape(solid.Theta,[n m])';
  Y = reshape(solid.Y,[n m])';
  R = reshape(solid.R,[n m])';
end

R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,use_rms);

Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);
R = R'; R = R(:);

X =  R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if new_model
  solid.prm.nprm = nprm;
  solid.prm.mprm = mprm;
  solid.prm.nncomp = nncomp;
  solid.prm.nmcomp = nmcomp;
  solid.prm.use_rms = use_rms;
  solid.prm.mfilename = mfilename;
  solid.normals = [];
else
  ii = length(solid.prm)+1;
  solid.prm(ii).nprm = nprm;
  solid.prm(ii).mprm = mprm;
  solid.prm(ii).nncomp = nncomp;
  solid.prm(ii).nmcomp = nmcomp;
  solid.prm(ii).use_rms = use_rms;
  solid.prm(ii).mfilename = mfilename;
  solid.normals = [];
end
solid.shape = 'revolution';
solid.filename = filename;
solid.mtlfilename = mtlfilename;
solid.mtlname = mtlname;
solid.comp_normals = comp_normals;
solid.curve = curve;
solid.n = n;
solid.m = m;
solid.Theta = Theta;
solid.Y = Y;
solid.R = R;
solid.vertices = vertices;

if dosave
  solid = objSaveModelCylinder(solid);
end

if ~nargout
   clear solid
end
