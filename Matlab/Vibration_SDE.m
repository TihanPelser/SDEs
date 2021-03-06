clear;
close all;

k = 500000;  % Stiffness [N/m]
m = 50;  % Rotor mass[kg]
r_u = 0.1;  % Eccentricity [m]
m_u = 0.05;  % Unbalanced mass [kg]
c = 200;  % Damping coefficient [Ns/m]
t0 = 0;  % Initial time [s] 
tf = 0.5;  % Final time [s] (originally 5s)
fs = 1E6; % Sampling rate
Nt = fs*(tf-t0);  % Time steps Originall 4096 for 5 seconds 
slew_rate = 200; % RPM slew rate [rpm/s]
dt = 1/fs;

A = [[0, 1]; [-k/m, -c/m]];

X0 = [0; 0]; % Rewrite second order DE as first -> X = [x; dx/dt] 

% Prescribed angular vel -> sinusoidal with amplitude of 5rad/s and freq of
% 1Hz, offset of 100 rad/s
omega = @(t) 10 + 5*sin(2*pi*1*t);

% Forcing function f(t)
f = @(t) m_u .* r_u .* omega(t).^2 .* sum(sin([1:1:4]' * omega(t)), 1);

% EoM -> dX = F(t,X)dt + G(t,X)dW
% F = @(t,X) A*X; % Drift
% G = @(t,X) [0; f(t)/m]/0.5E1; % Diffusion
F = @(t,X) A*X + [0; f(t)/m]; % Drift
G = @(t,X) [0; 1]/1E3; % Diffusion

EoM = @(t, X) A * X + [zeros(size(t)); f(t)/m];

SDE = sde(F, G, 'StartTime', t0, 'StartState', X0)    

[S, Tsde] = simByEuler(SDE, Nt, 'DeltaTime', dt, 'nTrials', 3); % Simulate SDE using Euler-Maruyama
[Trk, X] =  rk4th(EoM, t0, tf, X0, dt); % Runge-Kutta 4th order integration for DE

Smean = mean(S, 3); % Average of SDE solutions

SDE_Sol1 = EoM(Tsde', S(:,:,1)');
SDE_Sol2 = EoM(Tsde', S(:,:,2)');
SDE_Sol3 = EoM(Tsde', S(:,:,3)');
SDE_SolMean = EoM(Tsde', Smean');
Det_Sol = EoM(Trk, X);

figure;
hold on;
plot(Tsde, SDE_Sol1(2,:))
plot(Tsde, SDE_Sol2(2,:))
plot(Tsde, SDE_Sol3(2,:))
plot(Trk, Det_Sol(2,:), '--')
xlabel('Time')
ylabel('Acceleration')
title('Stochastic vs Deterministic Response')
legend('SDE Acc2', 'SDE Acc2', 'SDE Acc3', 'Det Acc')
hold off;

figure;
hold on;
plot(Tsde, SDE_SolMean(2,:))
plot(Trk, Det_Sol(2,:), '--')
xlabel('Time')
ylabel('Acceleration')
title('Mean Stochastic vs Deterministic Response')
legend('SDE Mean', 'DE')
hold off;

figure;
hold on;
plot(Trk, f(Trk)/m)
xlabel('Time')
ylabel('Force/kg [N/kg]')
title('Mass Normalised Forcing Function')
hold off;