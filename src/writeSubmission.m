function submission = writeSubmission(model, testTbl, testIds, outFile)
%WRITESUBMISSION Predict site_eui for the test set and write submission.csv.
%
%   submission = WRITESUBMISSION(model, testTbl, testIds, outFile) predicts
%   with the fitted model, checks the predictions, and writes a CSV with
%   exactly two columns, id and site_eui, in the original test.csv order.

    arguments
        model
        testTbl  table
        testIds  (:,1) double
        outFile  (1,1) string
    end

    siteEUI = predict(model, testTbl);

    % Energy use intensity is physically non-negative; boosting can dip
    % slightly below zero for a few extreme rows, so clamp at 0.
    siteEUI = max(siteEUI, 0);

    % --- Submission compliance checks -------------------------------------
    assert(all(isfinite(siteEUI)), ...
        "writeSubmission:invalidPrediction", "Predictions contain NaN or Inf values.");
    assert(numel(siteEUI) == numel(testIds), ...
        "writeSubmission:rowMismatch", "Prediction count does not match test ids.");

    submission = table(testIds, siteEUI, VariableNames=["id", "site_eui"]);
    writetable(submission, outFile);

    fprintf("Wrote %d predictions to %s (site_eui range %.1f to %.1f)\n", ...
        height(submission), outFile, min(siteEUI), max(siteEUI));
end
