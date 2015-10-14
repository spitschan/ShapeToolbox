function model = objMakeWorm(model)

% OBJMAKEWORM
%

% Copyright (C) 2015 Toni Saarela
% 2015-10-10 - ts - first version

% Reshape in to matrices.  Y coordinate grows by row.
Theta = reshape(model.Theta,[model.n model.m])';
R = reshape(model.R,[model.n model.m])';

% Convert to xyz coordinates
X =  R .* cos(Theta);
Z = -R .* sin(Theta);
Y = zeros(size(X));

up = [0 1 0]';
% Loop through the rows, that is, through each y-coordinate
for ii = 1:model.m
  % Get the direction of the "spine" at this point
  d = model.spine.D(ii,:)';
  if norm(up-d)>.0001 % an arbitrary threshold
    [v,alpha] = rotDir(d);
    M = rotMat(v,alpha);
    tmp = M * [X(ii,:); Y(ii,:); Z(ii,:)];
    X(ii,:) = tmp(1,:);% .* R(ii,:);
    Y(ii,:) = tmp(2,:);% .* R(ii,:);
    Z(ii,:) = tmp(3,:);% .* R(ii,:);
  end
end
X = X';  model.X = X(:);
Y = Y';  model.Y = Y(:);
Z = Z';  model.Z = Z(:);
model.vertices = [model.X model.Y model.Z] + ...
                 [model.spine.X model.spine.Y model.spine.Z];



function [v,alpha] = rotDir(d)

d = d/norm(d);
dproj = [d(1) 0 d(3)];
v = [-d(3) 0 d(1)];
v = v / norm(v);
alpha = pi/2-acos(norm(dproj));



function M = rotMat(v,alpha)

theta = atan2(v(1),v(3));
phi = atan2(v(2),sqrt(v(1)^2+v(3)^2));

Ry1 = [ cos(-theta) 0 -sin(-theta)
       0          1 0
      sin(-theta) 0 cos(-theta)];

Rx1 = [1 0         0
      0 cos(phi) sin(phi)
      0 -sin(phi)  cos(phi)];

Rz = [cos(alpha) sin(alpha) 0
      -sin(alpha)  cos(alpha) 0
      0           0          1];

Rx2 = [1 0         0
      0 cos(-phi) sin(-phi)
      0 -sin(-phi)  cos(-phi)];

Ry2 = [ cos(theta) 0 -sin(theta)
       0          1 0
      sin(theta) 0 cos(theta)];

M = Ry1 * Rx1 * Rz * Rx2 * Ry2;
