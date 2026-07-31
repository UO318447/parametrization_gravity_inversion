function GeometryStatistics = ComputeGeometryStatistics(GeometryTable)
%*******************************************************************************
% COMPUTEGEOMETRYSTATISTICS
%
% Purpose:
%   Computes descriptive statistics of the archaeological bodies obtained
%   from all inversion runs.
%
% Inputs:
%   GeometryTable - Table created by CreateGeometryTable.
%
% Outputs:
%   GeometryStatistics - Table containing descriptive statistics.
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%*******************************************************************************

Bodies = {'E','F'};

Parameters = {...
    'CenterX',...
    'CenterY',...
    'Depth',...
    'Length',...
    'Width',...
    'Height',...
    'Volume'};

BodyColumn      = strings(0,1);
ParameterColumn = strings(0,1);

MeanColumn   = [];
MedianColumn = [];
StdColumn    = [];
CVColumn     = [];
IQRColumn    = [];
MinColumn    = [];
MaxColumn    = [];

for ibody = 1:numel(Bodies)

    idx = GeometryTable.Body == Bodies{ibody};

    for ip = 1:numel(Parameters)

        values = GeometryTable{idx,Parameters{ip}};

        BodyColumn(end+1,1)      = Bodies{ibody};
        ParameterColumn(end+1,1) = Parameters{ip};

        MeanColumn(end+1,1)   = mean(values);
        MedianColumn(end+1,1) = median(values);
        StdColumn(end+1,1)    = std(values);
        CVColumn(end+1,1)     = 100*StdColumn(end)/abs(MeanColumn(end));
        IQRColumn(end+1,1)    = iqr(values);
        MinColumn(end+1,1)    = min(values);
        MaxColumn(end+1,1)    = max(values);

    end

end

GeometryStatistics = table(...
    BodyColumn,...
    ParameterColumn,...
    MeanColumn,...
    MedianColumn,...
    StdColumn,...
    CVColumn,...
    IQRColumn,...
    MinColumn,...
    MaxColumn,...
    'VariableNames',{...
    'Body',...
    'Parameter',...
    'Mean',...
    'Median',...
    'Std',...
    'CV',...
    'IQR',...
    'Minimum',...
    'Maximum'});

disp(' ')
disp('Geometry statistics successfully computed.')

end