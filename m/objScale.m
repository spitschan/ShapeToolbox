function m = objScale(m,scale)

  
  switch m.shape
    case 'sphere'
      m.R = scale * m.R;
      m = objMakeVertices(m);
    otherwise
      m.X = scale * m.X;
      m.Y = scale * m.Y;
      m.Z = scale * m.Z;
      m.vertices = scale * m.vertices;
  end
  
  
end
