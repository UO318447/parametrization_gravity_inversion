function [misfit,swarm] = fcost_prisma_rectangular_cripta(swarm,data,opciones,opfun)
%*******************************************************************************
% RECTANGULAR PRISM OBJECTIVE FUNCTION (PSO)
%
% Purpose:
%   Evaluates the objective (cost) function for a swarm of 3D rectangular 
%   prism models. It includes a penalty for intersecting bodies using the 
%   Separating Axis Theorem (SAT) and calculates the data misfit based on 
%   the forward gravity response.
%
% Inputs:
%   swarm    - Matrix of PSO particles (each row is a potential 3D model).
%   data     - Structure containing the observed gravity data (data.gobs).
%   opciones - PSO algorithm options.
%   opfun    - Structure containing inversion setup, station coordinates 
%              (ptos), norm type, and number of prisms.
%
% Outputs:
%   misfit   - Array containing the calculated cost/error for each particle.
%   swarm    - Updated swarm matrix (after parameter formatting/reordering).
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

ptos = opfun.ptos;

for i = 1:size(swarm,1)

    modeli = swarm(i,:);
    pris = trata_modelip(modeli,opfun);
    
    % Reordenar vector para el PSO
    B = pris';
    Bf = B(:);
    swarm(i,:) = Bf';
    
    %-----------------------------------------
    % ÁNGULOS → RADIANES
    %-----------------------------------------
    pris(:,7:8) = pris(:,7:8)*pi/180;
    
    %-----------------------------------------
% EXACT OVERLAP TEST FOR ORIENTED PRISMS
% Separating Axis Theorem (SAT)
%-----------------------------------------
invalid = false;

if opfun.npris > 1

    for k = 1:opfun.npris-1

        for j = k+1:opfun.npris

            if PrismasSolapanSAT(pris(k,:),pris(j,:))

                invalid = true;
                break

            end

        end

        if invalid
            break
        end

    end

end
    
    % Penalización fuerte
    if invalid
        misfit(i) = 1e6;
        continue
    end
    
    %-----------------------------------------
    % FORWARD (RECTANGULAR)
    %-----------------------------------------
    gD = GravPrismaRectangular(pris, ptos, 1, 1.0);
    
    % componente Z
    gcal = -gD(:,3) * 1.0e8;
    
    %-----------------------------------------
    % MISFIT
    %-----------------------------------------
    misfit(i) = norm(gcal(:)-data.gobs(:),opfun.norm) / ...
                norm(data.gobs(:),opfun.norm);

end
end