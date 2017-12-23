function model = objAddThickness(model,w)
  

  switch model.shape
    case 'sphere'
      Theta = reshape(model.Theta,[model.n model.m])';
      Phi = reshape(model.Phi,[model.n model.m])';
      R = reshape(model.R,[model.n model.m])';
      
      Theta = [Theta; flipud(Theta)];
      Phi = [Phi; flipud(Phi)];
      R = [R; flipud(R)-w];
      
      Theta = Theta'; Phi = Phi'; R = R';
      model.Theta = Theta(:);
      model.Phi = Phi(:);
      model.R = R(:);
      
      model.m = 2*model.m;
      
    case 'plane'

      X = reshape(model.X,[model.n model.m])';
      Y = reshape(model.Y,[model.n model.m])';
      Z = reshape(model.Z,[model.n model.m])';
      
      X = [X; flipud(X)];
      Y = [Y; flipud(Y)];
      Z = [Z; flipud(Z)-w];
      
      X = X'; Y = Y'; Z = Z';
      model.X = X(:);
      model.Y = Y(:);
      model.Z = Z(:);
      
      model.m = 2*model.m;
      m = model.m;
      
    case {'cylinder','revolution','extrusion'}
      Theta = reshape(model.Theta,[model.n model.m])';
      Y = reshape(model.Y,[model.n model.m])';
      R = reshape(model.R,[model.n model.m])';
      
      Theta = [Theta; flipud(Theta)];
      Y = [Y; flipud(Y)];
      R = [R; flipud(R)-w];
      
      Theta = Theta'; Y = Y'; R = R';
      model.Theta = Theta(:);
      model.Y = Y(:);
      model.R = R(:);

      % Spine
      X = reshape(model.spine.X,[model.n model.m])';
      Y = reshape(model.spine.Y,[model.n model.m])';
      Z = reshape(model.spine.Z,[model.n model.m])';
      
      X = [X; flipud(X)];
      Y = [Y; flipud(Y)];
      Z = [Z; flipud(Z)];
      
      X = X'; Y = Y'; Z = Z';
      model.spine.X = X(:);
      model.spine.Y = Y(:);
      model.spine.Z = Z(:);
      
      
      model.m = 2*model.m;
      m = model.m;      
  end

  model = objMakeVertices(model);
  
end
