function Body = ComputeBodyGeometry(model,prisms)
%*******************************************************************************
% COMPUTEBODYGEOMETRY
%
% Purpose:
%   Computes the bounding-box geometry of an archaeological body represented
%   by one or more rectangular prisms.
%
% Inputs:
%   model   - results.model
%   prisms  - Indices of the prisms defining the body.
%
% Outputs:
%   Body    - Structure containing the bounding-box geometry.
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%*******************************************************************************

xmin =  inf;
xmax = -inf;

ymin =  inf;
ymax = -inf;

zmin =  inf;
zmax = -inf;

for k = prisms

    X = model(k,1);
    Y = model(k,2);
    Z = model(k,3);

    a = model(k,4);
    b = model(k,5);
    c = model(k,6);

    xmin = min(xmin,X-a);
    xmax = max(xmax,X+a);

    ymin = min(ymin,Y-b);
    ymax = max(ymax,Y+b);

    zmin = min(zmin,Z-c);
    zmax = max(zmax,Z+c);

end

Body.X = (xmin+xmax)/2;
Body.Y = (ymin+ymax)/2;
Body.Depth = (zmin+zmax)/2;

Body.Length = xmax-xmin;
Body.Width  = ymax-ymin;
Body.Height = zmax-zmin;

Body.Volume = Body.Length*Body.Width*Body.Height;

Body.xmin = xmin;
Body.xmax = xmax;

Body.ymin = ymin;
Body.ymax = ymax;

Body.zmin = zmin;
Body.zmax = zmax;

end