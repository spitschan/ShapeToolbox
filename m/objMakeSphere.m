function sphere = objMakeSphere(cprm,varargin)

% OBJMAKESPHERE
% 
% Usage:          objMakeSphere()
%                 objMakeSphere(cpar,[options])
%                 objMakeSphere(cpar,mpar,[options])
%        OR:
%                 sphere = objMakeSphere(...)
%
% A 3D model sphere with a modulated radius.  The function writes the
% vertices and faces into a Wavefront OBJ-file and optionally returns
% them as a structure.  The modulation is sinusoidal.
%
% Without any input arguments, makes the default sphere with a
% modulation in the azimuth direction at the frequency of 8 cycle/2pi,
% amplitude of 0.1, and phase of 0.
%
% The radius (before modulation) of the sphere is 1.  The modulation
% amplitude is in the units of the radius, so an amplitude of A will
% result in a radius between 1-A and 1+A.
%
% The input argument cpar defines the parameters for the modulation.
% The parameters are the frequency, amplitude, phase, and direction of
% modulation:
%   cpar = [freq ampl ph dir]
%
% The direction of modulation is either 0 (azimuth) or 1 (elevation).
% (Actually, any non-zero value will be interpreted as meaning
% elevation direction.)
%
% The frequency for modulation in the azimuth direction is in
% cycle/(2*pi).  The frequency for modulation in the elevation direction
% is in cycle/pi.  The values of azimuth go from 0 to 2*pi.  The
% values of elevation (altitude) go from -pi/2 to pi/2.  All
% modulation are sine modulations (phase 0 is the sine phase).
%
% It is possible to define several component modulations.  These
% modulations are added together.  Several components are defined in
% different rows of cpar:
%   cpar = [freq_1 ampl_1 ph_1 dir_1
%           freq_2 ampl_2 ph_2 dir_2
%           ...
%           freq_n ampl_n ph_n dir_n]
%
% Default values for amplitude, phase, and direction are .1, 0, and 0,
% respectively.  If the number of columns in cpar is less that four,
% the default values will be filled in.
%
% To produce more complex modulations, separate carrier and
% modulator components can be defined.  The carrier components are
% defined exactly as above.  The modulator modulates the amplitude of
% the carrier.  The parameters of the modulator(s) are given in the
% input argument mpar.  The format is exactly the same as in defining
% the carrier components in cpar.  If several modulator components are
% defined, they are added together.  Typically, you will probably want
% to use a very simple (usually a single-component) modulator.
% Default values are as with cpar.
%
% Optional input arguments can be given to define the number of vertex
% points or the filename for saving the object.
%
% To define the number of vertices in the model, use the option
% 'npoints' followed by a vector of length giving the number of points
% in the elevation and azimuth directions:
%  ...,'npoints',[m n],...
% Default numbers are m=128 (elevation), n=256 (azimuth).
%
% The model is saved in a text file.  The default name of the output
% text file is 'sphere.obj'.  A different filename can be gives as a
% string:
%   ...,'myfilename',...
% If the custom filename does not have an obj-extension, it will be
% added.
%
% If the output argument is specified, the vertices and faces plus
% some other information are returned in the fields of the output 
% structure.
%
% Examples:
% > objMakeSphere()             % Default, 8 cycles in the azimuth direction
% > objMakeSphere([0 0 0 0])    % Makes a smooth sphere, saved in sphere.obj
% > objMakeSphere([6 .2])       % Six modulation cycles, amplitude 0.2
%
% Modulation components in the two directions (added), save to plaid.obj:
% > objMakeSphere([8 .2 0 0; 4 .1 0 1],'plaid.obj') 
% (This will produce a kind of "plaid" pattern.)
%
% Same as above, but use fewer points for a quicker testing (will not
% look good when rendered, but might be useful for experimenting):
% > objMakeSphere([8 .2 0 0; 4 .1 0 1],'npoints',[64 128],'plaid.obj') 
%
% Two modulation components in the same (azimuth) direction,
% frequencies 4 and 12:
% > objMakeSphere([4 .15 0 0; 12 .15 0 0]) 
%
% A carrier with 8 cycles in the azimuth direction, its amplitude
% modulated by a 2-cycle modulator in the same direction, also return
% the model in the structure sph:
% > sph = objMakeSphere([8 .2 0 0],[2 1 0 0]) 
%
% When the carrier is in the azimuth direction, the modulation is very
% "sharp" near the poles where the longitudinal lines come close
% together.  To make the modulated sphere smoother close to the poles,
% use a modulator in the elevation direction.  In this example, use a
% modulator with a frequency of 1 (a single cycle, from pole to pole),
% an amplitude of 1 (so that the modulation goes to zero at its
% minimum), and a phase of pi/2 (so that the modulation is at its
% minimum, or zero, at the poles):
% > objMakeSphere([8 .2 0 0],[1 1 pi/2 1]) 
%
% Compare this with the same without the modulator:
% > objMakeSphere([8 .2 0 0]) 


% Toni Saarela, 2013
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

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
filename = 'sphere.obj';
mtlfilename = '';
mtlname = '';

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
      mprm = [mprm ones(nccomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nccomp,3)];
    case 3
      mprm = [mprm zeros(nccomp,2)];
    case 4
      mprm = [mprm zeros(nccomp,1)];
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

% m = m + 1;
% n = n + 1;

r = 1; % radius
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi/2,pi/2,m)'; % elevation

%--------------------------------------------

if any(cprm(:,2)>r)
  error('Modulation amplitude has to be less than sphere radius (1).');
end

%--------------------------------------------

[Theta,Phi] = meshgrid(theta,phi);

R = r + _objMakeSineComponents(cprm,mprm,Theta,Phi);

%R = r + R;

% Convert vertices to cartesian coordinates
[X,Y,Z] = sph2cart(Theta,Phi,R);

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

if ~isempty(mtlfilename)
  Phi = Phi';
  Theta = Theta';
  U = (Theta(:)-min(theta))/(max(theta)-min(theta));
  V = (Phi(:)-min(phi))/(max(phi)-min(phi));
  uvcoords = [U V];
end

faces = zeros((m-1)*n*2,3);

% Face indices

%tic
F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n n+1]',[n-1 1]); [n 1]'];
F(:,3) = F(:,3) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end
%toc

% Old method for determining the faces looped over the vertices and
% took more than a second.  The way above is much faster.
% tic
% for ii = 1:m-1
%   for jj = 1:n-1
%     faces((2*ii-2)*(n-1)+2*jj-1,:) = [(ii-1)*n+jj ii*n+jj ii*n+jj+1];
%     faces((2*ii-2)*(n-1)+2*jj,:) = [(ii-1)*n+jj ii*n+jj+1 (ii-1)*n+jj+1];
%   end
% end
% toc

if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
  sphere.npointsx = n;
  sphere.npointsy = m;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
for ii = 1:nccomp
  fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',cprm(ii,:));
end
fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
  for ii = 1:nmcomp
    fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',mprm(ii,:));
  end
  fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
end

if isempty(mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Faces:\n');
  fprintf(fid,'f %d %d %d\n',faces');
  fprintf(fid,'# End faces\n\n');
else
  fprintf(fid,'\n\nmtllib %s\nusemtl %s\n\n',mtlfilename,mtlname);
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n\n# Faces:\n');
  fprintf(fid,'f %d/%d %d/%d %d/%d\n',expmat(faces,[1,2])');
  fprintf(fid,'# End faces\n\n');
end
fclose(fid);


