% Assume SAE class 4.8 steel
% - Proof load: Sp = 310 MPa
% - Yield strength: Sy = 240 MPa
% - Tensile strength: Su = 420 MPa

% Prelim calculations with an assumed Fmax of 100 N revealed a min At =
% 0.26 mm^2
% From Table 10.2 -> bolt of d= 3mm and At = 5.03 mm^2 selected

% Fin properties
density_fin = 965/1000/1000/1000;% [kg/mm^3]
radius_1 = 30; % [mm]
radius_2 = 5; % [mm]
fin_thickness = 10; % [mm]
plate_length = 30; % [mm]
plate_width = 20; % [mm]
mass_fin = density_fin*fin_thickness*(pi*0.5*radius_1^2 - pi*radius_2^2 + plate_length*plate_width)

% Bolt properties
S_y_bolt = 240; % [N/mm^2]
S_p_bolt = 310; % [N/mm^2]
S_u_bolt = 520; % [N/mm^2]
area_A_t = 5.03; % [mm^2]
num_bolts = 4; % number of bolts
const_K_i = 0.75; %p.432
num_surfaces = 1; % for calculation of friction to overcome
coeff_friction = 0.3; % for semi-polished steel p.447
%Inputs
F_spring = 45.79; % [N]
angle_thigh_cable = 0.483089762; % [rad]
angle_thigh_LA = 1.876851967; % [rad]

F_grav = mass_fin*9.81;
F_grav_a = F_grav*cos(angle_thigh_LA);
F_grav_t = F_grav*sin(angle_thigh_LA);

F_spring_a = F_spring*sin(angle_thigh_cable); % force perpendicular to thigh cuff 
F_sprint_t = F_spring*cos(angle_thigh_cable); %force tangential to thigh cuff 


% Axial loading (static)

axial_stress = (F_spring_a + F_grav_a) /(num_bolts*area_A_t);
SF_axial = S_y_bolt/axial_stress;


% Initial tension

F_init_tension = const_K_i*area_A_t*S_p_bolt;

% Shear loading (static)
F_shear_max = coeff_friction*F_init_tension*num_surfaces*num_bolts;
SF_shear = F_shear_max/(F_spring + F_grav);


% Endurance parameters
% Sn = S'n*C_L*C_g*C_s*C_t*C_R

C_L = 1.0;
C_G = 0.7;
C_S = 0.71; % Fig 8.13
C_T = 1; 
C_R = 0.868; % 95% reliability
k_f = 2.2; % rolled threads, Table 10.6 

% Cyclical loading
% - Assume spring force is entirely axial (since less enduring than
% bending)

S_n_prime = 0.5*S_u_bolt;
S_n_bolt = S_n_prime*C_L*C_G*C_S*C_T*C_R;

% portion of load taken by bolt varies between Fi and CP + Fi

F_mean_cyclic = ((F_init_tension + F_grav) + (F_init_tension + F_spring + F_grav))/2;

F_alt_cyclic = ((F_init_tension + F_spring + F_grav) - (F_init_tension + F_grav));

Stress_mean = F_mean_cyclic*k_f/ area_A_t;

Stress_alt = F_alt_cyclic*k_f / area_A_t;

SF_endurance = S_n_bolt/Stress_alt + S_u_bolt/Stress_mean
