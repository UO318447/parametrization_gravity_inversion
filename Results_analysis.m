%*******************************************************************************
% RESULTS ANALYSIS
%
% Purpose:
%   Analyzes the results from multiple PSO inversion runs across different 
%   geometric parameterizations (e.g., 2, 4, or 6 bodies). Extracts statistics, 
%   generates convergence and error distribution plots, and updates a global 
%   model complexity comparison table.
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

% =========================================================================
% GEOMETRY CONFIGURATION
% =========================================================================
% Modify this list to choose which geometries to process. 
% Examples:
% To process all: geometriesToRun = {'P2', 'P4', 'P6'};
% To process only P4: geometriesToRun = {'P4'};
geometriesToRun = {'P2', 'P4', 'P6'}; 

disp('=========================================')
disp(' RESULTS ANALYSIS')
disp('=========================================')

figureFolder = fullfile(pwd,'Figures');
if ~exist(figureFolder,'dir')
    mkdir(figureFolder);
end

%% MAIN LOOP OVER GEOMETRIES
for gIdx = 1:length(geometriesToRun)
    geometry = geometriesToRun{gIdx};
    
    fprintf('\n==========================================================\n');
    fprintf(' STARTING ANALYSIS FOR GEOMETRY: %s\n', geometry);
    fprintf('==========================================================\n');
    
    fprintf('Searching result folders...\n');
    folders = dir([geometry '*']);
    nRuns = length(folders);
    
    if nRuns == 0
        warning('No result folders found for %s. Skipping to next...', geometry);
        continue % Skip to next geometry if no folders exist
    end
    fprintf('%d result folders found.\n\n', nRuns);
    
    %% Summary table (Semivariogram removed, size adjusted to 6)
    summary = table('Size',[nRuns 6],...
        'VariableTypes',{'double','double','double','double','double','string'},...
        'VariableNames',{'Run','Error','Symmetry','Time','Bodies','Folder'});
    
    %% Storage
    Models               = cell(nRuns,1);
    Residuals            = cell(nRuns,1);
    ErrorIteration       = cell(nRuns,1);
    GoodModels           = cell(nRuns,1);
    ResultsConfig        = cell(nRuns,1);
    
    %% Load results
    for irun = 1:nRuns
        file = dir(fullfile(folders(irun).name,'*.mat'));
        if isempty(file)
            warning('No MAT file found in %s',folders(irun).name);
            continue
        end
        load(fullfile(file(1).folder,file(1).name), ...
            'results','results_config','good_models');
        
        summary.Run(irun)           = irun;
        summary.Error(irun)         = results.finalError;
        summary.Symmetry(irun)      = abs(results.symmetry.Sobs-results.symmetry.Spre);
        summary.Time(irun)          = results.time;
        summary.Bodies(irun)        = results_config.nBodies;
        summary.Folder(irun)        = string(folders(irun).name);
        
        Models{irun}               = results.model;
        Residuals{irun}            = results.residual;
        ErrorIteration{irun}       = results.error_iter;
        GoodModels{irun}           = good_models;
        ResultsConfig{irun}        = results_config;
    end
    
    %% Filter out empty runs
    validRuns = summary.Run > 0;
    summary = summary(validRuns, :);
    Models = Models(validRuns);
    Residuals = Residuals(validRuns);
    ErrorIteration = ErrorIteration(validRuns);
    GoodModels = GoodModels(validRuns);
    ResultsConfig = ResultsConfig(validRuns);
    nRuns = height(summary);
    
    %% Sort by error
    [summary, sortIdx] = sortrows(summary, "Error");
    
    Models               = Models(sortIdx);
    Residuals            = Residuals(sortIdx);
    ErrorIteration       = ErrorIteration(sortIdx);
    GoodModels           = GoodModels(sortIdx);
    ResultsConfig        = ResultsConfig(sortIdx);
    
    disp(summary(1:min(3, nRuns),:))
    
    %% Save files with Dynamic Naming
    matFilename = sprintf('Summary_%s.mat', geometry);
    save(matFilename,...
        'summary','Models','Residuals','ErrorIteration',...
        'GoodModels','ResultsConfig')
    
    disp(' ')
    disp('===================== SUMMARY =====================')
    disp(summary)
    fprintf('\nExperiment summary (%s)\n', geometry)
    fprintf('------------------\n')
    fprintf('Runs analysed     : %d\n',nRuns)
    fprintf('Model bodies      : %d\n',summary.Bodies(1))
    
    xlsFilename = sprintf('Summary_%s.xlsx', geometry);
    writetable(summary, xlsFilename);
    fprintf('\nSummary saved as %s\n', xlsFilename);
    
    %% Descriptive statistics
    Q1_Error   = prctile(summary.Error,25);
    Q3_Error   = prctile(summary.Error,75);
    IQR_Error  = iqr(summary.Error);
    CV_Error   = 100*std(summary.Error)/mean(summary.Error);
    
    Q1_Time    = prctile(summary.Time,25);
    Q3_Time    = prctile(summary.Time,75);
    CV_Time    = 100*std(summary.Time)/mean(summary.Time);
    IQR_Time   = iqr(summary.Time);
    
    fprintf('\n================= ERROR STATISTICS (%s) =================\n', geometry)
    fprintf('Mean    : %.2f %%\n',mean(summary.Error))
    fprintf('Median  : %.2f %%\n',median(summary.Error))
    fprintf('Std     : %.2f %%\n',std(summary.Error))
    fprintf('Minimum : %.2f %%\n',min(summary.Error))
    fprintf('Maximum : %.2f %%\n',max(summary.Error))
    
    %% Histogram
    f1 = figure;
    histogram(summary.Error, 'FaceColor',[0.2 0.5 0.8])
    xlabel('Relative error (%)')
    ylabel('Frequency')
    title(['Distribution of inversion error - ' geometry])
    grid on; grid minor;
    exportgraphics(f1, fullfile(figureFolder, sprintf('ErrorHistogram_%s.png', geometry)), 'Resolution',300)
    exportgraphics(f1, fullfile(figureFolder, sprintf('ErrorHistogram_%s.pdf', geometry)), 'ContentType','vector');
    
    %% Boxplot
    f2 = figure;
    boxchart(summary.Error)
    ylabel('Relative error (%)')
    title(['Error distribution - ' geometry])
    grid on; grid minor;
    exportgraphics(f2, fullfile(figureFolder, sprintf('ErrorBoxplot_%s.png', geometry)), 'Resolution',300)
    exportgraphics(f2, fullfile(figureFolder, sprintf('ErrorBoxplot_%s.pdf', geometry)), 'ContentType','vector')
    
    %% Correlation analysis
    [rhoSym,pSym] = corr(summary.Error, summary.Symmetry, 'Type','Spearman');
    [rhoTime,pTime] = corr(summary.Error, summary.Time, 'Type','Spearman');
    
    f3 = figure;
    [xsort,idx] = sort(summary.Symmetry);
    ysort = summary.Error(idx);
    plot(xsort,ysort, '-o', 'Color',[0 0.45 0.74], 'LineWidth',1.5, 'MarkerSize',5, 'MarkerFaceColor',[0 0.45 0.74]);
    xlabel('Symmetry difference')
    ylabel('Relative error (%)')
    title(['Error vs symmetry - ' geometry])
    grid on; grid minor; box on
    text(0.05,0.93, sprintf('\\rho = %.3f\np = %.4f',rhoSym,pSym), 'Units','normalized',...
        'FontSize',11, 'FontWeight','bold', 'BackgroundColor','white', 'Margin',6, 'EdgeColor',[0.7 0.7 0.7])
    exportgraphics(f3, fullfile(figureFolder, sprintf('Error_vs_Symmetry_%s.png', geometry)), 'Resolution',300)
    
    %% Convergence history
    f_conv = figure;
    hold on
    M = vertcat(ErrorIteration{:});
    M = M(:,6:end);
    numItersGuardadas = size(M, 2);
    iter = 6:(5 + numItersGuardadas); 
    
    for i = 1:size(M,1)
        plot(iter,M(i,:), 'Color',[0.82 0.82 0.82], 'LineWidth',0.8)
    end
    plot(iter,mean(M,1), 'k', 'LineWidth',3)
    xlabel('Iteration')
    ylabel('Relative error (%)')
    title(['PSO convergence history - ' geometry])
    xlim([5 (5 + numItersGuardadas)])
    grid on; box on;
    exportgraphics(f_conv, fullfile(figureFolder, sprintf('PSO_Convergence_History_%s.png', geometry)), 'Resolution',300)
    
    %% Representative Curves
    [~,idxBest]  = min(summary.Error);
    [~,idxWorst] = max(summary.Error);
    [~,ord] = sort(summary.Error);
    idxMedian = ord(ceil(nRuns/2));
    
    f_rep = figure;
    hold on
    hAll = gobjects(nRuns,1);
    for i = 1:nRuns
        hAll(i) = plot(iter,M(i,:), 'Color',[0.85 0.85 0.85], 'LineWidth',0.6);
    end
    hBest = plot(iter,M(idxBest,:), 'b','LineWidth',2.5);
    hMedian = plot(iter,M(idxMedian,:), 'Color',[0.90 0.50 0], 'LineWidth',2.5);
    hWorst = plot(iter,M(idxWorst,:), 'r','LineWidth',2.5);
    xlabel('Iteration')
    ylabel('Relative error (%)')
    title(['Representative PSO convergence curves - ' geometry])
    grid on; box on;
    legend([hAll(1) hBest hMedian hWorst], {'All runs','Best','Median','Worst'}, 'Location','northeast');
    
    %% Update Complexity Comparison Table
    comparisonFile = fullfile(pwd, 'Trnava_Model_Complexity_Comparison.xlsx');
    newRow = table( ...
        summary.Bodies(1), 9*summary.Bodies(1), mean(summary.Error), median(summary.Error), ...
        std(summary.Error), min(summary.Error), max(summary.Error), iqr(summary.Error), ...
        100*std(summary.Error)/mean(summary.Error), mean(summary.Time), median(summary.Time), ...
        std(summary.Time), mean(summary.Symmetry), median(summary.Symmetry), ...
        'VariableNames', {'Bodies', 'Parameters', 'MeanError', 'MedianError', 'StdError', ...
        'MinError', 'MaxError', 'IQRError', 'CVError', 'MeanTime', 'MedianTime', 'StdTime', ...
        'MeanSymmetry', 'MedianSymmetry'});
    
    if isfile(comparisonFile)
        oldTable = readtable(comparisonFile);
        
        % Remove old semivariogram columns if they exist in an old Excel file
        if ismember('MeanSemivariogram', oldTable.Properties.VariableNames)
            oldTable.MeanSemivariogram = [];
            oldTable.MedianSemivariogram = [];
        end
        
        oldTable(oldTable.Bodies == summary.Bodies(1),:) = []; % Remove previous duplicate
        comparisonTable = [oldTable; newRow];
    else
        comparisonTable = newRow;
    end
    comparisonTable = sortrows(comparisonTable,'Bodies');
    writetable(comparisonTable,comparisonFile);
    
