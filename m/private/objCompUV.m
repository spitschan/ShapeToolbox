function s = objCompUV(s)

% OBJCOMPUV
%
% Usage:    MODEL = objCompUV(MODEL)

% Copyright (C) 2015 Toni Saarela
% 2015-10-12 - ts - first version, separated from objSaveModel


%------------------------------------------------------------

m = s.m;
n = s.n;


switch s.shape
  case {'sphere','cylinder','revolution','extrusion','worm'}
    u = linspace(0,1,n+1);
    v = linspace(0,1,m);
    [U,V] = meshgrid(u,v);
    U = U'; V = V';
    s.uvcoords = [U(:) V(:)];

    % Faces, uv coordinate indices
    s.facestxt = zeros((m-1)*n*2,3);
    n2 = n + 1;
    F = ([1 1]'*[1:n]);
    F = F(:) * [1 1 1];
    F(:,2) = reshape([1 1]'*[2:n2]+[1 0]'*n2*ones(1,n),[2*n 1]);
    F(:,3) = n2 + [1; reshape([1 1]'*[2:n],[2*(n-1) 1]); n2];
    for ii = 1:m-1
      s.facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n2 + F;
    end
  case 'plane'
    U = (s.X-min(s.X))/(max(s.X)-min(s.X));
    V = (s.Y-min(s.Y))/(max(s.Y)-min(s.Y));
    s.uvcoords = [U V];

    s.facestxt = s.faces;

  case 'torus'
    u = linspace(0,1,n+1);
    v = linspace(0,1,m+1);
    [U,V] = meshgrid(u,v);
    U = U'; V = V';
    s.uvcoords = [U(:) V(:)];

    s.facestxt = zeros(m*n*2,3);
    F1 = [1 1]' * [1:n];
    F1 = F1(:);
    F2 = [(n+3):2*(n+1);2:(n+1)];
    F2 = F2(:);
    F3 = [1 1]' * [(n+2):2*(n+1)];
    F3 = F3(:);
    F3 = F3(2:end-1);
    F = [F1 F2 F3];
    for ii = 1:m
      s.facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*(n+1) + F;
    end
end
clear u v U V

