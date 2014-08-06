function sphere = objMakeSphere(f,a,ph,varargin)

% OBJMAKESPHERE
% 
% Usage:          objMakeSphere()
%                 objMakeSphere(f,a,ph,options)
%                 objMakeSphere(f,a,ph,fmod,amod,phmod,options)
%        OR:
%                 sphere = objMakeSphere(...)
%
% f is the frequency of the modulation of the radius
% in cycles per sphere; default = 8.  f can be a row vector 
% of two to define modulations in both azimuth and 
% elevation, e.g., f = [8 4].  The frequencies are in
% cycles per 360 degrees.
%
% f can also have several rows.  The entries in all rows
% in the first column define frequencies for several components
% in the azimuth direction, the second column, elevation.  See
% below how to define the method for combining the components. 
%
% a gives the amplitude of the modulation; default = .1.
% (Radius of the sphere is 1.)  If two frequencies are defined,
% a can also be a row vector of two, defining, two amplitudes.
% 
% If f has several rows (that define multiple components in each
% direction, see above), a should have the same size as f, defining
% the amplitudes.
%
% ph is the phase for all components.  Size of ph should equal the size
% of f.  Default is zero (sin phase) for all components.
%
% If there are multiple components in each direction defined (number
% of rows in f is greater than one), blendmethod should be a cell
% array of two.  The first cell gives the method for combining the
% components in the azimuth and elevation directions, the second 
% cell gives the method for combining the components within a 
% direction.
% 
% The model is saved in a text file.  The optional input 
% argument filename can be used to define the name of the
% file.  Default is 'sphere.obj'.
%
% Any of the input arguments can be omitted or left empty.
%       
% If the output argument is specified, the vertices and faces 
% are returned in the fields of the structure sphere.
%
% Examples:
% > objMakeSphere([],0)            % Makes a smooth sphere
% > objMakeSphere(8)               % Eight modulation cycles
%
% Identical modulation frequency in both directions, added, save to plaid.obj
% > objMakeSphere([8 8],[.2 .1],[0 0],'','plaid.obj') 
% (This will produce a kind of "plaid" pattern.)
%
% Identical modulation frequency in both directions, multiplied, save to foo.obj:
% > objMakeSphere([8 8],[.2 .2],[],'multiply','foo')  
%
% Note that in the above case, the modulation frequency seems to double
% because of the multiplication.  To get a more even result, use:
% > objMakeSphere([8 4],[.2 .2],[],'multiply','foo')  
%
% Modulation only as a function of elevation:
% > objMakeSphere([0 8],[0 .2],[0 0],'add')


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

% TODO
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% UPDATE HELP!
% More error checking on parameters (including modulator)
% Initialize all matrices properly

%--------------------------------------------


% Carrier parameters
% Set default frequency if necessary
if ~nargin || isempty(f)
  f = 8;
end

% Default amplitude
if nargin<2 || isempty(a)
  a = .1 * ones(size(f));
end

% Default phase
if nargin<3 || isempty(ph)
  ph = zeros(size(f));
end

% Set the default modulation parameters to empty indicating no modulator; set default filename.
fmod  = [];
amod  = [];
phmod = [];
filename = 'sphere.obj';

% Number of vertices in azimuth and elevation directions, default values
n = 256;
m = 128;


[modpar,par] = parseparams(varargin);

if ~isempty(modpar)
  if length(modpar)==1
    fmod = modpar{1};
  elseif length(modpar)==2
    fmod = modpar{1};
    amod = modpar{2};
  else
    fmod = modpar{1};
    amod = modpar{2};
    phmod = modpar{3};
  end
end

if ~isempty(par)
   ii = 1;
   while ii<=length(par)
     if ischar(par{ii})
       switch lower(par{ii})
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             m = par{ii}(2);
             n = par{ii}(1);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         otherwise
           filename = par{ii};
       end
     end
     ii = ii + 1;
   end
end

% Set the default values for modulation amplitude and phase.
% Make these the same size as fmod
if ~isempty(fmod)
  if isempty(amod)
    amod = .1 * ones(size(fmod));
  end
  if isempty(phmod)
    phmod = zeros(size(fmod));
  end
