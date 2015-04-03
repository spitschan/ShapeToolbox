function sphere = objMakeSphere(cprm,varargin)

  % OBJMAKESPHERE
  %
  % Usage:          objMakeSphere() 
  %                 objMakeSphere(CPAR,[OPTIONS])
  %                 objMakeSphere(CPAR,MPAR,[OPTIONS]) 
  %        SPHERE = objMakeSphere(...)
  %
  % A 3D model sphere with a modulated radius.  The function writes
  % the vertices and faces into a Wavefront OBJ-file and optionally
  % returns them as a structure.  The modulation components are
  % sinusoidal.
  %
  % Without any input arguments, makes the default sphere with a
  % modulation in the azimuth direction at the frequency of 8
  % cycle/2pi, amplitude of 0.1, and phase of 0.
  %
  % The input argument CPAR defines the parameters for the modulation.
  % The parameters are the frequency, amplitude, phase, and
  % orientation of modulation: 
  %   CPAR = [FREQ AMPL PH ANGLE]
  %
  % The frequency is in cycles per full circle, or cycle/(2*PI). The
  % values of azimuth go from -PI to PI-2*PI/N, where N is the number
  % of points (vertices) in that direction.  The values of elevation
  % (altitude) go from -PI/2 to PI/2. 
  % 
  % The unmodulated radius of the sphere is 1.  The modulation
  % amplitude is in the units of the radius, so an amplitude of A will
  % result in a radius between 1-A and 1+A.
  %
  % All modulations are sine modulations (phase 0 is the sine phase).
  % Phase is given in degrees.
  %
  % Orientation (angle) is given in degrees.  0 is "vertical", that
  % is, modulation in the azimuth direction.  90 is "horizontal", or
  % modulation as a function of elevation.
  %
  % It is possible to define several component modulations.  These
  % modulations are added together.  Several components are defined in
  % different rows of CPAR: 
  % CPAR = [FREQ1 AMPL1 PH1 ANGLE1 
  %         FREQ2 AMPL2 PH2 ANGLE2 
  %         ... 
  %         FREQN AMPLN PHN ANGLEN]
  %
  % Default values for amplitude, phase, and orientation are .1, 0, and
  % 0, respectively.  If the number of columns in CPAR is less that
  % four, the default values will be filled in.
  %
  % To produce more complex modulations, separate carrier and
  % modulator components can be defined.  The carrier components are
  % defined exactly as above.  The modulator modulates the amplitude
  % of the carrier.  The parameters of the modulator(s) are given in
  % the input argument MPAR.  The format is exactly the same as in
  % defining the carrier components in CPAR.  If several modulator
  % components are defined, they are added together.  Typically, you
  % will probably want to use a very simple (usually a
  % single-component) modulator. Default values are 1 for amplitude, 0
  % for phase and orientation.
  %
  % To define different modulators for different carriers (for
  % example, to use the modulators to modulate between two carriers),
  % define a group index for the components.  Carriers with the same
  % index are added together, and their amplitude is modulated by the
  % modulator(s) with that same group index.  The modulated components
  % are then added together.  The group index is the (optional) fifth 
  % entry of the parameter vector:
  %   CPAR = [FREQ1 AMPL1 PH1 ANGLE1 GROUP1
  %           ...
  %           FREQN AMPLN PHN ANGLEN GROUPN]
  % 
  %   MPAR = [FREQ1 AMPL1 PH1 ANGLE1 GROUP1
  %           ...
  %           FREQM AMPLM PHM ANGLEM GROUPM]
  %
  % Group index is a non-negative integer.  Group index 0 (the default
  % group index) is special: All carriers with index zero are added to
  % the other components WITHOUT first being multiplied with a
  % modulator.  Modulators with group index 0 multiply the sum of ALL
  % components, including components already multiplied by their own
  % modulators.  Gets confusing, right?  See examples below and in the
  % online help.
  %
  % Options:
  % A number of optional input arguments can be defined.  These are
  % typically key-value pairs, except in the case of an output file
  % name.  Possible options are:
  % 
  % 'NPOINTS' followed by a vector of two defines the number of vertices
  % in the two direction on the surface (elevation and azimuth):
  %   > objMakeSphere(...,'npoints',[m n],...)
  % Default number of vertices is 128x256.
  % 
  % The model is saved in a text file with an .obj-extension.  The
  % default name of the output text file is 'sphere.obj'.  A different
  % filename can be gives as an optional string argument: 
  %   > objMakeSphere(...,'myfilename',...)
  % If the custom filename does not have an obj-extension, it will be
  % added.
  %
  % 'MATERIAL' followed by a cell array with two text cells can be
  % used to define a material (mtl) file and a material name for the
  % object:
  %   > objMakeSphere(...,'material',{'materialfile.mtl','mymaterial'},...)
  %
  % 'NORMALS' followed by a boolean (or numeric) value to toggle the
  % computation of vertex normals.  Default is false, meaning the
  % normals are not computed.  Computing the normals will increase the
  % file size and many rendering programs compute the normals with
  % their own algorithm.  To turn the normal computation on:
  %   > objMakeSphere(...,'NORMALS',true,...)
  %
  % If an output argument is specified, the vertices and faces plus
  % some other information about the model are returned in the fields
  % of the output structure.
  %
  % Examples: 
  % > objMakeSphere()             % Default, 8 cycles in the azimuth direction 
  % > objMakeSphere([0 0 0 0])    % Makes a smooth sphere, saved in sphere.obj 
  % > objMakeSphere([6 .2])       % Six modulation cycles, amplitude 0.2
  % > objMakeSphere([8 .05 0 60]) % A 'spiral' pattern
  %
  % Two components in the same orientation:
  % > objMakeSphere([4 .15 0 0; 12 .15 0 0])
  %
  % Two components in different orientations, saved in plaid.obj: 
  % > objMakeSphere([8 .2 0 0; 8 .1 0 90],'plaid.obj')
  %
  % Same as above, but use more points for a finer mesh (and larger file):
  % > objMakeSphere([8 .2 0 0; 8 .1 0 90],'npoints',[256 512],'plaid.obj')
  %
  % A carrier with 8 cycles in the azimuth direction, its amplitude
  % modulated by a 2-cycle modulator in the same direction, also
  % return the model in the structure sph: 
  % > sph = objMakeSphere([8 .2 0 0],[2 1 0 0])
  %
  % Use a group index for carriers and modulators to alternate between
  % two carriers:
  % > cpar = [16 .1 0 60 1; 16 .05 0 -60 2]
  % > mpar = [4 1 0 0 1; 4 1 180 0 2]
  % > objMakeSphere(cpar,mpar)
  % 
  % The same modulation as above, but compute texture coordinates and
  % use material definitions from an mtl-file:
  % > objMakeSphere(cpar,mpar,'material',{'file.mtl','mymaterial'})
  %
  % When the carrier is in the azimuth direction, the modulation is
  % very "sharp" near the poles where the longitudinal lines come
  % close together.  To make the modulated sphere smoother close to
  % the poles, use a modulator in the elevation direction.  In this
  % example, use a modulator with a frequency of 1 (a single cycle,
  % from pole to pole), an amplitude of 1 (so that the modulation goes
  % to zero at its minimum), and a phase of 90 (so that the
  % modulation is at its minimum, or zero, at the poles): 
  % > objMakeSphere([8 .2 0 0],[2 1 90 90])
  %
  % Compare this with the same without the modulator: 
  % > objMakeSphere([8 .2 0 0])


