function overlap = PrismasSolapanSAT(prism1, prism2)
%*******************************************************************************
% 3D PRISM OVERLAP DETECTION (SAT)
%
% Purpose:
%   Determines whether the interiors of two arbitrarily oriented
%   rectangular prisms overlap using the Separating Axis Theorem (SAT).
%   Boundary contact (face, edge, or vertex contact) is allowed and is
%   therefore not classified as volumetric overlap.
%
% Inputs:
%   prism1  - Array with 9 parameters [xc yc zc a b c azimuth inclination density]
%             where (xc,yc,zc) is the center, (a,b,c) are half-lengths, and 
%             angles are in radians (R = Rz(azimuth) * Ry(inclination)).
%   prism2  - Array with 9 parameters for the second prism (same format).
%
% Outputs:
%   overlap - Boolean flag. Returns 'true' if the prism interiors overlap, 
%             and 'false' if they are separated or only touch.
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%
% This code is licensed under the MIT License. 
% See the LICENSE file in the project root for more information.
%*******************************************************************************


%% ============================================================
%  INPUT CHECK
% =============================================================

if numel(prism1) < 8 || numel(prism2) < 8
    error(['Each prism must contain at least the first 8 parameters: ' ...
           '[xc yc zc a b c azimuth inclination].']);
end


%% ============================================================
%  PRISM PARAMETERS
% =============================================================

% Centers
C1 = prism1(1:3).';
C2 = prism2(1:3).';

% Half-lengths along local prism axes
halfSize1 = prism1(4:6).';
halfSize2 = prism2(4:6).';

% Check geometrical validity
if any(halfSize1 <= 0) || any(halfSize2 <= 0)
    error('Prism half-lengths a, b, and c must be strictly positive.');
end

% Angles are already in radians
az1  = prism1(7);
inc1 = prism1(8);

az2  = prism2(7);
inc2 = prism2(8);


%% ============================================================
%  ROTATION MATRICES
%
%  Same convention as GravPrismaRectangular:
%
%       R = Rz(azimuth) * Ry(inclination)
%
%  The columns of R define the oriented local axes of the prism
%  expressed in global coordinates.
% =============================================================

Rz1 = [ cos(az1)  -sin(az1)   0;
        sin(az1)   cos(az1)   0;
        0          0          1 ];

Ry1 = [ cos(inc1)   0   sin(inc1);
        0           1   0;
       -sin(inc1)   0   cos(inc1) ];

A = Rz1 * Ry1;


Rz2 = [ cos(az2)  -sin(az2)   0;
        sin(az2)   cos(az2)   0;
        0          0          1 ];

Ry2 = [ cos(inc2)   0   sin(inc2);
        0           1   0;
       -sin(inc2)   0   cos(inc2) ];

B = Rz2 * Ry2;


%% ============================================================
%  RELATIVE ORIENTATION
%
%  R(i,j) = projection of local axis j of prism 2
%           onto local axis i of prism 1
% =============================================================

R = A.' * B;


%% ============================================================
%  RELATIVE TRANSLATION
%
%  Vector joining the centers, expressed in the local coordinate
%  system of prism 1.
% =============================================================

tGlobal = C2 - C1;

t = A.' * tGlobal;


%% ============================================================
%  NUMERICAL TOLERANCES
% =============================================================

% Tolerance used only to stabilize nearly parallel-axis calculations.
epsAxis = 1e-12;

AbsR = abs(R) + epsAxis;

% Geometrical tolerance used to distinguish actual volumetric overlap
% from simple boundary contact.
%
% The tolerance scales with the dimensions of the prisms.
geomScale = max([halfSize1; halfSize2; 1]);

tolGeom = 1e-10 * geomScale;


%% ============================================================
%  SEPARATING AXIS THEOREM
%
%  For two oriented rectangular boxes there are 15 candidate
%  separating axes:
%
%    3 local axes of prism 1
%    3 local axes of prism 2
%    9 cross products between their local axes
%
%  If separation or boundary contact is detected along any axis,
%  the interiors do not overlap.
% =============================================================

overlap = false;


%% ------------------------------------------------------------
%  1. Test local axes of prism 1: A1, A2, A3
% -------------------------------------------------------------

for i = 1:3

    ra = halfSize1(i);

    rb = halfSize2(1)*AbsR(i,1) + ...
         halfSize2(2)*AbsR(i,2) + ...
         halfSize2(3)*AbsR(i,3);

    distance = abs(t(i));

    % Separated or only touching
    if distance >= (ra + rb - tolGeom)
        return
    end

end


%% ------------------------------------------------------------
%  2. Test local axes of prism 2: B1, B2, B3
% -------------------------------------------------------------

for j = 1:3

    ra = halfSize1(1)*AbsR(1,j) + ...
         halfSize1(2)*AbsR(2,j) + ...
         halfSize1(3)*AbsR(3,j);

    rb = halfSize2(j);

    distance = abs( ...
        t(1)*R(1,j) + ...
        t(2)*R(2,j) + ...
        t(3)*R(3,j));

    % Separated or only touching
    if distance >= (ra + rb - tolGeom)
        return
    end

end


%% ------------------------------------------------------------
%  3. Test the 9 cross-product axes Ai x Bj
% -------------------------------------------------------------

for i = 1:3

    i1 = mod(i,3) + 1;
    i2 = mod(i+1,3) + 1;

    for j = 1:3

        j1 = mod(j,3) + 1;
        j2 = mod(j+1,3) + 1;

        ra = halfSize1(i1)*AbsR(i2,j) + ...
             halfSize1(i2)*AbsR(i1,j);

        rb = halfSize2(j1)*AbsR(i,j2) + ...
             halfSize2(j2)*AbsR(i,j1);

        distance = abs( ...
            t(i2)*R(i1,j) - ...
            t(i1)*R(i2,j));

        % For nearly parallel axes, Ai x Bj has negligible magnitude
        % and does not define a numerically meaningful separating axis.
        axisNormSq = 1 - R(i,j)^2;

        if axisNormSq > epsAxis

            % Separated or only touching
            if distance >= (ra + rb - tolGeom)
                return
            end

        end

    end

end


%% ============================================================
%  NO SEPARATING AXIS FOUND
%
%  The interiors of the two oriented prisms overlap.
% =============================================================

overlap = true;

end