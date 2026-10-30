function report = validationMetricTable(oof, temporal)
%VALIDATIONMETRICTABLE Keep random OOF and later-year evaluation separate.
names = ["Mean","Tree","Bag","LSBoost"];
report = table;
for split = 1:2
    if split == 1
        source = oof;
        scheme = "Five-fold OOF";
    else
        source = temporal;
        scheme = "Latest-year holdout";
    end
    for model = names
        metrics = regressionMetrics(source.actual,source.(model+"_prediction"));
        row = [table(scheme,model,'VariableNames',{'Validation','Model'}),metrics];
        report = [report;row]; %#ok<AGROW> Only eight model/split rows.
    end
end
end
