
function [SF_LA] = la_design(external_loads,anthro, design_inputs, material_data)


al1100 = material_data("al1100");

% Anthropometry
user = anthro;
user.waist_hip_length = 0.1*user.height;
user.waist_radius = user.waist_circumference/(2*pi);

% pulley specs
weight_pulley = 0.11189; %N


% CONSTANT DIMENSIONS
    waist_cuff_thickness = 10;%mm, variable? 
    LA_pulley_center = 8;
    length_dowel_bolt = 30; %mm, distance from end of dowel pin to centroid of screws
    length_pin = 30; %length of dowel pin
    radius_pin = 3.5; % mm
    hip_cuff_distance = 7/8*L_thigh; %m
    LA_length = 1/4*user.stride_length - user.waist_radius - length_pin - waist_cuff_thickness;

    
% INITIAL CONDITIONS
    b = 13;
    h = 9;
    diameter_bolt = 3; %M3 bolt

    cost_lowest = [b, h, 900000];
    SF_best = [-10,-10,-10,-10,-10,-10, -10,-10];
    count = 0;

%Pulley reaction forces
force_param.spring_x_force = spring_x_force;
force_param.spring_y_force = spring_y_force;
[angle_max_force_pulley, force_max_pulley_y, force_max_pulley_x] = find_pulley_force(external_loads.max_force.thigh_LA_right_angle,external_loads.max_force.spring_force, waist_hip_length, hip_cuff_distance, stride_length, weight_pulley);
[angle_min_force_pulley, force_min_pulley_y, force_min_pulley_x] = find_pulley_force(external_loads.min_force.thigh_LA_right_angle,external_loads.min_force.spring_force,waist_hip_length, hip_cuff_distance, stride_length, weight_pulley);

while count<10
  
    area_cross_section_LA = b*h;
    moment_of_inertia_LA = b*h^3/12;
      
    LA_volume = LA_length*area_cross_section_LA;
    pin_volume = pi*radius_pin^2*length_pin;
    
    LA_mass = (LA_volume + pin_volume)*al1100.density;
    LA_center_of_mass = (length_pin/2)*(radius_pin*2*length_pin) + (length_pin + LA_length/2)*(LA_length*h);
    
    
    % Deflection 
    a_bending = length_pin/2 + length_dowel_bolt; %find better name?
    L_bending = LA_length + LA_pulley_center + length_pin/2; %find better name?
    b_bending = L_bending - a_bending; %find better name?
    
    deflection_max = force_max_pulley_y*b_bending^2*L_bending/(3*alum_1100.modulus*moment_of_inertia_LA);
    
    % STRESSES
    
    % bending stress
    force_max_bending= force_max_pulley_y;
    force_min_bending = force_min_pulley_y;
    
    bending_max_moment_pin = -force_max_bending*(LA_length-length_dowel_bolt)/(length_pin/2 + length_dowel_bolt);
    stress_max_bending_pin = 2.8*32*bending_max_moment_pin/(pi*(2*radius_pin)^3); % 2.8 is theoretical stress concentrion at fillet (connection btwn pin + LA)
    
    bending_max_moment_LA = -force_max_bending*(LA_length-length_dowel_bolt);
    stress_max_bending_LA = 2.1*(bending_max_moment_LA*h/2/moment_of_inertia_LA)*bending_max_moment_LA/((h-diameter_bolt)*b^2); % max stress at bolt hole (rect section) from bending
    
    bending_min_moment_pin = -force_min_bending*(LA_length-length_dowel_bolt)/(length_pin/2 + length_dowel_bolt);
    stress_min_bending_pin = 2.8*32*bending_min_moment_pin/(pi*(2*radius_pin)^3); % 2.8 is theoretical stress concentrion at fillet (connection btwn pin + LA)
    
    bending_min_moment_LA = -force_min_bending*(LA_length-length_dowel_bolt);
    stress_min_bending_LA = 2.1*(bending_min_moment_LA*h/2/moment_of_inertia_LA)*bending_max_moment_LA/((h-diameter_bolt)*b^2); % max stress at bolt hole (rect section) from bending
    

    SF_static_bending_pin = stress_max_bending_pin/al1100.yield;
    SF_static_bending_LA = stress_max_bending_LA/al1100.yield;
    
    SF_cyclical_bending_pin = SF_fatigue(stress_max_bending_pin, stress_min_bending_pin, 0);
    SF_cyclical_bending_LA = SF_fatigue(stress_max_bending_LA, stress_min_bending_LA, 0);
    
    % axial stress
    force_max_axial = force_max_pulley_x;
    force_min_axial = force_min_pulley_x;
    
    stress_max_axial_pin = force_max_axial/(area_cross_section_LA)*2.5; %max concentration at fillet
    stress_max_axial_LA = force_max_axial/(h-diameter_bolt)*3.25; %max concentration at bolt hole
    
    stress_min_axial_pin = force_min_axial/(area_cross_section_LA)*2.5; %min loading at max stress location
    stress_min_axial_LA = force_min_axial/(h-diameter_bolt)*3.25; %min loading at max stress location
    
    SF_static_axial_pin = stress_max_axial_pin/al1100.yield;
    SF_static_axial_LA = stress_max_axial_LA/al1100.yield;
    
    SF_cyclical_axial_pin = SF_fatigue(stress_max_axial_pin, stress_min_axial_pin, 1);
    SF_cyclical_axial_LA = SF_fatigue(stress_max_axial_LA, stress_min_axial_LA, 1);
    
    SF_list = [SF_static_bending_pin, SF_static_bending_LA, SF_cyclical_bending_pin, SF_cyclical_bending_LA, SF_static_axial_pin, SF_static_axial_LA, SF_cyclical_axial_pin, SF_cyclical_axial_LA]
    
    increase = 0;
    cost = 0;
    for SF = SF_list
        if SF < 2.5
            SF_met =false;
            increase = 1;
            cost = cost+10000*(2.5-SF); %large cost for SF under 2.5
        else 
            cost = cost+0.001*(SF-2.5); %small cost for SF exceeding 2.5
        end
    end

    if cost<cost_lowest(1,3)
        cost_lowest = [b,h,cost]; %store dimensions which give lowest cost
        SF_best = SF_list;
    end 

    if increase == 1
        b = b*1.02;
        h = h*1.02;
        increase;
    else
        b = b*0.98;
        h= h*0.98;
    end

    count = count + 1;


