function s = objCompNormals(s)

% OBJCOMPNORMALS
%
% Usage:    MODEL = objCompNormals(MODEL)

% Copyright (C) 2015 Toni Saarela
% 2015-10-02 - ts - first version, from objSaveModel
% 2015-10-12 - ts - updated, returns the whole model structure


%------------------------------------------------------------

m = s.m;
n = s.n;

if ~isfield(s,'faces')
  fprintf('Faces not defined, computing faces first.\n');
  s = objCompFaces(s);
  fprintf('Done.\n');
end

%------------------------------------------------------------

% Surface normals for the faces
fn = cross([s.vertices(s.faces(:,2),:)-s.vertices(s.faces(:,1),:)],...
           [s.vertices(s.faces(:,3),:)-s.vertices(s.faces(:,1),:)]);

% Vertex normals
s.normals = zeros(m*n,3);

% Loop through vertices, slow
% for ii = 1:m*n
%  idx = any(faces==ii,2);
%  vn = sum(fn(idx,:),1);
%  normals(ii,:) = vn / sqrt(vn*vn');
% end

% Loop through faces, somewhat faster but still slow
switch s.shape
  case {'sphere','cylinder','revolution','extrusion','worm'}
    nfaces = (m-1)*n*2;
  case 'plane'
    nfaces = (m-1)*(n-1)*2;
  case 'torus'
    nfaces = m*n*2;
end
for ii = 1:nfaces
  s.normals(s.faces(ii,:),:) = s.normals(s.faces(ii,:),:) + [1 1 1]'*fn(ii,:);
end
s.normals = s.normals./sqrt(sum(s.normals.^2,2)*[1 1 1]);

%normals = s.normals;
