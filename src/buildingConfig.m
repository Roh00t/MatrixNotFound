function config = buildingConfig
%BUILDINGCONFIG Shared specification for the evaluated step-by-step pipeline.
% Keep validation and full-data refitting on the same settings. Changes to
% these values require new validation; existing release scores are historical.
config = struct('Seed',2026,'NumFolds',5,'BagCycles',200, ...
    'BoostCycles',300,'NonnegativePredictions',true);
end