end

cost_lowest
SF_LA = SF_best;

% WRITE DIMENSIONS IN TEXT FILE
fileID = fopen('C:\MCG4322B\MCG4322B\analysis\LA_dimensions.txt','w');
formatSpec = '"height" = %3.1f \n "width" = %3.1f \n "length" = %3.1f';
fprintf(fileID,formatSpec,b, a, LA_length);

end

% CYCLICAL SF
% bending 0, axial 1
function [SF] = SF_fatigue(stress_max, stress_min, loading)
    
    % material properties: Al alloy 1100 
    alum_1100 = struct;
    alum_1100.elastic_mod = 68900;
    alum_1100.strength_yield = 24.1;
    alum_1100.strength_ult = 75.8;
    alum_1100.density = 2710;

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
    
    Stress_mean = (stress_max + stress_min)/2; 
    
    Stress_alt = stress_max - stress_min;
    
    S_n_prime = 0.5*alum_1100.strength_ult;
    S_n = S_n_prime*C_L*C_G*C_S*C_T*C_R;
    
    SF= S_n/Stress_alt + alum_1100.strength_ult/Stress_mean;
end



% PULLEY REACTION FORCES
function [angle_force_pulley, force_pulley_y, force_pulley_x] = find_pulley_force(angle_thigh,force_spring,waist_hip_length, hip_cuff_distance, stride_length, weight_pulley)

    angle_centerline_thigh = pi/2 - angle_thigh; %rads
    
    angle_LA_cable = atan((waist_hip_length + cos(angle_centerline_thigh) * hip_cuff_distance)/(1/4*stride_length-sin(angle_centerline_thigh)*hip_cuff_distance));
    angle_force_pulley = angle_LA_cable/2;
    
    force_weight_CoM = LA_mass*9.81; %never used, should it be?
    
    force_pulley_reaction = 2*force_spring*cos(angle_force_pulley);
    
    force_pulley_reaction_x = force_pulley_reaction*cos(angle_force_pulley);
    force_pulley_reaction_y = force_pulley_reaction*sin(angle_force_pulley);
    
    force_pulley_y = force_pulley_reaction_y + weight_pulley;
    force_pulley_x = force_pulley_reaction_x;
end