end


  
% Add file name extension if needed
if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

m = m + 1;
n = n + 1;

r = 1; % radius
theta = linspace(-pi,pi,n); % azimuth
phi = linspace(-pi/2,pi/2,m); % elevation


%--------------------------------------------

if any(a(:)<0) || any(a(:)>r)
  error('Modulation amplitude has to be positive and less than sphere radius.');
end

%--------------------------------------------

if ~isempty(fmod)
  modaz = .5 * (1 + amod(1) * sin(fmod(1)*theta+phmod(1)));
  if length(fmod)>1
    model = .5 * (1 + amod(2) * sin(fmod(2)*phi+phmod(2)));
  else
    model = ones(size(phi));
  end
else
  modaz = ones(size(theta));
  model = ones(size(phi));
end

for ii = 1:size(f,1)
  carraz(ii,:) = a(ii,1)*sin(f(ii,1)*(theta)+ph(ii,1));
  if size(f,2)>1
    carrel(ii,:) = a(ii,2)*sin(f(ii,2)*(phi)+ph(ii,2));
  end  
end

if size(f,1)>1
  carraz = sum(carraz,1);
  if size(f,2)>1
    carrel = sum(carrel,1);
  end   
end

vertices = zeros(m*n,3);
for el = 1:m
  for az = 1:n
    if size(f,2)>1
      rtmp = r + modaz(az)*carraz(az) + model(el)*carrel(el);
    else
      rtmp = r + modaz(az)*carraz(az);
    end
    
    % Spherical to cartesian coordinates
    [x,y,z] = sph2cart(theta(az),phi(el),rtmp);
    vertices((el-1)*n+az,:) = [x y z];
    
  end
end

% Face indices
for ii = 1:m-1
  for jj = 1:n-1
    %faces((ii-1)*(n-1)+jj,:) = [(ii-1)*n+jj ii*dnm+jj ii*n+jj+1 (ii-1)*n+jj+1];

    %faces((2*ii-2)*(n-1)+jj,:) = [(ii-1)*n+jj ii*n+jj ii*n+jj+1];
    %faces((2*ii-1)*(n-1)+jj,:) = [(ii-1)*n+jj ii*n+jj+1 (ii-1)*n+jj+1];

    faces((2*ii-2)*(n-1)+2*jj-1,:) = [(ii-1)*n+jj ii*n+jj ii*n+jj+1];
    faces((2*ii-2)*(n-1)+2*jj,:) = [(ii-1)*n+jj ii*n+jj+1 (ii-1)*n+jj+1];
    
  end
end

if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
  sphere.npointsx = m-1;
  sphere.npointsy = n-1;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'# Modulation carrier frequency (azimuth): %4.2f.\n',f(:,1));
fprintf(fid,'# Modulation carrier amplitude (azimuth): %4.2f.\n',a(:,1));
fprintf(fid,'# Modulation carrier phase (azimuth): %4.2f.\n',ph(:,1));
if size(f,2)>1
  fprintf(fid,'# Modulation carrier frequency (elevation): %4.2f.\n',f(:,2));
  fprintf(fid,'# Modulation carrier amplitude (elevation): %4.2f.\n',a(:,2));
  fprintf(fid,'# Modulation carrier phase (elevation): %4.2f.\n',ph(:,2));
end
if ~isempty(fmod)
  fprintf(fid,'# Modulator frequency (azimuth): %4.2f.\n',fmod(:,1));
  fprintf(fid,'# Modulator amplitude (azimuth): %4.2f.\n',amod(:,1));
  fprintf(fid,'# Modulator phase (azimuth): %4.2f.\n',phmod(:,1));
  if length(fmod)>1
    fprintf(fid,'# Modulator frequency (elevation): %4.2f.\n',fmod(:,2));
    fprintf(fid,'# Modulator amplitude (elevation): %4.2f.\n',amod(:,2));
    fprintf(fid,'# Modulator phase (elevation): %4.2f.\n',phmod(:,2));
  end   
end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
%fprintf(fid,'f %d %d %d %d\n',faces');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);
