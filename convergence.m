%*******************************************************************************
% AUTOMATIC CONVERGENCE ANALYSIS
%
% Purpose:
%   Evaluates the convergence plateau of the PSO algorithm by comparing the 
%   relative error improvement between iterations 80 and 100 across different 
%   geometries (P2, P4, and P6). Performs non-parametric statistical testing 
%   (Kruskal-Wallis and post-hoc Dunn-Sidak) to determine if the convergence 
%   behavior differs significantly among parameterizations.
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
close all

files = {'Summary_P2.mat', 'Summary_P4.mat', 'Summary_P6.mat'};
names = {'P2', 'P4', 'P6'};

AllDelta = [];
AllGroups = [];
SummaryTable = table;

for k = 1:length(files)
    
    if ~isfile(files{k})
        fprintf('File %s not found. Skipping...\n', files{k});
        continue;
    end
    
    load(files{k}, 'ErrorIteration')
    nRuns = numel(ErrorIteration);
    DeltaRel = zeros(nRuns, 1);
    E80 = zeros(nRuns, 1);
    E100 = zeros(nRuns, 1);
    
    for i = 1:nRuns
        E = ErrorIteration{i};
        % Note: Assumes at least 100 iterations were run
        E80(i)  = E(80);
        E100(i) = E(100);
        DeltaRel(i) = 100 * (E80(i) - E100(i)) / E80(i);
    end
    
    %% Save individual results
    Results = table((1:nRuns)', E80, E100, DeltaRel, ...
        'VariableNames', {'Run', 'E80', 'E100', 'DeltaRel'});
    writetable(Results, ['Convergence_' names{k} '.xlsx']);
    
    %% Statistics
    SummaryTable = [SummaryTable;
        table( ...
        string(names{k}), ...
        mean(DeltaRel), ...
        median(DeltaRel), ...
        std(DeltaRel), ...
        min(DeltaRel), ...
        max(DeltaRel), ...
        'VariableNames', {'Parameterization', 'Mean', 'Median', 'Std', 'Min', 'Max'})];
        
    %% Data for statistical test
    AllDelta  = [AllDelta; DeltaRel];
    AllGroups = [AllGroups; repmat(names(k), nRuns, 1)];
end

%% Display summary table
disp('===================== CONVERGENCE SUMMARY =====================')
disp(SummaryTable)
if ~isempty(SummaryTable)
    writetable(SummaryTable, 'Convergence_Summary.xlsx');
end

%% Kruskal-Wallis test
if ~isempty(AllDelta)
    [p, tbl, stats] = kruskalwallis(AllDelta, AllGroups, 'off');
    fprintf('\n');
    fprintf('Kruskal-Wallis p-value = %.6g\n', p);
    
    if p < 0.05
        disp('Statistically significant differences found. Running post-hoc Dunn-Sidak...')
        results = multcompare(stats, ...
            'Display', 'off', ...
            'CType', 'dunn-sidak');
        ComparisonTable = array2table(results, ...
            'VariableNames', {'Group1', 'Group2', 'LowerCI', ...
            'Difference', 'UpperCI', 'pValue'});
        disp(ComparisonTable)
        writetable(ComparisonTable, 'PostHoc_DunnSidak.xlsx');
    else
        disp('No statistically significant differences found between groups.')
    end
    
    %% Boxplot
    figure('Name', 'Convergence Analysis', 'Position', [250 250 600 500])
    boxplot(AllDelta, AllGroups)
    ylabel('\DeltaE_{rel} (%)')
    title('Relative improvement during the last 20 iterations')
    grid on
    box on
    exportgraphics(gcf, 'Convergence_Boxplot.png', 'Resolution', 300);
    exportgraphics(gcf, 'Convergence_Boxplot.pdf', 'ContentType', 'vector');
end