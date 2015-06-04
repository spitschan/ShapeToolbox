function Z = objMakeNoiseComponents(nprm,mprm,X,Y,use_rms)

% OBJMAKENOISECOMPONENTS
%
% Z = objMakeNoiseComponents(nprm,mprm,X,Y,use_rms)
%
% A function called by a bunch of other functions in the toolbox.

% Toni Saarela, 2014
% 2014-10-15 - ts - first version written
% 2014-10-16 - ts - uses randn instead of normrnd (Octave users should
%                    be fine with either, but normrnd in Matlab might
%                    be in a toolbox not everyone has.  Plus randn is
%                    slightly faster, maybe normrnd calls it.  Not sure
%                    why I'm writing about this so extensively here).
% 2014-10-28 - ts - uses a separate function for computing the
%                    modulators, copied from _objMakeSineComponents
% 2014-11-10 - ts - renamed (removed leading underscore that's not
%                    allowed by Matlab)
% 2015-04-03 - ts - changed sign of noise filter orientation to make
%                    consistent with the sign convention of sine wave
%                    components --- positive is clock-wise
% 2015-05-31 - ts - minor change in noise filtering
% 2015-06-03 - ts - envelopes that share a group index are multiplied,
%                    not added



f = nprm(:,1);
fw = nprm(:,2);
th = -nprm(:,3);
thw = nprm(:,4);
a = nprm(:,5);
group = nprm(:,6);

nncomp = size(nprm,1);

[m,n] = size(X);

if ~isempty(mprm)

  nmcomp = size(mprm,1);

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
         %I = normrnd(0,1,[m n]);
         I = randn([m n]);
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
         % M = zeros(m,n);
         M = ones(m,n);
         for ii = 1:length(midx)
           %M = M + mprm(midx(ii),2) * sin(2*pi*mprm(midx(ii),1)*(X*cos(mprm(midx(ii),4))-Y*sin(mprm(midx(ii),4)))+mprm(midx(ii),3));
           % M = M + makeComp(mprm(midx(ii),:),X,Y);
           M = M .* .5 .* (1 + makeComp(mprm(midx(ii),:),X,Y));
         end % loop over modulator components
         % M = .5 * (1 + M);
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
       %I = normrnd(0,1,[m n]);
       I = randn([m n]);
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
     % M = zeros(m,n);
     M = ones(m,n);
     for ii = 1:length(midx)
       % M = M + makeComp(mprm(midx(ii),:),X,Y);
       M = M .* .5 .* (1 + makeComp(mprm(midx(ii),:),X,Y));
       %M = M + mprm(midx(ii),2) * sin(2*pi*mprm(midx(ii),1)*(X*cos(mprm(midx(ii),4))-Y*sin(mprm(midx(ii),4)))+mprm(midx(ii),3));
     end % loop over modulator components
     % M = .5 * (1 + M);
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
    %I = normrnd(0,1,[m n]);
    I = randn([m n]);
    I = imgFilterBand(I,f(ii),fw(ii),th(ii),thw(ii));%,0,pi/2);
    if use_rms
      C = C + a(ii) * I / sqrt(I(:)'*I(:)/(m*n));
    else
      C = C + a(ii) * I / max(abs(I(:)));
    end
  end % loop over noise carrier components
  Z = C;
end % if modulators defined


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

u = [-n:2:n-2]/n;
v = [-m:2:m-2]/m;
[U,V] = meshgrid(u,v);
fnyquist = n / 2;
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


function C = makeComp(prm,X,Y)

%C = prm(2) * sin(prm(1)*(X*cos(prm(4))-2*Y*sin(prm(4)))+prm(3));
C = prm(2) * sin(prm(1)*(X*cos(prm(4))-Y*sin(prm(4)))+prm(3));
