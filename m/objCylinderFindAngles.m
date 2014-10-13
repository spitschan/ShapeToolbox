function a = objCylinderFindAngles(f)

% OBJCYLINDERFINDANGLES
% 
% Usage: a = objCylinderFindAngles(f)
% 
% Given frequency f (in cycles per full circle), find the grating
% angles a that produce a smooth "corkscrew" pattern around the
% cylinder with no discontinuities.
%
% See also: objMakeCylinder, objCylinderFindFreqs

% Toni Saarela, 2014
% 2014-10-10 - ts - first version

n = 0:f;
a = 180*acos(n./f)/pi;
