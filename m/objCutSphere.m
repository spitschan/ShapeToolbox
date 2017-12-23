function model = objCutSphere(model,n)

  x = 1:model.n;
  y = (1:model.m)';
  [X,Y] = meshgrid(x,y);

  idx  = Y < (model.m - n + 1);
  
  idx = idx';
  idx = idx(:);
  


  model.Theta = model.Theta(idx);
  model.Phi = model.Phi(idx);
  model.R = model.R(idx);
  
  model.m = model.m - n;
  
  model = objMakeVertices(model);
  
end
