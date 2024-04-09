
function [safety_factors] = la_design(app, anthro, design_inputs, material_data)

al1100 = material_data("al1100");
al6061 = material_data("al6061");

% Anthropometry
user = anthro;
user.L_thigh = (0.53-0.285)*user.height; %m
user.stride_length = -2.234 + 0.106*user.age - 0.0008*user.age^2; % m 

% pulley specs
weight_pulley = 0.11189; %N


% CONSTANT DIMENSIONS
    waist_cuff_thickness = 0.01;%m, variable? 
    LA_pulley_center = 0.008;%m
    length_dowel_bolt = 0.03; %m, distance from end of dowel pin to centroid of screws
    length_pin = 0.03; %length of dowel pin
    hip_cuff_distance = 7/8*user.L_thigh; %m
    waist_hip_length = 0.1*user.height;
    LA_length = 1/4*user.stride_length - user.waist_radius - length_pin - waist_cuff_thickness;



%Pulley reaction forces
spring_min_force = design_inputs.external_loads.min_force.spring_force;
spring_min_force_angle = design_inputs.external_loads.min_force.thigh_LA_right_angle;
spring_max_force = design_inputs.external_loads.max_force.spring_force;
spring_max_force_angle = design_inputs.external_loads.max_force.thigh_LA_right_angle;

[angle_max_force_pulley, force_max_pulley_y, force_max_pulley_x] = compute_pulley_force(spring_max_force_angle,spring_max_force, waist_hip_length, hip_cuff_distance, user.stride_length, weight_pulley);
[angle_min_force_pulley, force_min_pulley_y, force_min_pulley_x] = compute_pulley_force(spring_min_force_angle,spring_min_force, waist_hip_length, hip_cuff_distance, user.stride_length, weight_pulley);

%For parametrization 
    best_configuration = struct();
    cost = intmax;
    cost_threshold = 0.05;
    num_iterations = 0;
    MAX_ITER = 5000;
    GOAL_SF = 2.5;


% INITIAL CONDITIONS
    h = 0.0188; 
    b = 0.013;
    ratio_b_h = b/h;
    diameter_bolt = 0.003; %M3 bolt
    radius_pin = b/2; 

log_to_output(app, sprintf("[la_design] Initializing LA parametrization: "));
log_to_output(app, sprintf("[la_design]     la_height:   %f8 m", h));
log_to_output(app, sprintf("[la_design]     la_base:     %f8 m", b));

