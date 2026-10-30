%% Capture the diagnostics export exception without the unit-test wrapper
projectDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(projectDir,'src'));
outputDir = fullfile(projectDir,'artifacts','debug','export_debug');
if ~isfolder(outputDir), mkdir(outputDir); end
logPath = fullfile(outputDir,'diagnostic_error.txt');
fid = fopen(logPath,'w');
assert(fid~=-1,'BuildingEnergy:DebugLog','Cannot create diagnostics log.');
fprintf(fid,'MATLAB: %s\n',version);
fprintf(fid,'Exporter: %s\n',which('exportValidationDiagnostics'));
fprintf(fid,'Metrics: %s\n',which('computeExtendedMetrics'));
try
    exportValidationDiagnostics([1;2;3],[1;2;4],outputDir,'MakePlots',false);
    fprintf(fid,'Direct export succeeded. Running the full failing test next.\n');
    % Save detailed test output too, in case the exception occurs after export.
    testFile = fullfile(projectDir,'tests','testDiagnostics.m');
    testOutput = evalc('diagnosticResults = runtests(testFile);');
    fprintf(fid,'%s\n',testOutput);
    fprintf('%s\n',testOutput);
catch exportError
    report = getReport(exportError,'extended','hyperlinks','off');
    fprintf(fid,'%s\n',report);
    fprintf(2,'%s\n',report);
end
fclose(fid);
fprintf('Diagnostic log saved: %s\n',logPath);
