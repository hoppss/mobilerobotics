function [mu,S,mup,Sp,K] = kalman_filter(ssm,mu,S,u,y,example,t,freq)

% Performs one iteration of Kalman Filtering

% Inputs:
%       ssm                 : State space model structure
%       mu                  : Mean of current state
%       S                   : Covariance of current state
%       u                   : Control Input of current time step
%       y                   : Measurment of current time step
%       example             : Example under consideration
%       t                   : Current time step
%       freq                : Multirate kalman filter frequency
% Outputs:
%       mu                  : Final estimated mean after iteration
%       S                   : Final estimated covariance after iteration
%       mup                 : Predicted mean after motion update
%       Sp                  : Predicted covariance after motion update
%       K                   : Kalman gain for current time step 

% State space model structure
% x[n] = A*x[n-1] + B*u[n] + R (gaussian disturbance)
% y[n] = C*x[n] + D*u[n] + Q (gaussian disturbance)

% Unwrap state space model
A = ssm.A; 
B = ssm.B;
C = ssm.C; 
D = ssm.D;
R = ssm.R;
Q = ssm.Q;
n = ssm.n;
m = ssm.m;

% Prediction Step: ------------------------------------------------
% Predict new mean based on motion
mup = A*mu + B*u;
% Predict new covariance based on motion
Sp = A*S*A' + R;

% Measurement Step: ------------------------------------------------
% If/else statement added since example 3 is a multirate kalman filter and 
% requires processing different measurement models at a certain frequency. 

if example == 3
    % Measures position and velocity
    if (mod(t,freq) == 0)
        % Calculate kalman gain
        K = Sp*C'*inv(C*Sp*C'+Q);
        % Get new mean of state after measurement
        mu = mup + K*(y-C*mup);
        % Get new covaraince of state after measurement
        S = (eye(n)-K*C)*Sp;
    else
        % Only measures velocity
        K = Sp*C'*inv(C*Sp*C'+Q);
        mu = mup + K*(y([2 4],:)-C*mup);
        S = (eye(n)-K*C)*Sp;
    end
else % example 1 an 2
    K = Sp*C'*inv(C*Sp*C'+Q);
    mu = mup + K*(y-C*mup);
    S = (eye(n)-K*C)*Sp;
end
