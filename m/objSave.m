function s = objSave(s)

% OBJMODEL
%
% Usage: model = objSave(model)
%
% A function called by the objMake*-functions to compute
% texture coordinates, faces, and so forth; and to write the model
% to a file.
%

% I'd love to start the names of these helper functions with an
% underscore (_) to make it clear they're helper functions not to
% be directly called by the user, but Matlab doesn't allow it
% (Octave allows it.  Use Octave.)

% Copyright (C) 2015,2016 Toni Saarela
% 2015-04-06 - ts - first version, based on the model-type-specific
%                    functions
% 2015-05-04 - ts - uses option comp_uv for uv-coords instead of
%                    checking whether mtl filename is empty
% 2015-05-07 - ts - bettered the writing of vertices etc to file.
%                    it's better now.
% 2015-05-12 - ts - plane width and height are now 2, changed freq conversion
% 2015-05-18 - ts - added new model shape, 'extrusion'
% 2015-05-30 - ts - updated to work with new object structure format
% 2015-06-01 - ts - fixed a comment string to work with matlab (# to %)
% 2015-06-06 - ts - explicitly open file in text mode (for windows)
% 2015-06-10 - ts - changed freq conversion for plane
% 2015-06-10 - ts - added mesh reso to obj comments
% 2015-10-07 - ts - checks for material library and material name
%                    separately; fixed a bug in setting texture
%                    coordinate faces for planes
% 2015-10-10 - ts - added support for worm shape
% 2015-10-12 - ts - computation of faces, uv-coordinates, and normals
%                    separated into their own functions
% 2016-01-28 - ts - reformatted the "created with"-string
% 2016-02-19 - ts - writes perturbation type into comments
% 2016-03-26 - ts - renamed objSave (was objSaveModel)

m = s.m;
n = s.n;

%--------------------------------------------
% Faces, vertex indices
s = objCompFaces(s);

% Texture coordinates if material is defined
if s.flags.comp_uv
  s = objCompUV(s);
end

% Vertex normals
if s.flags.comp_normals
  s = objCompNormals(s);
end

%--------------------------------------------
% Write to file

fid = fopen(s.filename,'wt');
fprintf(fid,'# %s\n',datestr(now,31));
if length(s.prm)==1
   if isfield(s.prm,'mfilename_called') && ~isempty(s.prm.mfilename_called)
     fprintf(fid,'# Created with function %s (calling %s) from ShapeToolbox.\n',s.prm.mfilename,s.prm.mfilename_called);
   else
     fprintf(fid,'# Created with function %s from ShapeToolbox.\n',s.prm.mfilename);
   end
else
  for ii = 1:length(s.prm)
    if ii==1 verb = 'Created'; else verb = 'Modified'; end 
    if isfield(s.prm(ii),'mfilename_called') && ~isempty(s.prm(ii).mfilename_called)
      fprintf(fid,'# %d. %s with function %s (calling %s) from ShapeToolbox.\n',ii,verb,s.prm(ii).mfilename,s.prm(ii).mfilename_called);
    else
      fprintf(fid,'# %d. %s with function %s from ShapeToolbox.\n',ii,verb,s.prm(ii).mfilename);
    end
  end
end
fprintf(fid,'#\n# Base shape: %s.\n',s.shape);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(s.vertices,1));
fprintf(fid,'# Mesh resolution: %dx%d.\n',s.m,s.n);
fprintf(fid,'# Number of faces: %d.\n',size(s.faces,1));

if s.flags.comp_uv
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
end

if s.flags.comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

for ii = 1:length(s.prm)
    if length(s.prm)==1
      if isfield(s.prm,'mfilename_called') && ~isempty(s.prm.mfilename_called)
        fprintf(fid,'#\n# %s\n# %s (->%s) parameters:\n',...
                repmat('-',1,50),s.prm(ii).mfilename,s.prm(ii).mfilename_called);
      else
        fprintf(fid,'#\n# %s\n# %s parameters:\n',repmat('-',1,50),s.prm(ii).mfilename);
      end
    else
      if isfield(s.prm(ii),'mfilename_called') && ~isempty(s.prm(ii).mfilename_called)
        fprintf(fid,'#\n# %s\n# %d. %s (->%s) parameters:\n',...
                repmat('-',1,50),ii,s.prm(ii).mfilename,s.prm(ii).mfilename_called);
      else
        fprintf(fid,'#\n# %s\n# %d. %s parameters:\n',repmat('-',1,50),ii,s.prm(ii).mfilename);
      end
    end
    fprintf(fid,'#\n# Perturbation type: %s\n',s.prm(ii).perturbation);
  switch s.prm(ii).perturbation
    %---------------------------------------------------
    case 'sine'
      if strcmp(s.shape,'plane')
        %- Convert frequencies back to cycles/plane
        s.prm(ii).cprm(:,1) = s.prm(ii).cprm(:,1)/(2*pi);
        if ~isempty(s.prm(ii).mprm)
          s.prm(ii).mprm(:,1) = s.prm(ii).mprm(:,1)/(2*pi);
        end         
      end
      writeSpecs(fid,s.prm(ii).cprm,s.prm(ii).mprm);
    %---------------------------------------------------
    case 'bump'
      writeSpecsBumpy(fid,s.prm(ii).prm);
    %---------------------------------------------------
    case 'noise'
      if strcmp(s.shape,'plane')
        %- Convert frequencies back to cycles/plane
        if ~isempty(s.prm(ii).mprm)
          s.prm(ii).mprm(:,1) = s.prm(ii).mprm(:,1)/(2*pi);
        end
      end
      writeSpecsNoisy(fid,s.prm(ii).nprm,s.prm(ii).mprm);
      if s.prm(ii).use_rms
        fprintf(fid,'# Use RMS contrast: Yes.\n');
      else
        fprintf(fid,'# Use RMS contrast: No.\n');
      end
    %---------------------------------------------------
    case 'custom'
      writeSpecsCustom(fid,s.prm(ii),s.flags.use_map);
    %---------------------------------------------------
 end
