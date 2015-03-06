function Z = objMakeSineComponents(cprm,mprm,X,Y)

% OBJMAKESINECOMPONENTS
%
% Z = objMakeSineComponents(cprm,mprm,X,Y)
%
% A function called by a bunch of other functions in the toolbox.

% Toni Saarela, 2014
% 2014-10-15 - ts - first version written
% 2014-11-10 - ts - renamed (removed leading underscore that's not
%                    allowed by Matlab)

[m,n] = size(X);

nccomp = size(cprm,1);

if ~isempty(mprm)

  nmcomp = size(mprm,1);

   % Find the component groups
   cgroups = unique(cprm(:,5));
   mgroups = unique(mprm(:,5));
   
   % Groups other than zero (zero is a special group handled
   % separately below)
   cgroups2 = setdiff(cgroups,0);
   mgroups2 = setdiff(mgroups,0);
   
   if ~isempty(cgroups2)
     Z = zeros([m n length(cgroups2)]);
     for gi = 1:length(cgroups2)
       % Find the carrier components that belong to this group
       cidx = find(cprm(:,5)==cgroups2(gi));
       % Make the (compound) carrier
       C = zeros(m,n);
       for ii = 1:length(cidx)
         C = C + makeComp(cprm(cidx(ii),:),X,Y);
       end % loop over carrier components
       % If there's a modulator in this group, make it
       midx = find(mprm(:,5)==cgroups2(gi));
       if ~isempty(midx)          
         M = zeros(m,n);
         for ii = 1:length(midx)
           M = M + makeComp(mprm(midx(ii),:),X,Y);
         end % loop over modulator components
         M = .5 * (1 + M);
         if any(M(:)<0) || any(M(:)>1)
           if nmcomp>1
             warning('The amplitude of the compound modulator is out of bounds (0-1).\n Expect wonky results.');
           else
             warning('The amplitude of the modulator is out of bounds (0-1).\n Expect wonky results.');
           end
         end % if modulator out of range
         % Multiply modulator and carrier
         Z(:,:,gi) = M .* C;
       else % Otherwise, the carrier is all
         Z(:,:,gi) = C;
       end % is modulator defined
     end % loop over carrier groups
     Z = sum(Z,3);
   else
     Z = zeros([m n]);;
   end % if there are carriers in groups other than zero

   

   % Handle the component group 0:
   % Carriers in group zero are always added to the other (modulated)
   % components without any modulator of their own
   % Modulators in group zero modulate ALL the other components.  That
   % is, if there are carriers/modulators in groups other than zero,
   % they are made and added together first (above).  Then, carriers
   % in group zero are added to those.  Finally, modulators in group
   % zero modulate that whole bunch.
   cidx = find(cprm(:,5)==0);
   if ~isempty(cidx)
     % Make the (compound) carrier
     C = zeros(m,n);
     for ii = 1:length(cidx)
       C = C + makeComp(cprm(cidx(ii),:),X,Y);
     end % loop over carrier components
     Z = Z + C;
   end

   midx = find(mprm(:,5)==0);
   if ~isempty(midx)          
     M = zeros(m,n);
     for ii = 1:length(midx)
       M = M + makeComp(mprm(midx(ii),:),X,Y);
     end % loop over modulator components
     M = .5 * (1 + M);
     if any(M(:)<0) || any(M(:)>1)
       if nmcomp>1
         warning('The amplitude of the compound modulator is out of bounds (0-1).\n Expect wonky results.');
       else
         warning('The amplitude of the modulator is out of bounds (0-1).\n Expect wonky results.');
       end
     end % if modulator out of range
     
     % Multiply modulator and carrier
     Z = M .* Z;
   end

else % there are no modulators
  % Only make the carriers here, add them up and you're done
  C = zeros(m,n);
  for ii = 1:nccomp
    C = C + makeComp(cprm(ii,:),X,Y);
  end % loop over carrier components
  Z = C;
end % if modulators defined



function C = makeComp(prm,X,Y)

%C = prm(2) * sin(prm(1)*(X*cos(prm(4))-2*Y*sin(prm(4)))+prm(3));
C = prm(2) * sin(prm(1)*(X*cos(prm(4))-Y*sin(prm(4)))+prm(3));
