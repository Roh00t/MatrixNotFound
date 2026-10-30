%% Run project tests using absolute paths, regardless of the current folder
projectDir = fileparts(mfilename('fullpath'));
testDir = fullfile(projectDir,'tests');
assert(isfolder(testDir),'BuildingEnergy:MissingTests', ...
    'Test folder not found: %s. Use the latest project files.',testDir);
addpath(fullfile(projectDir,'src'));
suite = testsuite(testDir,'IncludeSubfolders',true);
assert(~isempty(suite),'BuildingEnergy:NoTests', ...
    'No tests were discovered under %s.',testDir);
fprintf('Running %d tests from %s\n',numel(suite),testDir);
testResults = run(suite);
disp(testResults);
assertSuccess(testResults);
fprintf('All project tests passed. Running the saved-output demo.\n');
run(fullfile(projectDir,'demo_submission.m'));
