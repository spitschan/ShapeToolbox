function solid = objMakeRevolutionCustom(curve,f,prm,varargin)

% OBJMAKEREVOLUTIONCUSTOM
%

% Copyright (C) 2015 Toni Saarela
% 2015-05-15 - ts - first version
% 2015-05-29 - ts - fixed a bug in normalization of image/matrix values
% 2015-06-01 - ts - calls objMakeCustom

%------------------------------------------------------------

solid = objMakeCustom('revolution',f,prm,varargin{:},'curve',curve);

if ~nargout
  clear solid
end
