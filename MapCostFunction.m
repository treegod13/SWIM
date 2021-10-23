function [J, W_grad] = MapCostFunction(W, X, Y, lambda)
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
X = [ones(length(X), 1)  X];

% Setup some useful variables
m = min(size(X, 1), size(Y, 1));
         
% You need to return the following variables correctly 
J = 0;
W_grad = zeros(size(W));

% Loss
s = W*X(1:m, :)' - Y(1:m, :)';
J = 1 / m * trace(s * s');
regularize = lambda  * trace(W * W');
J = J + regularize;

% W_grad = computeNumericalGradient(J, W);
% gradient
for i = 1:size(W,1)
    for j = 1:size(X, 2)
        W_grad(i,j) = 2 * W(i,:) * X' * X(:, j);
    end
end
W_grad = (1 / m * trace(s * s') * 2) .* X(1,1) + 2*lambda .* W;
W_grad - numgrad

% delta_3 = a_3 - Y;
% %delta_2 = delta_3 * Theta2;
% %delta_2 = delta_2(:,2:end) .* sigmoidGradient(z_2);
% delta_2 = delta_3 * Theta2 .* a_2 .* (1 - a_2);
% delta_2 = delta_2(:,2:end);%注意！！！上面注释掉的是错误的！！！why？
% Theta1_grad = delta_2' * a_1 / m;
% Theta2_grad = delta_3' * a_2 / m;
% 
% t1 = [zeros(size(t1,1),1) t1] * lambda / m;
% t2 = [zeros(size(t2,1),1) t2] * lambda / m;
% Theta1_grad = Theta1_grad + t1;
% Theta2_grad = Theta2_grad + t2;




% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
% grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