end % END OF GEOMETRY LOOP

%% =========================================================
% FINAL COMPARATIVE BOXPLOT
% ==========================================================
fprintf('\nGenerating global comparative boxplot...\n');
ErrorGlobal = [];
GroupGlobal = {};

if isfile('Summary_P2.xlsx')
    tP2 = readtable('Summary_P2.xlsx');
    ErrorGlobal = [ErrorGlobal; tP2.Error];
    GroupGlobal = [GroupGlobal; repmat({'P2'}, height(tP2), 1)];
end
if isfile('Summary_P4.xlsx')
    tP4 = readtable('Summary_P4.xlsx');
    ErrorGlobal = [ErrorGlobal; tP4.Error];
    GroupGlobal = [GroupGlobal; repmat({'P4'}, height(tP4), 1)];
end
if isfile('Summary_P6.xlsx')
    tP6 = readtable('Summary_P6.xlsx');
    ErrorGlobal = [ErrorGlobal; tP6.Error];
    GroupGlobal = [GroupGlobal; repmat({'P6'}, height(tP6), 1)];
end

if ~isempty(ErrorGlobal)
    f_comp = figure('Position',[200 200 700 600]);
    boxplot(ErrorGlobal, GroupGlobal)
    xlabel('Parameterization')
    ylabel('Relative data misfit (%)')
    title('Distribution of inversion error (Comparison)')
    grid on
    box on
    exportgraphics(f_comp, fullfile(figureFolder, 'Error_Boxplot_Comparison.png'), 'Resolution',300);
    exportgraphics(f_comp, fullfile(figureFolder, 'Error_Boxplot_Comparison.pdf'), 'ContentType','vector');
    disp('Comparative boxplot successfully saved.');
else
    disp('Not enough summary files (Summary_Px.xlsx) to create the global comparison.');
end

disp('=========================================')
disp(' ANALYSIS COMPLETED')
disp('=========================================')