end

fprintf(fid,'#\n# Phase and angle (if present) are in radians above.\n');

if ~isempty(s.mtlfilename)
  fprintf(fid,'\n# Materials:\nmtllib %s\nusemtl %s\n',s.mtlfilename,s.mtlname);
elseif ~isempty(s.mtlname)
  fprintf(fid,'\n# Materials:\nusemtl %s\n',s.mtlname);
end

fprintf(fid,'\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',s.vertices');
fprintf(fid,'# End vertices\n');

if s.flags.comp_uv
  fprintf(fid,'\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',s.uvcoords');
  fprintf(fid,'# End texture coordinates\n');
end

if s.flags.comp_normals
  fprintf(fid,'\n# Normals:\n');
  fprintf(fid,'vn %8.6f %8.6f %8.6f\n',s.normals');
  fprintf(fid,'# End normals\n');
end

% Write face defitions to file.  These are written differently
% depending on whether uvcoordinates and/or normals are included.
fprintf(fid,'\n# Faces:\n');
if ~s.flags.comp_uv
  if s.flags.comp_normals
    fprintf(fid,'f %d//%d %d//%d %d//%d\n',...
            [s.faces(:,1) s.faces(:,1) ...
             s.faces(:,2) s.faces(:,2) ...
             s.faces(:,3) s.faces(:,3)]');
  else
    fprintf(fid,'f %d %d %d\n',s.faces');    
  end
else
  if s.flags.comp_normals
    fprintf(fid,'f %d/%d/%d %d/%d/%d %d/%d/%d\n',...
            [s.faces(:,1) s.facestxt(:,1) s.faces(:,1)...
             s.faces(:,2) s.facestxt(:,2) s.faces(:,2)...
             s.faces(:,3) s.facestxt(:,3) s.faces(:,3)]');
  else
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',...
            [s.faces(:,1) s.facestxt(:,1) ...
             s.faces(:,2) s.facestxt(:,2) ...
             s.faces(:,3) s.facestxt(:,3)]');
  end
end
fprintf(fid,'# End faces\n');
fclose(fid);

%--------------------------------------------
% Functions to write the modulation specs; these are called above

function writeSpecs(fid,cprm,mprm)

nccomp = size(cprm,1);
nmcomp = size(mprm,1);

fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
for ii = 1:nccomp
  fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',cprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

function writeSpecsBumpy(fid,prm)

nbumptypes = size(prm,1);

fprintf(fid,'#\n# Gaussian bump parameters (each row is bump type):\n');
fprintf(fid,'#  # of bumps | Amplitude | Sigma\n');
for ii = 1:nbumptypes
  fprintf(fid,'#  %10d   %9.2f   %5.2f\n',prm(ii,:));
end

function writeSpecsNoisy(fid,nprm,mprm)

nncomp = size(nprm,1);
nmcomp = size(mprm,1);

fprintf(fid,'#\n# Noise carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | FWHH | Angle | FWHH | Amplitude | Group\n');
for ii = 1:nncomp
  fprintf(fid,'#  %9.2f   %4.2f   %5.2f   %4.2f   %9.2f       %d\n',nprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

function writeSpecsCustom(fid,prm,use_map)

if use_map
  if isfield(prm,'imgname')
     fprintf(fid,'#\n# Modulation values defined by the (average) intensity\n');
     fprintf(fid,'# of the image %s.\n',prm.imgname);
  else
     fprintf(fid,'#\n# Modulation values defined by a custom matrix.\n');
  end
else    
  fprintf(fid,'#\n#  Modulation defined by a custom user-defined function.\n');
  fprintf(fid,'#  Modulation parameters:\n');
  fprintf(fid,'#  # of locations | Cut-off dist. | Custom function arguments\n');
  for ii = 1:prm.nbumptypes
    fprintf(fid,'#  %14d   %13.2f   ',prm.prm(ii,1:2));
    fprintf(fid,'%5.2f  ',prm.prm(ii,3:end));
    fprintf(fid,'\n');
  end
end