% Copyright (C) 2013,2014,2015 Toni Saarela
% 2013-10-09 - ts - first version
% 2013-10-10 - ts - added option for different amplitudes for the two modulations
%                   added a choice for multiplying or adding the two modulations
% 2013-10-11 - ts - udpated help
%                   new version objMakeSphere2: can have several component modulations in each dir
% 2013-10-12 - ts - radius modulation calculated outside the main loop
% 2013-10-14 - ts - renamed back to objMakeSphere;
%                    added some 'help'
% 2013-10-15 - ts - added phase; minor changes and fixes; fixed writing the freqs etc in 
%                    the comments of the obj-file
% 2013-10-28 - ts - triangular instead of quad faces
% 2014-04-01 - ts - help examples updated
% 2014-05-06 - ts - help examples updated
% 2014-07-30 - ts - * Merged objMakeSphere and objMakeSphereMod
%                   * An optional modulator can be used to modulate the
%                     carrier
%                   * Removed the blendmethod-options: multiple carriers
%                     are always added together, modulator and carrier
%                     multiply
%                   * Option to give the grid resolution as input
%                   * Write more specs to obj-file; return more specs
%                     in the structure
% 2014-08-06 - ts - simplified the computation of carriers (no loop) and
%                    modulators, new format for giving the modulation
%                    parameters
%                   updated help  
% 2014-08-07 - ts - better initialization of matrices; additions to help;
%                   significantly speeded up the computation of faces
% 2014-10-12 - ts - now possible to use the modulators to modulate
%                    between two (or more) carriers
% 2014-10-14 - ts - added an option to compute texture coordinates and
%                    include a mtl file reference
% 2014-10-27 - ts - cleaning and tidying; fixed writing specs in obj
%                    file comments; return also uv-coords; help
%                    updated; fixed wrapping of uv-coordinates
% 2014-10-28 - ts - improved face computation
% 2014-10-29 - ts - added optional computation of vertex normals
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated

