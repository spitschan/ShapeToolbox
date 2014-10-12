function cylinder = objMakeCylinder(cprm)

% OBJMAKECYLINDER 
%

% Toni Saarela, 2014
% 2014-10-10 - ts - first version

% TODO
% Add an option to define whether modulations are done in angle
% (theta) units or distance units.
% Add modulators
% More and better parsing of input arguments

if ~nargin || isempty(cprm)
  cprm = [8 .1 0 0];
end

[nccomp,ncol] = size(cprm);

cprm(:,3:4) = pi * cprm(:,3:4)/180;

filename = 'cylinder.obj';

% Number of vertices in azimuth and elevation directions
m = 256; 
n = 256;

cprm(:,1) = cprm(:,1)/(2*pi);
r = 1; % radius
h = 2*pi*r; % height
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
y = linspace(-h/2,h/2,m); % 

%--------------------------------------------

[Theta,Y] = meshgrid(theta,y);
Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);

% Make the (compound) carrier
C = zeros(m*n,1);
for ii = 1:nccomp
  C = C + cprm(ii,2) * sin(2*pi*cprm(ii,1)*(Theta*cos(cprm(ii,4))-Y*sin(cprm(ii,4)))+cprm(ii,3));
end

% Multiply carrier by modulator, add to culinder radius to get the 
% modulated radius
%R = r + M.*C;
R = r + C;

% Convert vertices to cartesian coordinates
X = R .* cos(Theta);
Z = R .* sin(Theta);
%[X,Y,Z] = sph2cart(ones(m,1)*theta,phi*ones(1,n),R);

%X = X'; X = X(:);
%Y = Y'; Y = Y(:);
%Z = Z'; Z = Z(:);

vertices = [X Y Z];

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

if nargout
  cylinder.vertices = vertices;
  cylinder.faces = faces;
  cylinder.npointsx = n;
  cylinder.npointsy = m;
end

# Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Orientation\n');
for ii = 1:nccomp
  fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',cprm(ii,:));
end
## if ~isempty(mprm)
##   fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
##   fprintf(fid,'#  Frequency | Amplitude | Phase | Orientation\n');
##   for ii = 1:nmcomp
##     fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',mprm(ii,:));
##   end
## end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);

