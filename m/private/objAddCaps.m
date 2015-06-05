function model = objAddCaps(model)

% OBJADDCAPS
%
% model = objAddCaps(model)
%

% Copyright (C) 2015 Toni Saarela
% 2015-06-05 - ts - first version

Theta = reshape(model.Theta,[model.n model.m])';
Y = reshape(model.Y,[model.n model.m])';
R = reshape(model.R,[model.n model.m])';

Theta = [Theta(1,:); Theta; Theta(end,:)];
Y = [Y(1,:); Y; Y(end,:)];
R = [zeros(1,model.n); R; zeros(1,model.n)];

Theta = Theta'; model.Theta = Theta(:);
Y = Y'; model.Y = Y(:);
R = R'; model.R = R(:);

model.X =  model.R .* cos(model.Theta);
model.Z = -model.R .* sin(model.Theta);

model.vertices = [model.X model.Y model.Z];
model.m = model.m + 2;
