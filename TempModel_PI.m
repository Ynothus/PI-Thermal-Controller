% Thermal PI Control Simulation
% Based on senior design: 3D printer filament recycler (PLA)
% Target: 190°C (typical PLA melting range)

clear; clc;

% System parameters
T_ambient = 25;         % °C
C = 200;                % Thermal capacity (J/°C)
R = 0.5;                % Thermal resistance (°C/W)
k_heater = 1000;         % Heater influence factor (W per control input)

% PID gains
Kp = 2.5;
Ki = 0.01;

% Simulation settings
dt = 0.1;               % time step (seconds)
t_end = 60;             % total time (seconds)
n_steps = t_end / dt;

% Target temperature
T_target = 190;         % °C

% Initialize
t = zeros(1, n_steps);
T = zeros(1, n_steps);
T(1) = T_ambient;
u = 0;                  % control signal (heater power 0-100%)
integral_error = 0;
prev_error = 0;

% Store for plotting
u_history = zeros(1, n_steps);

% Main simulation loop
for i = 1:n_steps-1
    t(i+1) = t(i) + dt;
    
    % Error
    error = T_target - T(i);
    
    % PID controller
    integral_error = integral_error + error * dt;
    u = Kp * error + Ki * integral_error;
    
    % Saturate heater (0 to 100%)
    u = max(0, min(100, u));
    u_history(i+1) = u;
    
    % Thermal dynamics: dT/dt = (Q_in - Q_out) / C
    Q_in = (u/100) * k_heater;      % heat added
    Q_out = (T(i) - T_ambient) / R; % heat lost to ambient
    dT_dt = (Q_in - Q_out) / C;
    
    % Euler integration
    T(i+1) = T(i) + dT_dt * dt;
    
    prev_error = error;
end

% Plot results
figure('Position', [100 100 800 600]);

subplot(2,1,1);
plot(t, T, 'b-', 'LineWidth', 2); hold on;
yline(T_target, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Temperature (°C)');
title('Thermal PID Control for PLA Filament Recycler');
legend('Temperature', 'Target (190°C)', 'Location', 'southeast');
grid on;

subplot(2,1,2);
plot(t, u_history, 'g-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Heater Power (%)');
title('Control Signal');
grid on;

% Performance metrics
rise_time = find(T >= 0.9*T_target, 1, 'first') * dt;
overshoot = (max(T) - T_target) / T_target * 100;
steady_state_error = abs(T(end) - T_target);

fprintf('=== PID Performance ===\n');
fprintf('Rise time (to 90%% of target): %.1f s\n', rise_time);
fprintf('Overshoot: %.1f%%\n', max(0, overshoot));
fprintf('Steady-state error: %.2f °C\n', steady_state_error);
