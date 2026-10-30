function tests = testSelectedFactors
tests = functiontests(localfunctions);
end

function testThreeModelsShareSplitsAndSelectedSchema(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
n = 30;
years = repelem((1:3)',10);
X = table(categorical(years),(100:100:3000)',repmat(20,n,1), ...
    categorical(repmat(["Office";"School"],15,1)), ...
    'VariableNames',{'Year_Factor','floor_area','heating_degree_days','facility_type'});
y = 10+(1:n)';
folder = tempname; mkdir(folder);
cleanup = onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
config = buildingConfig; config.BoostCycles = 2;
result = compareThreeModels(X,y,years,(1:n)', ...
    {'floor_area','facility_type'},config,folder);
verifySize(testCase,result.OOF,[n,3]);
verifyTrue(testCase,all(isfinite(result.OOF),'all'));
verifyEqual(testCase,result.FeatureCounts(:,2),result.FeatureCounts(:,3));
verifyGreaterThan(testCase,result.FeatureCounts(:,1),result.FeatureCounts(:,2));
verifyEqual(testCase,height(result.Metrics),6);
verifyEqual(testCase,result.TemporalRows,find(years==3));
end
function testSelectionKeepsOnlyCorrespondingFlags(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
X = table([100;200],[0;1],categorical(["A";"B"]),[0;0], ...
    [10;20],[1;0],'VariableNames',{'floor_area','floor_area_was_missing', ...
    'facility_type','facility_type_was_unknown','max_wind_speed','max_wind_speed_was_missing'});
selected = selectComparisonFactors(X,{'floor_area','facility_type'});
verifyEqual(testCase,selected.Properties.VariableNames, ...
    {'floor_area','facility_type','floor_area_was_missing','facility_type_was_unknown'});
verifyEqual(testCase,height(selected),height(X));
verifyError(testCase,@() selectComparisonFactors(X,{'missing_column'}), ...
    'BuildingEnergy:SelectedFactors');
end