% TODO
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% More error checking on parameters (including modulator)
% UPDATE HELP UPDATE HELP UPDATE HELP

%--------------------------------------------

% Carrier parameters

% Set default frequency, amplitude, phase, "orientation"  and component group id

if ~nargin || isempty(cprm)
  cprm = [8 .1 0 0 0];
end

[nccomp,ncol] = size(cprm);

switch ncol
  case 1
    cprm = [cprm ones(nccomp,1)*[.05 0 0 0]];
  case 2
    cprm = [cprm zeros(nccomp,3)];
  case 3
    cprm = [cprm zeros(nccomp,2)];
  case 4
    cprm = [cprm zeros(nccomp,1)];
end

cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material filename.
mprm  = [];
nmcomp = 0;
filename = 'sphere.obj';
mtlfilename = '';
mtlname = '';
comp_normals = false;
dosave = true;
new_model = true;

% Number of vertices in azimuth and elevation directions, default values
n = 256;
m = 128;

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
      mprm = [mprm ones(nmcomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nmcomp,3)];
    case 3
      mprm = [mprm zeros(nmcomp,2)];
    case 4
      mprm = [mprm zeros(nmcomp,1)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
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
         case 'normals'
           if ii<length(par) && isscalar(par{ii+1})
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
             sphere = par{ii};
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
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  phi = linspace(-pi/2,pi/2,m)'; % elevation

  [Theta,Phi] = meshgrid(theta,phi);
  Theta = Theta'; Theta = Theta(:);
  Phi   = Phi';   Phi   = Phi(:);
else
  m = sphere.m;
  n = sphere.n;
  Theta = sphere.Theta;
  Phi = sphere.Phi;
  r = sphere.R;
end

if any(cprm(:,2)>r)
  error('Modulation amplitude has to be less than sphere radius (1).');
end

R = r + objMakeSineComponents(cprm,mprm,Theta,Phi);

% Convert vertices to cartesian coordinates
[X,Y,Z] = sph2cart(Theta,Phi,R);

vertices = [X Y Z];

clear X Y Z

% The field prm can be made an array.  If the structure sphere is
% passed to another objMakeSphere*-function, that function will add
% its parameters to that array.
if new_model
  sphere.prm.cprm = cprm;
  sphere.prm.mprm = mprm;
  sphere.prm.nccomp = nccomp;
  sphere.prm.nmcomp = nmcomp;
  sphere.prm.mfilename = mfilename;
  sphere.normals = [];
else
  ii = length(sphere.prm)+1;
  sphere.prm(ii).cprm = cprm;
  sphere.prm(ii).mprm = mprm;
  sphere.prm(ii).nccomp = nccomp;
  sphere.prm(ii).nmcomp = nmcomp;
  sphere.prm(ii).mfilename = mfilename;
  sphere.normals = [];
end
sphere.shape = 'sphere';
sphere.filename = filename;
sphere.mtlfilename = mtlfilename;
sphere.mtlname = mtlname;
sphere.comp_normals = comp_normals;
sphere.n = n;
sphere.m = m;
sphere.Theta = Theta;
sphere.Phi = Phi;
sphere.R = R;
sphere.vertices = vertices;

if dosave
  sphere = objSaveModelSphere(sphere);
end

if ~nargout
   clear sphere
end

