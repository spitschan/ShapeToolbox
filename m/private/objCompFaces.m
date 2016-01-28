function s = objCompFaces(s)

% OBJCOMPFACES
%
% Usage:    MODEL = objCompNormals(SHAPE)

% Copyright (C) 2015 Toni Saarela
% 2015-10-12 - ts - first version, separated from objSaveModel


%------------------------------------------------------------

m = s.m;
n = s.n;


switch s.shape
  case {'sphere','cylinder','revolution','extrusion','worm'}
    s.faces = zeros((m-1)*n*2,3);
    F = ([1 1]'*[1:n]);
    F = F(:) * [1 1 1];
    F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
    F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
    for ii = 1:m-1
      s.faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
    end
  case {'plane','disk'}
    s.faces = zeros((m-1)*(n-1)*2,3);
    ftmp = [[1 1]'*[1:n-1]];
    F(:,1) = ftmp(:);
    % OR:
    %F(:,1) = ceil([1:(2*n-2)]'/2);
    ftmp = [n+2:2*n; 2:n];
    F(:,2) = ftmp(:);
    ftmp = [[1 1]' * [n+1:2*n]];
    ftmp = ftmp(:);
    F(:,3) = ftmp(2:end-1);    
    for ii = 1:m-1
      s.faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
    end
  case 'torus'
    s.faces = zeros(m*n*2,3);
    % The first part is the same as with the sphere:
    F = ([1 1]'*[1:n]);
    F = F(:) * [1 1 1];
    F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
    F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
    % But loop until m, not m-1 as phi goes -pi to pi here (not -pi/2 to
    % pi/2) and faces wrap around the "tube".
    for ii = 1:m
      s.faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
    end
    % Finally, to wrap around properly in the phi-direction:
    s.faces = 1 + mod(s.faces-1,m*n);
end
