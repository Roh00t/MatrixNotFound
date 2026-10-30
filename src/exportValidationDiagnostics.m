function summary = exportValidationDiagnostics(actual, predicted, outputDir, options)
%EXPORTVALIDATIONDIAGNOSTICS UI-independent metrics, chart data, and PNG plots.
% Pass held-out/OOF predictions, NEVER fitted training predictions. The validation
% label is supplied explicitly so scores from different workflows stay distinct.
arguments
    actual (:,1) double
    predicted (:,1) double
    outputDir (1,1) string
    options.Model (1,1) string = "Bag"
    options.Validation (1,1) string = "Five-fold OOF"
    options.MakePlots (1,1) logical = true
end
metrics = computeExtendedMetrics(actual,predicted);
if ~isfolder(outputDir), mkdir(outputDir); end
writetable(metrics,fullfile(outputDir,'metrics.csv'));
residual = predicted-actual;
% Deterministic evenly spaced DISPLAY sample. Every metric uses ALL rows.
displayRows = unique(round(linspace(1,numel(actual),min(2000,numel(actual)))))';
points = table(displayRows,actual(displayRows),predicted(displayRows), ...
    residual(displayRows),'VariableNames',{'SourceRow','Actual','Predicted','Residual'});
writetable(points,fullfile(outputDir,'plot_points.csv'));
summary = struct('SchemaVersion',1,'Model',options.Model, ...
    'Validation',options.Validation,'N',numel(actual), ...
    'Metrics',table2struct(metrics),'MetricRows','All validation rows', ...
    'ResidualConvention','Predicted minus actual', ...
    'DisplaySampleRows',numel(displayRows),'DisplaySampleMethod','Evenly spaced original row indices', ...
    'R2Definition','1-SSE/SST; null when actual target is constant', ...
    'MeasuredTestAccuracy',false);
summary.Points = table2struct(points);
jsonPath = fullfile(outputDir,'validation_summary.json');
fid = fopen(jsonPath,'w','n','UTF-8');
assert(fid~=-1,'BuildingEnergy:DiagnosticsWrite','Cannot write %s.',jsonPath);
closer = onCleanup(@() fclose(fid));
fprintf(fid,'%s',jsonencode(summary));
clear closer;
if ~options.MakePlots, return; end

% Retain all points in the full-range view, including extreme consumers.
fig = figure('Visible','off','Color','white','Position',[100 100 1200 560]);
closer = onCleanup(@() close(fig));
tiledlayout(fig,1,2,'Padding','compact');
ax = nexttile;
scatter(ax,actual,predicted,7,'filled','MarkerFaceAlpha',0.12);
hold(ax,'on');
limits = [min([actual;predicted;0]),max([actual;predicted;1])];
plot(ax,limits,limits,'k--','LineWidth',1.3);
xlim(ax,limits); ylim(ax,limits); axis(ax,'square'); grid(ax,'on');
xlabel(ax,'Actual site_eui','Interpreter','none');
ylabel(ax,'Predicted site_eui','Interpreter','none');
title(ax,'All validation rows; dashed line = perfect prediction');
ax = nexttile;
% Central view is explicitly labeled and counts points outside its bounds.
cap = max(1,prctile([actual;predicted],99.5));
inside = actual>=0 & predicted>=0 & actual<=cap & predicted<=cap;
scatter(ax,actual(inside),predicted(inside),7,'filled','MarkerFaceAlpha',0.12);
hold(ax,'on'); plot(ax,[0 cap],[0 cap],'k--','LineWidth',1.3);
xlim(ax,[0 cap]); ylim(ax,[0 cap]); axis(ax,'square'); grid(ax,'on');
xlabel(ax,'Actual site_eui','Interpreter','none');
ylabel(ax,'Predicted site_eui','Interpreter','none');
title(ax,sprintf('Central view; %d points outside bounds',nnz(~inside)));
sgtitle(fig,sprintf('%s / %s | RMSE %.2f, MAE %.2f, R2 %.3f', ...
    options.Model,options.Validation,metrics.RMSE,metrics.MAE,metrics.R2),'Interpreter','none');
exportgraphics(fig,fullfile(outputDir,'predicted_vs_actual.png'),'Resolution',180);
clear closer;

fig = figure('Visible','off','Color','white','Position',[100 100 1100 480]);
closer = onCleanup(@() close(fig));
tiledlayout(fig,1,2,'Padding','compact');
ax = nexttile;
scatter(ax,predicted,residual,7,'filled','MarkerFaceAlpha',0.12);
yline(ax,0,'k--'); grid(ax,'on');
xlabel(ax,'Predicted site_eui','Interpreter','none');
ylabel(ax,'Residual: predicted - actual');
title(ax,'Residuals across predicted energy intensity');
ax = nexttile;
histogram(ax,residual,60); grid(ax,'on');
xlabel(ax,'Residual: predicted - actual'); ylabel(ax,'Buildings');
title(ax,'Error distribution, including extreme values');
exportgraphics(fig,fullfile(outputDir,'residual_diagnostics.png'),'Resolution',180);
end
