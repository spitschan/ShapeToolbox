function plane = objMakePlaneNoise(prm,filename)

%

% Toni Saarela, 2013
% 2013-10-15 - ts - first, rudimentary version
% 2014-10-09 - ts - improved speed, included filtering function,
%                   added input arguments/options
% 2014-10-11 - ts - improved filtering function, added orientation filtering

%--------------------------------------------

% TODO
% Define rms contrast instead of amplitude
% Add an option for unequal size in x and y -- see objMakePlane

if ~nargin || isempty(prm)
  prm = [8 1 0 pi/4 .2];
end

nccomp = size(prm,1);

f = prm(:,1);
fw = prm(:,2);
th = prm(:,3);
thw = prm(:,4);
a = prm(:,5);

use_rms = false;

if nargin<2 || isempty(filename)
  filename = 'planenoisy.obj';
elseif isempty(regexp(fn,'\.obj$'))
  filename = [filename,'.obj'];
end

m = 256;
n = 256;

r = 1; % extent of the plane, goes from -r to r in both x and y
x = linspace(-r,r,m); % azimuth
y = linspace(-r,r,n); % elevation

%f = f/(2*r);

%--------------------------------------------

if a<0
  error('Modulation amplitude has to be positive.');
end

%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);

Z = zeros([m n nccomp]);
I = zeros([m n]);
for ii = 1:nccomp
  I = normrnd(0,1,[m n]);
  I = imgFilterBand(I,f(ii),fw(ii),th(ii),thw(ii));%,0,pi/2);
  if use_rms
    I = a(ii) * I / sqrt(I(:)'*I(:)/(m*n));
  else
    I = a(ii) * I / max(abs(I(:)));
  end
  Z(:,:,ii) = I;
end
Z = sum(Z,3);
%keyboard

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

faces = zeros((m-1)*(n-1)*2,3);

%tic
F = ([1 1]'*[1:n-1]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + repmat([n n+1]',[n-1 1]);
F(:,3) = F(:,3) + repmat([n+1 1]',[n-1 1]);
for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end
%toc

if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  plane.npointsx = n;
  plane.npointsy = m;
end

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));


fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);



%-------------------------------------------------
% Functions

function If = imgFilterBand(I,f0,fw,th0,thw)

% IMGFILTERBAND
%
% Usage:  If = imgFilterBand(I,f0,fw,th0,thw)
%

% Toni Saarela, 2014
% 2014-10-11 - ts - first version

F = fftshift(fft2(I));

[m,n] = size(F);

u = [-m:2:m-2]/m;
v = [-n:2:n-2]/n;
[U,V] = meshgrid(u,v);
fnyquist = m / 2;
f0 = f0 / fnyquist;

% Full width at half-height to sd:
sigma  = sqrt(-(2^(fw/2)-1)^2*f0/(2^(fw/2)*log(.5)));
sigmao = thw / (2*sqrt(2*log(2)));

D = sqrt(U.^2+V.^2);
Hf = exp(-(D-f0).^2./(D*sigma^2));

T  = atan2(V,U);
T1 = wrapAnglePi(T - th0);
T2 = wrapAnglePi(T - th0 + pi);
Ho = exp(-T1.^2/(2*sigmao^2)) + exp(-T2.^2/(2*sigmao^2));
Ho(D>1) = 0;

H = Hf .* Ho;

H(U==0 & V==0) = 1;

G = H.*F;
If = real(ifft2(ifftshift(G)));


function theta = wrapAnglePi(theta)

theta = rem(theta,2*pi);
theta(theta>pi) = -2*pi+theta(theta>pi);
theta(theta<-pi) = 2*pi+theta(theta<-pi);
