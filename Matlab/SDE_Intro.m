clear;
close all;

t0 = 0;
X0 = [1; 0.5]; % Multivariate -> X = [x1; x2]

% Modified Mathworks tutorial on SDEs
F = @(t,X) 0.1 * X + 1*t; % Drift
% G = @(t,X) 0.3 * X;  % Diffusion
G = @(t,X) [0.3; 0.3];  % Diffusion

SDE = sde(F, G, 'StartTime', t0, 'StartState', X0)    % dX = F(t,X)dt + G(t,X)dW

nPeriods = 100;
dt = 1E-1;

[S,T] = simulate(SDE, nPeriods, 'DeltaTime', dt, 'nTrials', 3);


figure;
hold on;
plot(T, S(:,:,1))
plot(T, S(:,:,2))
plot(T, S(:,:,3))
xlabel('Time')
ylabel('x')
title('Some Realisations of the SDE')
legend('1-x1', '1-x2', '2-x1', '2-x2', '3-x1', '3-x2')
hold off;