while (cost > cost_threshold && num_iterations <= MAX_ITER)
  
    radius_pin = b/2; %new addition
    area_cross_section_LA = b*h;
    moment_of_inertia_LA = b*h^3/12;
      
    LA_volume = LA_length*area_cross_section_LA;
    pin_volume = pi*radius_pin^2*length_pin;
    
    LA_mass = (LA_volume + pin_volume)*al6061.density;
    LA_center_of_mass = (length_pin/2)*(radius_pin*2*length_pin) + (length_pin + LA_length/2)*(LA_length*h);
    
    
    % Deflection 
    a_bending = length_pin/2 + length_dowel_bolt; 
    L_bending = LA_length + LA_pulley_center + length_pin/2; 
    b_bending = L_bending - a_bending;
    
    deflection_max = force_max_pulley_y*b_bending^2*L_bending/(3*al1100.modulus*moment_of_inertia_LA);
    
    % STRESSES
    
    % bending stress
    force_max_bending= force_max_pulley_y;
    force_min_bending = force_min_pulley_y;
    
    bending_max_moment_pin = force_max_bending*b_bending/(a_bending)*0.015;
    stress_max_bending_pin = 2.8*32*bending_max_moment_pin/(pi*(2*radius_pin)^3); % 2.8 is theoretical stress concentrion at fillet (connection btwn pin + LA)
    
    bending_max_moment_LA = force_max_bending*b_bending;
    stress_max_bending_LA = 2.1*6*bending_max_moment_LA/((h-diameter_bolt)*b^2); % max stress at bolt hole (rect section) from bending
    
    bending_min_moment_pin = force_min_bending*(LA_length-length_dowel_bolt)/(length_pin/2 + length_dowel_bolt);
    stress_min_bending_pin = 2.8*32*bending_min_moment_pin/(pi*(2*radius_pin)^3); % 2.8 is theoretical stress concentrion at fillet (connection btwn pin + LA)
    
    bending_min_moment_LA = force_min_bending*b_bending;
    stress_min_bending_LA = 2.1*6*bending_min_moment_LA/((h-diameter_bolt)*b^2); % max stress at bolt hole (rect section) from bending
    
    SF_static_bending_pin = al6061.yield/stress_max_bending_pin;
    SF_static_bending_LA = al6061.yield/stress_max_bending_LA;
    
    SF_cyclical_bending_pin = fatigue([stress_min_bending_pin, stress_max_bending_pin], al6061, false);
    SF_cyclical_bending_LA = fatigue([stress_min_bending_LA, stress_max_bending_LA], al6061, false);
    
    % axial stress
    force_max_axial = force_max_pulley_x;
    force_min_axial = force_min_pulley_x;
    
    stress_max_axial_pin = force_max_axial/(area_cross_section_LA)*2.5; %max concentration at fillet
    stress_max_axial_LA = force_max_axial/((h-diameter_bolt)*b)*3.25; %max concentration at bolt hole
    
    stress_min_axial_pin = force_min_axial/(area_cross_section_LA)*2.5; %min loading at max stress location
    stress_min_axial_LA = force_min_axial/((h-diameter_bolt)*b)*3.25; %min loading at max stress location
    
    SF_static_axial_pin = al6061.yield/stress_max_axial_pin; 
    SF_static_axial_LA = al6061.yield/stress_max_axial_LA;
    
    SF_cyclical_axial_pin = fatigue([stress_min_axial_pin, stress_max_axial_pin], al6061, true); 
    SF_cyclical_axial_LA = fatigue([stress_min_axial_LA, stress_max_axial_LA], al6061, true);
    

    %% SAFETY FACTORS, DIMENSIONS:
    
        % safety factors to log %
        config.safety_factors = struct(...
        'LA_cyclical_bending_SF', SF_cyclical_bending_LA, ...
        'LA_static_axial_SF', SF_static_axial_LA,...
        'LA_static_bending_SF', SF_static_bending_LA, ...
        'pin_cyclical_bending_SF', SF_cyclical_bending_pin, ...
        'pin_static_axial_SF', SF_static_axial_pin, ...
        'pin_static_bending_SF', SF_static_bending_pin);
        weights = [0.002,0.00025,0.0005,10,0.00025,0.0005];
        config.cost = compute_cost(config.safety_factors, weights );

        % dimensions to log %
        config.dimensions = struct(...
            'LA_length', LA_length,...
            'LA_height', h, ...
            'LA_width', b, ...
            'radius_pin', radius_pin);

        %% LOOP
        % Check if we found the best configuration so far %
        if (config.cost < cost)
            best_configuration = config;
            cost = config.cost;
        end
        % Increment/Decrement parameter based on SF %
        kick = (1/1000)*sqrt(cost);
        if (SF_static_bending_pin < GOAL_SF || SF_static_bending_LA < GOAL_SF || SF_cyclical_bending_pin < GOAL_SF || SF_cyclical_bending_LA < GOAL_SF ||...
                SF_static_axial_pin < GOAL_SF || SF_static_axial_LA < GOAL_SF || SF_cyclical_axial_pin < GOAL_SF || SF_cyclical_axial_LA < GOAL_SF)
           b= b+b*kick;
           h = b/ratio_b_h;
        else
           b= b - b*kick;
           h = b/ratio_b_h;
        end
        num_iterations = num_iterations + 1;
end

    log_dimensions("code/la/LA_dimensions.txt", best_configuration.dimensions);
    safety_factors = best_configuration.safety_factors;
