function [X, A] = LBP_iterative(n, sigma, percent, damp)
% loopy belief propagation for Ising model
% damp is the damping parameter used in message update
% X = rand(n,n);

if nargin < 3
    percent = 0.5;
    damp = 1;
end


if nargin < 4
    damp = 1;
end

percent = 1-percent;
% external field eta
eta = rand(n,n);
eta(eta>percent) = 1;
eta(eta<=percent) = -1;

messages = rand(n,n,4,2);

T = 50;

% M = [1 exp(eta); 1 exp(mu+sigma)]';

A = ones(1,T);
count = 1 ;
for t = 1:T
    for i = 1:n
        for j = 1:n
%             M = [exp(-eta(i,j)+sigma) exp(eta(i,j)-sigma); exp(-eta(i,j)-sigma) exp(eta(i,j)+sigma)]';
            if j > 1
                M = [exp(-eta(i,j-1)+sigma) exp(eta(i,j-1)-sigma); exp(-eta(i,j-1)-sigma) exp(eta(i,j-1)+sigma)]';
                message_left = squeeze(prod(messages(i, j-1, :, :), 3)./ messages(i, j-1, 3, :));
                message_left = M*message_left;
            else
                M = [exp(-eta(i,n)+sigma) exp(eta(i,n)-sigma); exp(-eta(i,n)-sigma) exp(eta(i,n)+sigma)]';
                message_left = squeeze(prod(messages(i, n, :, :), 3)./ messages(i, n, 3, :));
                message_left = M*message_left;
            end
            if i > 1
                M = [exp(-eta(i-1,j)+sigma) exp(eta(i-1,j)-sigma); exp(-eta(i-1,j)-sigma) exp(eta(i-1,j)+sigma)]';
                message_top = squeeze(prod(messages(i-1, j, :, :), 3)./ messages(i-1, j, 4, :));
                message_top = M*message_top;
            else
                M = [exp(-eta(n,j)+sigma) exp(eta(n,j)-sigma); exp(-eta(n,j)-sigma) exp(eta(n,j)+sigma)]';
                message_top = squeeze(prod(messages(n, j, :, :), 3)./ messages(n, j, 4, :));
                message_top = M*message_top;
            end
            if j <n
                M = [exp(-eta(i,j+1)+sigma) exp(eta(i,j+1)-sigma); exp(-eta(i,j+1)-sigma) exp(eta(i,j+1)+sigma)]';
                message_right = squeeze(prod(messages(i, j+1, :, :), 3)./ messages(i, j+1, 1, :));
                message_right = M*message_right;
            else
                M = [exp(-eta(i,1)+sigma) exp(eta(i,1)-sigma); exp(-eta(i,1)-sigma) exp(eta(i,1)+sigma)]';
                message_right = squeeze(prod(messages(i, 1, :, :), 3)./ messages(i, 1, 1, :));
                message_right = M*message_right;
            end
            if i < n
                M = [exp(-eta(i+1,j)+sigma) exp(eta(i+1,j)-sigma); exp(-eta(i+1,j)-sigma) exp(eta(i+1,j)+sigma)]';
                message_bottom = squeeze(prod(messages(i+1, j, :, :), 3)./ messages(i+1, j, 2, :));
                message_bottom = M*message_bottom;
            else
                M = [exp(-eta(1,j)+sigma) exp(eta(1,j)-sigma); exp(-eta(1,j)-sigma) exp(eta(1,j)+sigma)]';
                message_bottom = squeeze(prod(messages(1, j, :, :), 3)./ messages(1, j, 2, :));
                message_bottom = M*message_bottom;
            end
            %normalization
            message_left = (1-damp)*squeeze(messages(i,j,1,:)) + damp* message_left;
            message_top = (1-damp)*squeeze(messages(i,j,2,:)) + damp*message_top;
            message_right = (1-damp)*squeeze(messages(i,j,3,:)) + damp*message_right;
            message_bottom = (1-damp)*squeeze(messages(i,j,4,:)) + damp*message_bottom;
            message_left = message_left ./ sum(message_left);
            message_right = message_right ./ sum(message_right);
            message_top = message_top ./ sum(message_top);
            message_bottom = message_bottom ./ sum(message_bottom);
            messages(i,j,1,:) = message_left;
            messages(i,j,2,:) = message_top;
            messages(i,j,3,:) = message_right;
            messages(i,j,4,:) = message_bottom;
%             aux = squeeze(prod(messages, 3));
%             A(count) = exp(eta(i,j))*aux(i,j, 2)+exp(-eta(i,j))*aux(i,j, 1);
%             count = count+1;
        end
    end
%     aux = squeeze(prod(messages, 3));
%     p1 = exp(eta).*aux(:,:,2);
%     p0 = exp(-eta)*aux(:,:,1);
%     p = p1./(p1 + p0);
%     At = sum(sum((2*p-1).*eta + entropy(p)));
%     a = exp(sigma)*
    A(count) = LBP_log_partition(messages, eta, sigma);
    count = count+1;
end

X = squeeze(prod(messages, 3));
X = exp(eta).*X(:,:,2)./(exp(eta).*X(:,:,2)+exp(-eta).*X(:,:,1));
X = rand(n)<X;