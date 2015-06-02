function solid = objMakeRevolutionBumpy(curve,prm,varargin)

% OBJMAKEREVOLUTIONBUMPY
%

% Copyright (C) 2015 Toni Saarela
% 2015-05-14 - ts - first version
% 2015-06-01 - ts - calls objMakeBump

%------------------------------------------------------------

if nargin<2
  prm = [];
end
solid = objMakeBump('revolution',prm,varargin{:},'curve',curve);

if ~nargout
  clear solid
end
