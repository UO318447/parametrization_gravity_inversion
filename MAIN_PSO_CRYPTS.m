%*******************************************************************************
% REAL-DATA 3D GRAVITY INVERSION USING RR-GPSO
%
% Purpose:
%   Performs 3D gravity inversion of real gravity data using RR-GPSO.
%   *Customized for TRNAVA dataset and RECTANGULAR PRISMS.*
%
% Authors:
%   GPINV Research Group
%   University of Oviedo, Spain
%
% Copyright (c) 2026 GPINV Research Group, University of Oviedo
%
% DATASET ACKNOWLEDGMENT / ATTRIBUTION:
%   The real microgravity dataset ('02_Trnava_micrograv.grd') was provided 
%   and processed by Prof. Roman Pašteka (Comenius University in Bratislava).
%   All rights regarding the raw dataset belong to the original author/provider.
%
% This code is licensed under the MIT License.
% See the LICENSE file in the project root for more information.
%==========================================================================
clear
clc
close all

nRuns = 30;
summary = table('Size',[nRuns 7], ...
    'VariableTypes',{'double','double','double','double','double','double','string'}, ...
    'VariableNames',{'Run','Error','Symmetry','Semivariogram','Time','Bodies','Folder'});

for irun = 1:nRuns
    %% 1. CONFIGURATION
    %----------------------------------------------------------------------
    % Display & Analysis options
    %----------------------------------------------------------------------
    show_parameters   = true;
    save_figures      = true;
    compute_variogram = true;
    compute_symmetry  = true;
    
    %% 2. PSO SETTINGS
    algo_type = 5;
    options.pso.maxiter = 100; % ¡OJO! Subir a 100 para la inversión final
    options.pso.size    = 300; % ¡OJO! Subir a 300 para la inversión final
    options.pso.elitism = 0;
    fprintf('Swarm size : %d\n', options.pso.size);
    fprintf('Iterations : %d\n', options.pso.maxiter);
    
    %% 3. DATA LOADING
    % Read microgravity grid
    [F, columnsn, rowsm, minx, maxx, miny, maxy, minf, maxf] = ...
        readSRF_ASCIIgrid('02_Trnava_micrograv.grd');
    
    x_vec = linspace(minx, maxx, columnsn);
    y_vec = linspace(miny, maxy, rowsm);
    [X, Y] = meshgrid(x_vec, y_vec);
    
    % Observation coordinates
    x = X(:);
    y = Y(:);
    z = zeros(size(x));
    
    % Convert gravity from mGal to µGal
    gobs = F(:) * 1000;
    
    %% 4. SEARCH SPACE
    number_of_bodies = 6;
    [model.lowlimit, model.upperlimit] = SearchSpaceCrypts(number_of_bodies);
    
    % Automatically add the third semi-axis for rectangular prisms
    nc = length(model.lowlimit)/8;
    L_mat = reshape(model.lowlimit,[8 nc]);
    U_mat = reshape(model.upperlimit,[8 nc]);
    L_new = [L_mat(1:5,:); L_mat(5,:); L_mat(6:8,:)];
    U_new = [U_mat(1:5,:); U_mat(5,:); U_mat(6:8,:)];
    model.lowlimit  = L_new(:)';
    model.upperlimit = U_new(:)';
    disp('>>> Search space automatically adapted for rectangular prisms.')
    
    % Observation data
    ptos = [x y z];
    data.gobs = gobs;
    opfun.ptos = ptos;
    opfun.x = x;
    opfun.y = y;
    opfun.z = z;
    
    %% 5. INVERSION SETUP
    opfun.nstation = length(data.gobs);
    opfun.nparam   = 9;
    
    ncuerpos = length(model.lowlimit)/opfun.nparam;
    if ncuerpos ~= number_of_bodies
        error('The search space is inconsistent with the selected number of bodies.');
    end
    
    fprintf('Final swarm size : %d\n', options.pso.size);
    fprintf('Final iterations : %d\n', options.pso.maxiter);
    disp(['>>> ',num2str(ncuerpos),' rectangular prisms'])
    
    funobj = @fcost_prisma_rectangular_cripta;
    opfun.npris = ncuerpos;
    
    PSO_options;
    
    opfun.norm = 1;
    opfun.modellog = 0;
    opfun.prior.model = [];
    opfun.prior.niter = 2;
    
    results_config.dataset   = 'Trnava';
    results_config.geometry  = 'Rectangular Prisms';
    results_config.nBodies   = ncuerpos;
    results_config.swarmSize = options.pso.size;
    results_config.maxIter   = options.pso.maxiter;
    
    %% 6. PSO OPTIMIZATION
    disp('>>> Running PSO optimization...')
    tic
    results = pso_grav3D(funobj, model, data, options, opfun);
    Duracion = toc;
    
    %% Best model
    [~, jmodel] = min(results.error_hist);
    if opfun.modellog
        results.historia = 10.^results.historia;
    end
    
    cuerpo_invertido = results.historia(jmodel,:);
    if ncuerpos > 1
        cuerpo_invertido = reshape(cuerpo_invertido,[opfun.nparam,ncuerpos])';
    end
    
    cuerpo_invertido(:,7:8) = cuerpo_invertido(:,7:8)*pi/180;
    
    %% Forward modelling
    [gpre_temp,~,~,ediscinv] = GravPrismaRectangular(cuerpo_invertido,ptos,1,1.0);
    
    % Convert from m/s² to µGal
    gpre = -gpre_temp(:,3)*1.0e8;
    error_final = 100*min(results.error_hist);
    results.gpre          = gpre;
    results.model         = cuerpo_invertido;
    results.residual      = data.gobs - gpre;
    results.finalError    = error_final;
    results.time          = Duracion;
    results.bestIteration = jmodel;
    
    %% Output file name
    str_error = sprintf('Err%.2f',error_final);
    str_error = strrep(str_error,'.','p');
    str_time = sprintf('T%.1fs',Duracion);
    str_time = strrep(str_time,'.','p');
    
    nombre_archivo = sprintf('P%d_Trnava_Run%02d_%s_%s', ncuerpos, irun, str_error, str_time);
    disp(['>>> Results will be saved as: ',nombre_archivo,'.mat']);
    
    %% 7. POSTERIOR ANALYSIS
    disp('>>> Running posterior analysis...')
    Etol = 0.20;
    good_models = posterior(opfun, options, results, Etol);
    results.good_models = good_models;
    
    %% 8. VISUALIZATION
    disp('>>> Generating figures...')
    
    %% Recovered 3D model
    figure('Name','Recovered 3D model','Position',[100 100 800 600])
    hold on
    for ibody = 1:length(ediscinv)
        if isempty(ediscinv{ibody}) || size(ediscinv{ibody},2) ~= 3
            continue
        end
        Cinv = convhull(ediscinv{ibody}(:,1), ediscinv{ibody}(:,2), ediscinv{ibody}(:,3));
        trisurf(Cinv, ediscinv{ibody}(:,1), ediscinv{ibody}(:,2), ediscinv{ibody}(:,3),...
            'FaceColor','r','FaceAlpha',0.8,'EdgeColor','k');
    end
    scatter3(x,y,z,15,'k','filled')
    title('Recovered 3D model')
    xlabel('Local X coordinate (m)')
    ylabel('Local Y coordinate (m)')
    zlabel('Depth (m)')
    grid on
    view(3)
    axis equal
    zlim([-5 0])
    ax = gca;
    ax.Position = [0.05 0.10 0.62 0.80];
    
    %% Model parameters
    if show_parameters
        texto_datos = {'MODEL PARAMETERS', '----------------------------'};
        for ibody = 1:ncuerpos
            texto_datos{end+1} = sprintf('Body %d',ibody);
            texto_datos{end+1} = sprintf('Center [X,Y]: [%.2f, %.2f] m', cuerpo_invertido(ibody,1), cuerpo_invertido(ibody,2));
            texto_datos{end+1} = sprintf('Center depth : %.2f m', cuerpo_invertido(ibody,3));
            texto_datos{end+1} = sprintf('Top depth    : %.2f m', cuerpo_invertido(ibody,3)+cuerpo_invertido(ibody,6));
            texto_datos{end+1} = sprintf('Half-width X : %.2f m', cuerpo_invertido(ibody,4));
            texto_datos{end+1} = sprintf('Half-width Y : %.2f m', cuerpo_invertido(ibody,5));
            texto_datos{end+1} = sprintf('Half-width Z : %.2f m', cuerpo_invertido(ibody,6));
            texto_datos{end+1} = sprintf('Azimuth      : %.1f°', cuerpo_invertido(ibody,7)*180/pi);
            texto_datos{end+1} = sprintf('Dip          : %.1f°', cuerpo_invertido(ibody,8)*180/pi);
            texto_datos{end+1} = sprintf('Density      : %.0f kg/m^3', cuerpo_invertido(ibody,9));
            texto_datos{end+1} = '';
        end
        annotation('textbox', [0.68 0.10 0.30 0.80], 'String',texto_datos,...
            'EdgeColor','k', 'BackgroundColor','w', 'FitBoxToText','on',...
            'FontName','Courier', 'FontSize',9);
    end
    hold off
    
    %% Gravity anomaly maps
    num_pts = 100;
    [X_grid,Y_grid] = meshgrid(linspace(minx,maxx,num_pts), linspace(miny,maxy,num_pts));
    G_obs_grid = griddata(x,y,data.gobs,X_grid,Y_grid,'natural');
    G_pre_grid = griddata(x,y,gpre,X_grid,Y_grid,'natural');
    results.Gobs_grid = G_obs_grid;
    results.Gpre_grid = G_pre_grid;
    
    figure('Name','Gravity anomaly maps','Position',[150 150 1000 400])
    subplot(1,2,1)
    pcolor(X_grid,Y_grid,G_obs_grid)
    shading interp
    title('Observed anomaly (\muGal)')
    xlabel('X (m)')
    ylabel('Y (m)')
    colorbar
    colormap(parula)
    axis equal tight
    
    subplot(1,2,2)
    pcolor(X_grid,Y_grid,G_pre_grid)
    shading interp
    title('Predicted anomaly (\muGal)')
    xlabel('X (m)')
    ylabel('Y (m)')
    colorbar
    colormap(parula)
    axis equal tight
    
    vmin = min(data.gobs);
    vmax = max(data.gobs);
    subplot(1,2,1)
    clim([vmin vmax])
    subplot(1,2,2)
    clim([vmin vmax])
    
    %% 9. SYMMETRY ANALYSIS
    disp('>>> Computing symmetry index...')
    G_obs_temp = G_obs_grid;
    G_obs_temp(isnan(G_obs_temp)) = 0;
    G_pre_temp = G_pre_grid;
    G_pre_temp(isnan(G_pre_temp)) = 0;
    
    G_obs_mirror = fliplr(G_obs_temp);
    G_pre_mirror = fliplr(G_pre_temp);
    
    norm_diff_obs = norm(G_obs_temp(:) - G_obs_mirror(:));
    norm_diff_pre = norm(G_pre_temp(:) - G_pre_mirror(:));
    norm_obs = norm(G_obs_temp(:));
    norm_pre = norm(G_pre_temp(:));
    S_obs = norm_diff_obs / norm_obs;
    S_pre = norm_diff_pre / norm_pre;
    
    results.symmetry.Sobs = S_obs;
    results.symmetry.Spre = S_pre;
    results.symmetry.Gobs = G_obs_temp;
    results.symmetry.Gpre = G_pre_temp;
    results.symmetry.obsDifference = G_obs_temp - G_obs_mirror;
    results.symmetry.preDifference = G_pre_temp - G_pre_mirror;
    
    disp('-------------------------------------------')
    disp('Symmetry analysis')
    disp('-------------------------------------------')
    fprintf('Observed symmetry index : %.4f\n',S_obs);
    fprintf('Predicted symmetry index: %.4f\n',S_pre);
    fprintf('Absolute difference     : %.4f\n',abs(S_obs-S_pre));
    disp('-------------------------------------------')
    disp('Lower values indicate higher symmetry.')
    
    %% Symmetry difference maps
    figure('Name','Mirror symmetry difference maps','Position',[200 200 900 400])
    subplot(1,2,1)
    imagesc(results.symmetry.obsDifference)
    axis equal tight
    colorbar
    colormap(turbo)
    title('Observed symmetry residual')
    subplot(1,2,2)
    imagesc(results.symmetry.preDifference)
    axis equal tight
    colorbar
    colormap(turbo)
    title('Predicted symmetry residual')
    
    
    %% 11. SAVE RESULTS
    disp('>>> Saving results...')
    nombre_carpeta = nombre_archivo;
    if ~exist(nombre_carpeta,'dir')
        mkdir(nombre_carpeta);
    end
    
    %% Save workspace
    ruta_mat = fullfile(nombre_carpeta,[nombre_archivo,'.mat']);
    save(ruta_mat,'results','results_config','good_models');
    fprintf('Results saved: %s\n',ruta_mat);
    
    %% Save figures
    if save_figures
        figuras = findall(0,'Type','figure');
        for ifig = 1:length(figuras)
            fig = figuras(ifig);
            if ~isgraphics(fig,'figure')
                continue
            end
            try
                nombre_figura = fig.Name;
                if isempty(nombre_figura)
                    nombre_figura = sprintf('Figure_%d',fig.Number);
                end
                nombre_figura = strrep(nombre_figura,' ','_');
                nombre_figura = regexprep(nombre_figura,'[/\\*:?"<>|]','');
                
                savefig(fig, fullfile(nombre_carpeta,[nombre_figura,'.fig']));
                exportgraphics(fig, fullfile(nombre_carpeta,[nombre_figura,'.png']), 'Resolution',300);
                exportgraphics(fig, fullfile(nombre_carpeta,[nombre_figura,'.pdf']), 'ContentType','vector');
                fprintf('Saved: %s\n',nombre_figura);
            catch ME
                fprintf(2, 'Warning: Could not export figure %d.\n', ifig);
                fprintf(2, 'Reason: %s\n', ME.message);
                continue
            end
        end
    end
    
    %% ============================================================
    % UPDATE SUMMARY FOR CURRENT RUN
    % =============================================================
    summary.Run(irun)           = irun;
    summary.Error(irun)         = results.finalError;
    summary.Symmetry(irun)      = abs(results.symmetry.Sobs-results.symmetry.Spre);
    summary.Time(irun)          = results.time;
    summary.Bodies(irun)        = ncuerpos;
    summary.Folder(irun)        = string(nombre_carpeta);
    fprintf('\nRun %d added to summary.\n',irun);
    close all

end  % <<< for irun = 1:nRuns

%% ============================================================
% FINAL SUMMARY
% =============================================================
summary = sortrows(summary,'Error');
disp(' ')
disp('================== FINAL SUMMARY ==================')
disp(summary)