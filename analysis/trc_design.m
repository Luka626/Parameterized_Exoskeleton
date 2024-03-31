
% DIMENSIONS - SHOULD SCALE WITH USER 
L =370*10^-3; %m
t= 5*10^-3; %m
r = 510^-3; %m
R = 30*10^-3; %m
V= 30*10^-3; %m
w = 65*10^-3; %m
s = 74*10^-3; %m
k = 130*10^-3; %m


% deflection SF -> divide/multiply length 

cF = 0.49;
Rcf = 0.078;
cEF1 = 0.40;
RcEF1 = 0.0636;

max_deflection = Rcf - RcEF1;
%moment_inertia_cuff = t*w^3/12
I_x_x = 5.729*10^(-10); %Ixx result shown in sample calcs (doesn't align with calc above)

a = 0.07*10^-2; %taken from Ersan - Working Analysis
l = 0.37*10^-2; %taken from Ersan - Working Analysis
stretch_force = 6*max_deflection*polyethylene("elastic_mod")*I_x_x/(a^2*(3*l-a)) %not the same result as working analysis, even with same Ixx used

% pressure SF -> divide/,multiply length

A_velcro = 0.12*0.055*10^6; %mm^2, where do these numbers come from? Will they be scaled?
pressure = stretch_force/ A_velcro %MPa


% fatigue SF -> divide/multiply fin radii

loading = 1; % axial
k_t_factor = 2.18;
q = 0.88; %notch 
K_f = 1+q*(k_t_factor - 1)

fin_area = 10*pi*(60-10);  %what dimension do these numbers correspond to?
stress_max = K_f*max_force_param(:,2)*sin(max_force_angle)/fin_area
stress_min = 0;

TRC_SF = SF_fatigue(stress_max, stress_min, loading, polyethylene)

%slippage force -> maybe don't include since it will be compensated by
%velcro


% CYCLICAL SF - Ersan uses different equation. Better for this scenario?
% bending 0, axial 1
function [SF] = SF_fatigue(stress_max, stress_min, loading, polyethylene)

    % fatigue limit constants
    C_G_bending = 1;
    C_G_axial = 0.9;
    C_S = 0.8 ; %machined
    C_T = 1;
    C_R = 0.868; %95% reliability
    C_L = 1; 

    if loading == 0
        C_G = C_G_bending;
    else 
        C_G = C_G_axial;
    end
    
    Stress_mean = (stress_max + stress_min)/2 %stresses are different than what Ersan calculated
    
    Stress_alt = stress_max - stress_min
    
    S_n_prime = 0.5*polyethylene("strength_ult");
    S_n = S_n_prime*C_L*C_G*C_S*C_T*C_R;
    
    SF= S_n/Stress_alt + polyethylene("strength_ult")/Stress_mean;
end
