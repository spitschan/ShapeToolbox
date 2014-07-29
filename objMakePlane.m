function plane = objMakePlane(f,a,filename)

% OBJMAKEPLANE
% 
% Usage:          objMakePlane()
%                 objMakePlane(f,a,filename)
%        plane = objMakePlane(f,a,filename)
%
% f is the frequency of the modulation of the radius
% in cycles per plane; default = 8.  f can be a vector 
% of two to define modulations in both azimuth and 
% elevation, e.g., f = [8 4].
%
% a gives the amplitude of the modulation; default = .1.
% (Radius of the plane is 1.)
% 
% The model is saved in a text file.  The optional input 
% argument filename can be used to define the name of the
% file.  Default is 'plane.obj'.
%
% Any of the input arguments can be omitted or left empty.
%       
% If the output argument is specified, the vertices and faces 
% are returned in the structure plane.

% Toni Saarela, 2013
% 2013-10-09 - ts - first version

% TODO
% WRITE HELP (the current one is for the sphere function)
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% Add option for a second frequency, added to the first one
% Or wait, should it be multiplied?  Added, I suppose

%--------------------------------------------

if ~nargin || isempty(f)
  f = 8;
end

if nargin<2 || isempty(a)
  a = .1;
end

if nargin<3 || isempty(filename)
  filename = 'plane.obj';
elseif isempty(regexp(fn,'\.obj$'))
  filename = [filename,'.obj'];
end

m = 256 + 1;
n = 256 + 1;

r = 1; % extent of the plane, goes from -r to r in both x and y
x = linspace(-r,r,m); % azimuth
y = linspace(-r,r,n); % elevation

f = f/(2*r);

%--------------------------------------------

if a<0
  error('Modulation amplitude has to be positive.');
end

%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);

if length(f)>1
  Z = a*sin(2*pi*f(1)*X).*sin(2*pi*f(2)*Y);
  %Z = a*sin(2*pi*f(2)*Y);
else
  Z = a*sin(2*pi*f*X);
end

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

for ii = 1:n-1
  for jj = 1:m-1
    faces((ii-1)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1 (ii-1)*m+jj+1];
  end
end

if nargout
  plane.vertices = vertices;
  plane.faces = faces;
end

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Modulation frequency (x): %4.2f.\n',f(1));
if length(f)>1
  fprintf(fid,'# Modulation frequency (y): %4.2f.\n',f(2));
end
fprintf(fid,'# Modulation amplitude: %4.2f.\n',a);
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
fprintf(fid,'f %d %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);

