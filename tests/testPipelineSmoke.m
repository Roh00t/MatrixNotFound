function tests = testPipelineSmoke
% Small synthetic end-to-end checks; no competition data or lengthy fits.
tests = functiontests(localfunctions);
end

function testValidationRefitAndExport(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
rng(12,'twister');
n = 60;
years = repelem((1:6)',10);
X = table(categorical(years), categorical(repmat(["Office";"School"],30,1)), ...
    (100:100:6000)', repmat(2000,n,1), repmat(50,n,1), ...
    (1:n)', repmat(10,n,1), 'VariableNames', ...
    {'Year_Factor','facility_type','floor_area','year_built', ...
    'energy_star_rating','heating_degree_days','cooling_degree_days'});
X.energy_star_rating(1:7:end) = NaN;
y = 10 + (1:n)'/2;
folder = tempname; mkdir(folder);
cleanup = onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
config = buildingConfig;
config.BagCycles = 3;
config.BoostCycles = 3;
result = crossValidateModels(X,y,years,config,folder);
verifySize(testCase,result.OOF,[n,4]);
verifyTrue(testCase,all(isfinite(result.OOF),'all'));
verifyTrue(testCase,all(result.FoldID>=1 & result.FoldID<=5));
verifyEqual(testCase,result.TemporalRows,find(years==6));
% Every constant baseline prediction must use its OWN fold's training mean.
for fold = 1:5
    rows = result.FoldID==fold;
    verifyEqual(testCase,result.OOF(rows,1), ...
        repmat(mean(y(~rows)),nnz(rows),1),'AbsTol',1e-12);
end
state = fitPreprocessor(X);
features = engineerFeatures(applyPreprocessor(X,state));
model = trainCandidate(features,y,"Bag",config);
bundle = struct('SchemaVersion',1,'Model',compact(model), ...
    'Preprocessor',state,'PredictorNames',{features.Properties.VariableNames});
held = X(1:3,:);
held.Year_Factor = categorical([7;7;7]);
expected = predictBuildingEnergy(bundle,held);
save(fullfile(folder,'bundle.mat'),'bundle');
saved = load(fullfile(folder,'bundle.mat'),'bundle');
actual = predictBuildingEnergy(saved.bundle,held);
verifyEqual(testCase,actual,expected,'AbsTol',1e-12);
ids = [90;30;70];
sampleFile = fullfile(folder,'sample.csv');
writetable(table(ids,zeros(3,1),'VariableNames',{'id','site_eui'}),sampleFile);
submission = exportBuildingSubmission(ids,actual,sampleFile, ...
    fullfile(folder,'submission.csv'));
verifyEqual(testCase,submission.id,ids);
verifyError(testCase,@() engineerFeatures(held),'BuildingEnergy:UnpreparedFeatures');
verifyError(testCase,@() predictBuildingEnergy(struct,held),'BuildingEnergy:InvalidBundle');
end
