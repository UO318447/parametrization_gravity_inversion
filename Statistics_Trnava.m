%*******************************************************************************
% STATISTICAL ANALYSIS OF INVERSION RESULTS
%
% Purpose:
%   Performs non-parametric statistical analysis (Kruskal-Wallis test and 
%   post-hoc Dunn-Sidak comparisons) on the inversion results (Error, 
%   Symmetry, etc.) across different geometric parameterizations (P2, P4, P6).
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
clear
clc

%% =========================================================
% LOAD SUMMARY TABLES
% ==========================================================
% Check if files exist before attempting to load them
filesToLoad = {'Summary_P2.xlsx', 'Summary_P4.xlsx', 'Summary_P6.xlsx'};
for i = 1:length(filesToLoad)
    if ~isfile(filesToLoad{i})
        error('File %s not found. Please run the results analysis script first.', filesToLoad{i});
    end
end

P2 = readtable('Summary_P2.xlsx');
P4 = readtable('Summary_P4.xlsx');
P6 = readtable('Summary_P6.xlsx');

%% =========================================================
% VARIABLES TO ANALYZE
% ==========================================================
variables = {'Error', 'Semivariogram', 'Symmetry'};

for ivar = 1:length(variables)
    varName = variables{ivar};
    
    % Safety check: Only analyze the variable if it exists in the tables
    if ~ismember(varName, P2.Properties.VariableNames)
        fprintf('\nSkipping %s (Variable not found in summary tables).\n', upper(varName));
        continue;
    end
    
    x2 = P2.(varName);
    x4 = P4.(varName);
    x6 = P6.(varName);
    
    data = [x2; x4; x6];
    groups = [ ...
        repmat({'P2'}, length(x2), 1);
        repmat({'P4'}, length(x4), 1);
        repmat({'P6'}, length(x6), 1)];
        
    fprintf('\n');
    fprintf('=============================================\n');
    fprintf(' VARIABLE: %s\n', upper(varName));
    fprintf('=============================================\n');
    
    %% Kruskal-Wallis test
    [p, tbl, stats] = kruskalwallis(data, groups, 'off');
    fprintf('Kruskal-Wallis p-value = %.6g\n', p);
    
    %% Post-hoc pairwise comparisons
    if p < 0.05
        fprintf('\nPost-hoc multiple comparisons (Dunn-Sidak):\n');
        results = multcompare(stats, ...
            'CType', 'dunn-sidak', ...
            'Display', 'off');
            
        ComparisonTable = array2table(results, ...
            'VariableNames', ...
            {'Group1', 'Group2', 'LowerCI', ...
             'Difference', 'UpperCI', 'pValue'});
        disp(ComparisonTable);
        
        % Save the post-hoc results to an Excel file
        writetable(ComparisonTable, sprintf('PostHoc_%s.xlsx', varName));
    else
        fprintf('No significant overall differences detected.\n');
    end
end