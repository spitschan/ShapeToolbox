function cylinder = objMakeCylinder(cprm,varargin)

% OBJMAKECYLINDER 
%

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-10 - ts - first version
% 2014-10-19 - ts - switched to using an external function to compute
%                   the modulation
% 2014-10-20 - ts - added texture mapping
% 2015-01-16 - ts - fixed the call to renamed objMakeSineComponents
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default parameters

% TODO
% Add an option to define whether modulations are done in angle
% (theta) units or distance units.
% Add modulators
% More and better parsing of input arguments
% HEEEEEEEEEEEELLLLLLLLLLLPPPPPPPPPP

%--------------------------------------------

defprm = [8 .1 0 0 0];

if ~nargin || isempty(cprm)
  cprm = defprm;
end

[nccomp,ncol] = size(cprm);

% Fill in default carrier parameters if needed
if ncol<5
  defprm = ones(nccomp,1)*defprm;
  cprm(:,ncol+1:5) = defprm(:,ncol+1:5);
end
clear defprm

cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no
% modulator; set default filename.
mprm  = [];
nmcomp = 0;

opts.filename = 'cylinder.obj';
opts.m = 256; 
opts.n = 256;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
  mprm = modpar{1};
  % Set default values to modulator parameters as needed
  [nmcomp,ncol] = size(mprm);
  if ncol<5
    defprm = ones(nmcomp,1)*[1 0 0 0];
    mprm(:,ncol+1:5) = defprm(:,ncol:4);
    clear defprm
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
[opts,cylinder] = objParseArgs(opts,par);
  
%--------------------------------------------
% Vertices

if opts.new_model
  m = opts.m;
  n = opts.n;

  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 
  
  [Theta,Y] = meshgrid(theta,y);
  Theta = Theta'; Theta = Theta(:);
  Y = Y'; Y = Y(:);
else
  m = cylinder.m;
  n = cylinder.n;
  Theta = cylinder.Theta;
  Y = cylinder.Y;
  r = cylinder.R;
end

R = r + objMakeSineComponents(cprm,mprm,Theta,Y);;

% Convert vertices to cartesian coordinates
X =  R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if opts.new_model
  cylinder.prm.cprm = cprm;
  cylinder.prm.mprm = mprm;
  cylinder.prm.nccomp = nccomp;
  cylinder.prm.nmcomp = nmcomp;
  cylinder.prm.mfilename = mfilename;
  cylinder.normals = [];
else
  ii = length(cylinder.prm)+1;
  cylinder.prm(ii).cprm = cprm;
  cylinder.prm(ii).mprm = mprm;
  cylinder.prm(ii).nccomp = nccomp;
  cylinder.prm(ii).nmcomp = nmcomp;
  cylinder.prm(ii).mfilename = mfilename;
  cylinder.normals = [];
end
cylinder.shape = 'cylinder';
cylinder.filename = opts.filename;
cylinder.mtlfilename = opts.mtlfilename;
cylinder.mtlname = opts.mtlname;
cylinder.comp_uv = opts.comp_uv;
cylinder.comp_normals = opts.comp_normals;
cylinder.n = n;
cylinder.m = m;
cylinder.Theta = Theta;
cylinder.Y = Y;
cylinder.R = R;
cylinder.vertices = vertices;

if opts.dosave
  cylinder = objSaveModel(cylinder);
end

if ~nargout
   clear cylinder
end
