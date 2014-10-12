function plane = objMakePlaneNoise(nprm,varargin)

%

% Toni Saarela, 2013
% 2013-10-15 - ts - first, rudimentary version
% 2014-10-09 - ts - improved speed, included filtering function,
%                   added input arguments/options
% 2014-10-11 - ts - improved filtering function, added orientation filtering
% 2014-10-11 - ts - now possible to use the modulators to modulate
%                    between two (or more) carriers
%                   can have different sizes in x and y directions
%                    (not tested properly yet)
% 2014-10-12 - ts - fixed a bug affecting the case when there are
%                   carriers AND modulators only in group 0

%--------------------------------------------

% TODO
% Define rms contrast instead of amplitude, add as optional input argument
% Add an option for unequal size in x and y -- see objMakePlane
% Take input in degrees, convert to radians
% If orientation full width is zero, that means no orientation
% filtering.  Or wait, should it be Inf?

if ~nargin || isempty(nprm)
  nprm = [8 1 0 45 .1 0];
end

[nncomp,ncol] = size(nprm);

if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

f = nprm(:,1);
fw = nprm(:,2);
th = nprm(:,3);
thw = nprm(:,4);
a = nprm(:,5);
group = nprm(:,6);

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
filename = 'planenoisy.obj';
use_rms = false;

% Number of vertices in y and x directions, default values
m = 256;
n = 256;

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
      mprm = [mprm ones(nccomp,1)*[.1 0 0 0]];
    case 2
      mprm = [mprm zeros(nccomp,3)];
    case 3
      mprm = [mprm zeros(nccomp,2)];
    case 4
      mprm = [mprm zeros(nccomp,1)];
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
         case 'rms'
           use_rms = true;
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

w = 1; % width of the plane
h = m/n * w;

x = linspace(-w/2,w/2,n); % 
y = linspace(-h/2,h/2,m)'; % 

%f = f/(2*r);

%--------------------------------------------

if a<0
  error('Modulation amplitude has to be positive.');
end

%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);
Y = flipud(Y);

if ~isempty(mprm)

   % Find the component groups
   ngroups = unique(nprm(:,6));
   mgroups = unique(mprm(:,5));
   
   % Groups other than zero (zero is a special group handled
   % separately below)
   ngroups2 = setdiff(ngroups,0);
   mgroups2 = setdiff(mgroups,0);

   if ~isempty(ngroups2)
     Z = zeros([m n length(ngroups2)]);
     for gi = 1:length(ngroups2)
       % Find the carrier components that belong to this group
       cidx = find(nprm(:,6)==ngroups2(gi));
       % Make the (compound) carrier

       C = zeros(m,n);
       for ii = 1:length(cidx)
         I = normrnd(0,1,[m n]);
         I = imgFilterBand(I,f(cidx(ii)),fw(cidx(ii)),th(cidx(ii)),thw(cidx(ii)));%,0,pi/2);
         if use_rms
           C = C + a(cidx(ii)) * I / sqrt(I(:)'*I(:)/(m*n));
         else
           C = C + a(cidx(ii)) * I / max(abs(I(:)));
         end
       end % loop over noise carrier components

       % If there's a modulator in this group, make it
       midx = find(mprm(:,5)==ngroups2(gi));
       if ~isempty(midx)          
         M = zeros(m,n);
         for ii = 1:length(midx)
           M = M + mprm(midx(ii),2) * sin(2*pi*mprm(midx(ii),1)*(X*cos(mprm(midx(ii),4))-Y*sin(mprm(midx(ii),4)))+mprm(midx(ii),3));
         end % loop over modulator components
         M = .5 * (1 + M);
         if any(M(:)<0) || any(M(:)>1)
           if nmcomp>1
             warning('The amplitude of the compound modulator is out of bounds (0-1).\n Expect wonky results.');
           else
             warning('The amplitude of the modulator is out of bounds (0-1).\n Expect wonky results.');
           end
         end % if modulator out of range
         % Multiply modulator and carrier
         Z(:,:,gi) = M .* C;
       else % Otherwise, the carrier is all
         Z(:,:,gi) = C;
       end % is modulator defined
     end % loop over carrier groups      
     Z = sum(Z,3);
   else
     Z = zeros([m n]);
   end % if there are noise carriers in groups other than zero

   % Handle the component group 0:
   % Carriers in group zero are always added to the other (modulated)
   % components without any modulator of their own
   % Modulators in group zero modulate ALL the other components.  That
   % is, if there are carriers/modulators in groups other than zero,
   % they are made and added together first (above).  Then, carriers
   % in group zero are added to those.  Finally, modulators in group
   % zero modulate that whole bunch.
   cidx = find(nprm(:,6)==0);
   if ~isempty(cidx)
     % Make the (compound) carrier
     C = zeros(m,n);
     for ii = 1:length(cidx)
       I = normrnd(0,1,[m n]);
       I = imgFilterBand(I,f(cidx(ii)),fw(cidx(ii)),th(cidx(ii)),thw(cidx(ii)));%,0,pi/2);
       if use_rms
         C = C + a(cidx(ii)) * I / sqrt(I(:)'*I(:)/(m*n));
       else
         C = C + a(cidx(ii)) * I / max(abs(I(:)));
       end
     end % loop over noise carrier components
     Z = Z + C;
   end

   midx = find(mprm(:,5)==0);
   if ~isempty(midx)
     M = zeros(m,n);
     for ii = 1:length(midx)
       M = M + mprm(midx(ii),2) * sin(2*pi*mprm(midx(ii),1)*(X*cos(mprm(midx(ii),4))-Y*sin(mprm(midx(ii),4)))+mprm(midx(ii),3));
     end % loop over modulator components
     M = .5 * (1 + M);
     if any(M(:)<0) || any(M(:)>1)
       if nmcomp>1
         warning('The amplitude of the compound modulator is out of bounds (0-1).\n Expect wonky results.');
       else
         warning('The amplitude of the modulator is out of bounds (0-1).\n Expect wonky results.');
       end
     end % if modulator out of range
     % Multiply modulator and carrier
     Z = M .* Z;
   end

else % there are no modulators
  % Only make the carriers here, add them up and you're done
  C = zeros(m,n);
  for ii = 1:nncomp
    I = normrnd(0,1,[m n]);
    I = imgFilterBand(I,f(ii),fw(ii),th(ii),thw(ii));%,0,pi/2);
    if use_rms
      C = C + a(ii) * I / sqrt(I(:)'*I(:)/(m*n));
    else
      C = C + a(ii) * I / max(abs(I(:)));
    end
  end % loop over noise carrier components
  Z = C;
end % if modulators defined

%--------------------------------------
% Z = zeros([m n nccomp]);
% I = zeros([m n]);
% for ii = 1:nccomp
%   I = normrnd(0,1,[m n]);
%   I = imgFilterBand(I,f(ii),fw(ii),th(ii),thw(ii));%,0,pi/2);
%   if use_rms
%     I = a(ii) * I / sqrt(I(:)'*I(:)/(m*n));
%   else
%     I = a(ii) * I / max(abs(I(:)));
%   end
%   Z(:,:,ii) = I;
% end
% Z = sum(Z,3);
%--------------------------------------


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
