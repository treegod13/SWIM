function [X_norm, mu, sigma] = data_normalize(X)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

% You need to set these values correctly
% X_norm = X;
% mu = zeros(1, size(X, 2));
% sigma = zeros(1, size(X, 2));

% ====================== YOUR CODE HERE ======================
% Instructions: First, for each feature dimension, compute the mean
%               of the feature and subtract it from the dataset,
%               storing the mean value in mu. Next, compute the 
%               standard deviation of each feature and divide
%               each feature by it's standard deviation, storing
%               the standard deviation in sigma. 
%
%               Note that X is a matrix where each column is a 
%               feature and each row is an example. You need 
%               to perform the normalization separately for 
%               each feature. 
%
% Hint: You might find the 'mean' and 'std' functions useful.
%       
% samples = size(X,1);%计算样本数；
% features = size(X,2);%计算features数；
% for i = 1 : features
%     mu(i) = mean(X(:,i));%平均； 
%     sigma(i) = std(X(:,i));%均方差；
%     X_norm(:,i) = (X(:,i) - mu(i)) / sigma(i);
% end

% 0均值标准化
% mu = mean2(X);
% sigma = std2(X);
% X_norm = (X - mu) / sigma;

%
X(X == -Inf) = 0;
X(X == 0) = mean2(X);
X_norm = (X - min(min(X))) / (max(max(X)) - min(min(X)));


% ============================================================

end
