function [J] = LossFunction(W, X, Y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
% X = [ones(length(X), 1)  X];

% Setup some useful variables
m = min(size(X, 1), size(Y, 1));
         
% You need to return the following variables correctly 
J = 0;

% Loss
s = W*X(1:m, :)' - Y(1:m, :)';
J = 1 / m * trace(s * s');
regularize = lambda  * trace(W * W');
J = J + regularize;



end
