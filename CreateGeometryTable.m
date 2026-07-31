function GeometryTable = CreateGeometryTable(Run)
%*******************************************************************************
% CREATEGEOMETRYTABLE
%
% Purpose:
%   Creates a MATLAB table containing the geometric characteristics of the
%   archaeological bodies recovered from all inversion runs.
%
% Inputs:
%   Run - Structure containing all inversion results.
%
% Outputs:
%   GeometryTable - MATLAB table with one row per archaeological body.
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%*******************************************************************************

nRuns = numel(Run);

nRows = 2*nRuns;

RunNumber = zeros(nRows,1);
Body = strings(nRows,1);

CenterX = zeros(nRows,1);
CenterY = zeros(nRows,1);
Depth = zeros(nRows,1);

Length = zeros(nRows,1);
Width = zeros(nRows,1);
Height = zeros(nRows,1);

Volume = zeros(nRows,1);

Error = zeros(nRows,1);
Time = zeros(nRows,1);
BestIteration = zeros(nRows,1);

Folder = strings(nRows,1);

row = 1;

for i = 1:nRuns

    %%==========================
    %% Body E
    %%==========================

    B = Run(i).BodyE;

    RunNumber(row) = Run(i).Run;
    Body(row) = "E";

    CenterX(row) = B.X;
    CenterY(row) = B.Y;
    Depth(row) = B.Depth;

    Length(row) = B.Length;
    Width(row) = B.Width;
    Height(row) = B.Height;

    Volume(row) = B.Volume;

    Error(row) = Run(i).Error;
    Time(row) = Run(i).Time;
    BestIteration(row) = Run(i).BestIteration;

    Folder(row) = Run(i).Folder;

    row = row + 1;

    %%==========================
    %% Body F
    %%==========================

    B = Run(i).BodyF;

    RunNumber(row) = Run(i).Run;
    Body(row) = "F";

    CenterX(row) = B.X;
    CenterY(row) = B.Y;
    Depth(row) = B.Depth;

    Length(row) = B.Length;
    Width(row) = B.Width;
    Height(row) = B.Height;

    Volume(row) = B.Volume;

    Error(row) = Run(i).Error;
    Time(row) = Run(i).Time;
    BestIteration(row) = Run(i).BestIteration;

    Folder(row) = Run(i).Folder;

    row = row + 1;

end

GeometryTable = table(...
    RunNumber,...
    Body,...
    CenterX,...
    CenterY,...
    Depth,...
    Length,...
    Width,...
    Height,...
    Volume,...
    Error,...
    Time,...
    BestIteration,...
    Folder);

disp(' ')
disp('Geometry table created successfully.')
disp(GeometryTable)

end