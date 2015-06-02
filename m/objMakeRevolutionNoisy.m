function solid = objMakeRevolutionNoisy(curve,nprm,varargin)

% OBJMAKEREVOLUTIONNOISY
%
% Usage: solid = objMakeRevolutionNoisy(curve,nprm,[OPTIONS])
%
% Note: if modifying an existing model, the first input argument (the
% curve) is ignored.  Just leave it empty.


% Copyright (C) 2015 Toni Saarela
% 2015-04-05 - ts - first version
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters
% 2015-06-01 - ts - calls objMakeNoise

%------------------------------------------------------------

if nargin<2
  nprm = [];
end
solid = objMakeNoise('revolution',nprm,varargin{:},'curve',curve);

if ~nargout
  clear solid
end
