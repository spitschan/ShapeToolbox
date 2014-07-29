function sphere = objMakeSphere(f,a,ph,blendmethod,filename)

% OBJMAKESPHERE
% 
% Usage:          objMakeSphere()
%                 objMakeSphere(f,a,ph,blendmethod,filename)
%        sphere = objMakeSphere()
%        sphere = objMakeSphere(f,a,ph,blendmethod,filename)
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
% blendmethod is either 'multiply' or 'add' (default).  It defines
% how the two modulations are combined.  Note that setting separate
% amplitudes really makes sense only when the blendmethod is 'add'.
% When using 'multiply', you can always set one amplitude to 1
% and control the modulation amplitude with the other.
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

% TODO
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% Add option for a second frequency, added to the first one
% Or wait, should it be multiplied?  Added, I suppose
% Add option for rotation.  Or make a separate function?
% Add a modulator that modulates carrier amplitude
% Check input argument checking and default parameters
% Update examples in help.

%--------------------------------------------


% Set default frequency if necessary
if ~nargin || isempty(f)
  f = 8;
end

% Default amplitude
if nargin<2 || isempty(a)
  a = .1 * ones(size(f));
end

if nargin<3 || isempty(ph)
  ph = zeros(size(f));
end

if nargin<4 || isempty(blendmethod)
  if size(f,1)>1
    blendmethod = {'add','add'};
  else
    blendmethod = {'add'};
  end
end

if ischar(blendmethod)
  blendmethod = {blendmethod};
end
  
% Default file name
if nargin<5 || isempty(filename)
  filename = 'sphere.obj';
elseif isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

% Number of vertices in azimuth and elevation directions
m = 256 + 1;
n = 128 + 1;

r = 1; % radius
theta = linspace(-pi,pi,m); % azimuth
phi = linspace(-pi/2,pi/2,n); % elevation


%--------------------------------------------

if any(a(:)<0) || any(a(:)>r)
  error('Modulation amplitude has to be positive and less than sphere radius.');
end

%--------------------------------------------

for ii = 1:size(f,1)
  modaz(ii,:) = a(ii,1)*sin(f(ii,1)*(theta)+ph(ii,1));
  if size(f,2)>1
    model(ii,:) = a(ii,2)*sin(f(ii,2)*(phi)+ph(ii,2));
  end  
end

if size(f,1)>1
  switch blendmethod{2}
   case 'multiply'
    modaz = prod(modaz,1);
    if size(f,2)>1
      model = prod(model,1);
    end
   case 'add'
    modaz = sum(modaz,1);
    if size(f,2)>1
      model = sum(model,1);
    end   
  end
end

vertices = zeros(m*n,3);
for el = 1:n
  for az = 1:m
    
    if size(f,2)>1
      switch blendmethod{1}
       case 'multiply'
        rtmp = r + modaz(az) * model(el);
       case 'add'
        rtmp = r + modaz(az) + model(el);
       otherwise
        error('Bad value for ''blendmethod''.');
      end
    else
      rtmp = r + modaz(az);
    end
    
    % Spherical to cartesian coordinates
    [x,y,z] = sph2cart(theta(az),phi(el),rtmp);
    vertices((el-1)*m+az,:) = [x y z];
    
  end
end

% Face indices
for ii = 1:n-1
  for jj = 1:m-1
    %faces((ii-1)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1 (ii-1)*m+jj+1];

    %faces((2*ii-2)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1];
    %faces((2*ii-1)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj+1 (ii-1)*m+jj+1];

    faces((2*ii-2)*(m-1)+2*jj-1,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1];
    faces((2*ii-2)*(m-1)+2*jj,:) = [(ii-1)*m+jj ii*m+jj+1 (ii-1)*m+jj+1];
    
  end
end

if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Modulation frequency (azimuth): %4.2f.',f(:,1));
fprintf(fid,'\n# Modulation amplitude (azimuth): %4.2f.',a(:,1));
if size(f,2)>1
  fprintf(fid,'\n# Modulation frequency (elevation): %4.2f.',f(:,2));
  fprintf(fid,'\n# Modulation amplitude (elevation): %4.2f.',a(:,2));
end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
%fprintf(fid,'f %d %d %d %d\n',faces');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);

