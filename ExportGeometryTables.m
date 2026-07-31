function ExportGeometryTables(GeometryTable,GeometryStatistics)
%*******************************************************************************
% EXPORTGEOMETRYTABLES
%
% Purpose:
%   Exports the archaeological geometry tables to Excel and CSV files.
%
% Inputs:
%   GeometryTable
%   GeometryStatistics
%
% Outputs:
%   GeometryTable.xlsx
%   GeometryStatistics.xlsx
%   GeometryTable.csv
%   GeometryStatistics.csv
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%*******************************************************************************

fprintf('\n');
fprintf('Exporting results...\n');

%% Export geometry table

writetable(GeometryTable,'GeometryTable.xlsx');
writetable(GeometryTable,'GeometryTable.csv');

%% Export statistics table

writetable(GeometryStatistics,'GeometryStatistics.xlsx');
writetable(GeometryStatistics,'GeometryStatistics.csv');

fprintf('GeometryTable.xlsx exported.\n');
fprintf('GeometryStatistics.xlsx exported.\n');

fprintf('GeometryTable.csv exported.\n');
fprintf('GeometryStatistics.csv exported.\n');

fprintf('Export completed successfully.\n');

end