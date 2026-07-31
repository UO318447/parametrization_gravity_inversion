%*******************************************************************************
% ARCHAEOLOGICALINTERPRETATIONP4
%
% Purpose:
%   Post-processes the P4 rectangular-prism inversion results to obtain the
%   geometric characteristics of the archaeological bodies interpreted from
%   the recovered models.
%
%   The program:
%
%     - Loads the 30 independent RR-GPSO inversion results.
%     - Groups prisms 1–2 into Body E (upper crypt).
%     - Groups prisms 3–4 into Body F (lower crypt).
%     - Computes the bounding-box geometry of each body.
%     - Stores the inversion information.
%     - Creates a geometry table.
%     - Computes descriptive statistics.
%
% Inputs:
%   Folder containing the inversion results.
%
% Outputs:
%   Run                 Structure containing all inversion results.
%   GeometryTable       Table with the geometric parameters.
%   GeometryStatistics  Descriptive statistics.
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%*******************************************************************************

clear
clc
close all

%% Locate inversion folders

folders = dir('P4_Trnava_Run*');
folders = folders([folders.isdir]);

nRuns = numel(folders);

fprintf('Found %d inversion runs.\n\n',nRuns);

%% Read all inversion results

Run = struct([]);

for irun = 1:nRuns

    folderName = folders(irun).name;

    fprintf('Run %02d/%02d : %s\n',irun,nRuns,folderName);

    matFile = dir(fullfile(folderName,'*.mat'));

    if isempty(matFile)

        warning('No MAT file found in %s.',folderName);
        continue

    end

    load(fullfile(folderName,matFile(1).name));

    %% General information

    Run(irun).Run = irun;

    Run(irun).Folder = folderName;

    Run(irun).Error = results.finalError;

    Run(irun).Time = results.time;

    Run(irun).BestIteration = results.bestIteration;

    %% Archaeological interpretation

    Run(irun).BodyE = ComputeBodyGeometry(results.model,[1 2]);

    Run(irun).BodyF = ComputeBodyGeometry(results.model,[3 4]);

end

fprintf('\nFinished reading inversion results.\n');

%% Create geometry table

GeometryTable = CreateGeometryTable(Run);

%% Compute descriptive statistics

GeometryStatistics = ComputeGeometryStatistics(GeometryTable);

%% Display statistics

disp(' ')
disp(GeometryStatistics)

%% Export results

ExportGeometryTables(GeometryTable,GeometryStatistics);

ExportGeometryLatex(GeometryStatistics);

fprintf('\nAnalysis completed successfully.\n');