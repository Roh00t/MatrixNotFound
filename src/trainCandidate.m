function model = trainCandidate(X, y, name, config)
%TRAINCANDIDATE Fit one reproducible candidate to already prepared predictors.
switch string(name)
    case "Mean"
        model = mean(y);
    case "Tree"
        model = fitrtree(X,y,'MinLeafSize',20,'MaxNumSplits',100);
    case "Bag"
        learner = templateTree('MinLeafSize',10);
        model = fitrensemble(X,y,'Method','Bag','Learners',learner, ...
            'NumLearningCycles',config.BagCycles);
    case "LSBoost"
        learner = templateTree('MinLeafSize',10,'MaxNumSplits',20);
        model = fitrensemble(X,y,'Method','LSBoost','Learners',learner, ...
            'NumLearningCycles',config.BoostCycles,'LearnRate',0.05);
    otherwise
        error('BuildingEnergy:UnknownModel','Unknown candidate: %s.',name);
end
end
