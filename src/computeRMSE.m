function err = computeRMSE(yTrue, yPred)
%COMPUTERMSE Root mean squared error between true and predicted values.
%
%   err = COMPUTERMSE(yTrue, yPred) returns sqrt(mean((yTrue - yPred).^2)),
%   the competition metric for site_eui.

    arguments
        yTrue (:,1) double
        yPred (:,1) double {mustBeEqualSize(yTrue, yPred)}
    end

    err = sqrt(mean((yTrue - yPred).^2));
end

function mustBeEqualSize(a, b)
    if ~isequal(size(a), size(b))
        error("computeRMSE:sizeMismatch", "yTrue and yPred must be the same size.");
    end
end
