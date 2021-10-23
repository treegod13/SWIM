function numgrad = GradFunction(W, X, Y, lambda)
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
% numeral gradient
numgrad = zeros(size(W));
perturb = zeros(size(W));
e = 1e-4;
for p = 1:numel(W)
    % Set perturbation vector
    perturb(p) = e;
    loss1 = LossFunction(W - perturb, X, Y, lambda);
    loss2 = LossFunction(W + perturb, X, Y, lambda);
    % Compute Numerical Gradient
    numgrad(p) = (loss2 - loss1) / (2*e);
    perturb(p) = 0;
end

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
