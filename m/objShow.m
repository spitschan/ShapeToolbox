function h = objShow(obj)

% OBJSHOW
% 
% Usage: h = objShow(obj)
%

% Toni Saarela, 2014
% 2014-07-28 - ts - first version

X = reshape(obj.vertices(:,1),[obj.npointsy obj.npointsx]);
Y = reshape(obj.vertices(:,2),[obj.npointsy obj.npointsx]);
Z = reshape(obj.vertices(:,3),[obj.npointsy obj.npointsx]);

figure
h = surf(X,Y,Z);
set(gca,'Visible','Off');
colormap gray
