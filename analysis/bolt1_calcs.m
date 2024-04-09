% Load case
% - assume pure shear loading 

% Bolt properties
S_y_bolt = 240; % [N/mm^2]
S_p_bolt = 310; % [N/mm^2]
S_u_bolt = 520; % [N/mm^2]
area_A_t = 5.03; % [mm^2]
num_bolts = 1; % number of bolts
const_K_i = 0.75; %p.432
num_surfaces = 1; % for calculation of friction to overcome
coeff_friction = 0.3; % for semi-polished steel p.447

F_bolt = 15; % to be provided by Luka 

% Initial tension

F_init_tension = const_K_i*area_A_t*S_p_bolt

% Shear stress

F_shear_max = coeff_friction*F_init_tension*num_surfaces*num_bolts; % friction to overcome
SF_shear = F_shear_max/F_bolt %check?