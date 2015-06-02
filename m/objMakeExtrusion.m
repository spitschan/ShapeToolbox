function solid = objMakeExtrusion(curve,cprm,varargin)

% OBJMAKEEXTRUSION
%
% Usage: solid = objMakeExtrusion(curve,[options])

% Copyright (C) 2015 Toni Saarela
% 2015-05-18 - ts - first version
% 2015-06-01 - ts - calls objMakeSine

%------------------------------------------------------------

if nargin<2
  cprm = [];
end
solid = objMakeSine('extrusion',cprm,varargin{:},'curve',curve);

if ~nargout
  clear solid
end
