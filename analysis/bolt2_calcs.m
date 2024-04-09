% Lever arm dimensions
A = 30; % [mm], dowel pin length
B = 100; % [mm], end of dowel pin to end of LA
C = 30; % [mm], end of dowel pin to midpoint between bolts

%Bolt properties
S_y_bolt = 240; % [N/mm^2]
S_p_bolt = 310; % [N/mm^2]
S_u_bolt = 520; % [N/mm^2]
area_A_t = 5.03; % [mm^2]
num_bolts = 4; % number of bolts
const_K_i = 0.75; %p.432
num_surfaces = 1; % for calculation of friction to overcome
coeff_friction = 0.3; % for semi-polished steel p.447



% Material properties
SF = 2.5; 
% Assume SAE class 4.8 steel
% - Proof load: Sp = 310 MPa
% - Yield strength: Sy = 240 MPa
% - Tensile strength: Su = 420 MPa
% AISI 1020, as-rolled (Appendix C-4)
Sy_bolt = 240; % [MPa], yield strength
Ssy_bolt = 0.58*Sy_bolt; % [MPa], yield strength in shear (?)


% Al 7075 for LA
density_LA = 2.81/1000/(10^3); % [kg/mm^3] converted from g/cm^3

% Assumptions
% - assume uniformly distributed load along dowel pin
% - assume equal sharing between bolts

% Centroid of LA
height_LA = 11.1; % [mm]
thickness_LA = 22.2; % [mm]
CoM_LA = B/2; %to be changed to more accurate value later
mass_LA = height_LA*thickness_LA*B*density_LA;


% Sum of moments about centroid of bolts
% - solve for w [N/m] of distributed load
% - at 2/3 length of dist load, F=1/2wL
% - bolt forces simplified to one reaction force at centroid, F_b_y

F_spring_y = 36.1612941; % [N], max vertical force
F_spring_x = 73.63005983; 
Fg = mass_LA*9.81; % [N]
% 0 = w*A*(A/2 + C + D) - Fy*(B-C-D) - Fg*(B/2-C-D)

w= (F_spring_y*(B-C)+Fg*(B/2-C))/(A*(A/2 + C)); % [N/mm]

%Sum of vertical forces

% 0 = -*w*A + Fby - Fy -Fg

Fby = F_spring_y + Fg + w*A

% Sum of horizontal forces
% - assume horizontal reaction force taken by bolts (neglect reaction at dowel pin) 
Fbx = F_spring_x;

F_bolt = sqrt(Fbx^2 + Fby^2)/2 % this corresponds to make force exerted on each bolt

% Initial tension

F_init_tension = const_K_i*area_A_t*S_p_bolt;

% Shear stress

F_shear_max = coeff_friction*F_init_tension*num_surfaces*num_bolts; % friction to overcome
SF_shear = F_shear_max/F_bolt %check?


% Case where there is no spring force, only Fg

w2= (Fg*(B/2-C))/(A*(A/2 + C)); % [N/mm]
F_bolt_2=  Fg + w2*A;  % no horizontal forces in this case


% Cyclical loading
% - Assume spring force is entirely bending

% Endurance parameters
% Sn = S'n*C_L*C_g*C_s*C_t*C_R

C_L = 1.0;
C_G = 1.0; % bending 
C_S = 0.71; % Fig 8.13
C_T = 1; 
C_R = 0.868; % 95% reliability
k_f = 2.2; % rolled threads, Table 10.6 

S_n_prime = 0.5*S_u_bolt*0.8; %0.8 coeff added since shear
S_n_bolt = S_n_prime*C_L*C_G*C_S*C_T*C_R;

% portion of load taken by bolt varies between F_bolt_2 and (F_bolt)

F_mean_cyclic = (F_bolt_2 + F_bolt)/2;

F_alt_cyclic = (F_bolt - F_bolt_2)/2;

Stress_mean = F_mean_cyclic*k_f/ area_A_t;

Stress_alt = F_alt_cyclic*k_f / area_A_t;

SF_endurance = S_n_bolt/Stress_alt + S_u_bolt/Stress_mean


