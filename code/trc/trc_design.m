function [safety_factors] = trc_design(anthro, design_inputs, material_data)
hdpe = material_data("hdpe");

% ANTHROPOMETRY 
user = anthro;

% FORCE PARAMETERS
min_force = design_inputs.external_loads.min_force;
max_force = design_inputs.external_loads.max_force;

% DIMENSIONS

V= 60*10^-3; %m, constant
t= 30*10^-3; %m, constant
s = 40*10^-3; %m, constant

shellLength = user.height/13.07; %m
partialSidebarLength = (user.height*1000 * 0.245 - 180)*10^-3; %m
shell_outer_radius = user.height/20;
shell_inner_radius = user.height/22;
fin_platform_extrusion = 60*user.height/1700;

velcro_inner_radius = user.height/20;

fin_hole_radius = 0.01; %m 
fin_thickness = 5*user.height/1500;
fin_platform_width = 2*user.height/20*sin(18/180*pi)-0.01;
fin_platform_height = (70.58-60)/(2000-1700)*user.height - 0.01;
platform_height_width = fin_platform_height/fin_platform_width;


a = 0.04; %distance from top of sidebar to velcro slot (will not change)

L =partialSidebarLength + shellLength;

    % For parametrization %
    best_configuration = struct();
    cost = intmax;
    cost_threshold = 0.05;
    num_iterations = 0;
    MAX_ITER = 1000;
    GOAL_SF = 2.5;


while (cost > cost_threshold && num_iterations <= MAX_ITER)
  
    % deflection/pressure on wearer SF -> divide/multiply sidebar length 
    
    max_deflection = L*tan(7/180*pi);
    
    I_x_x = t*(shell_outer_radius -shell_inner_radius)^3/12; %not counter balanced with thigh bar breaking 
    
    deflection_force = 6*max_deflection*hdpe.modulus*I_x_x/(a^2*(3*L-a)); %N, not the same result as working analysis, even with same Ixx used
    velcro_area = 0.055*pi*velcro_inner_radius;%m^2
    deflection_pressure = deflection_force/velcro_area; %N/m^2


    max_pressure = 20532; %N/m^2
    SF_pressure = max_pressure/deflection_pressure;

    %bending stress on thigh bar
    thigh_bar_area = t*(shell_outer_radius -shell_inner_radius);
    bending_stress = deflection_force/thigh_bar_area;
    SF_bending = hdpe.yield/bending_stress;


    % fatigue SF -> divide/multiply fin radii
    
    K_f = 2.5; %assumed constant since small variation in outer-inner radius
    fin_base_area = fin_thickness*fin_platform_height; %m^2
    stress_max = K_f*max_force.spring_force*sin(max_force.cable_thigh_right_angle)/(fin_base_area); %N/m^2
    stress_min = K_f*min_force.spring_force*sin(min_force.cable_thigh_right_angle)/(fin_base_area); %N/m^2
    
    SF_cyclical = fatigue([stress_min, stress_max], hdpe, true);

      
    %% SAFETY FACTORS, DIMENSIONS:
    
    % safety factors to log %
    config.safety_factors = struct(...
        'SF_skin_pressure', SF_pressure, ...
        'SF_bending', SF_bending, ...
        'SF_fin_cyclical', SF_cyclical);
    weights = [1,100,1];
    config.cost = compute_cost(config.safety_factors, weights);

    % dimensions to log %
        config.dimensions = struct(...
        'shell_outer_radius', shell_outer_radius, ...
        'fin_platform_width', fin_platform_width, ...
        'fin_platform_height', fin_platform_height, ...
        'fin_thickness', fin_thickness);
   %% LOOP
        % Check if we found the best configuration so far %
        if (config.cost < cost)
            best_configuration = config;
            cost = config.cost;
        end

        % Increment/Decrement parameter based on SF %
        kick = (1/10000)*sqrt(cost);

   if SF_pressure < GOAL_SF || SF_bending < GOAL_SF
            shell_outer_radius = shell_outer_radius - shell_outer_radius*kick;
            if shell_outer_radius < shell_inner_radius + 0.003
                shell_outer_radius = shell_inner_radius + 0.003;
            end
   else
            shell_outer_radius = shell_outer_radius + shell_outer_radius*kick;
   end

    if SF_cyclical < GOAL_SF    
       fin_thickness = fin_thickness + fin_thickness*kick
       fin_platform_height =fin_platform_height + fin_platform_height*kick
    else
       fin_thickness = fin_thickness - fin_thickness*kick;
       if fin_thickness < 0.003
           fin_thickness = 0.003; % limited for manufacturing purposes
       end 
       fin_platform_height = fin_platform_height - fin_platform_height*kick;
       if fin_platform_height < 0.0375
           fin_platform_height = 0.0375;
       end 
    end
    fin_platform_width = fin_platform_height/platform_height_width;
    num_iterations = num_iterations + 1;

end

 best_configuration.dimensions
 log_dimensions("C:\MCG4322B\MCG4322B\code\trc\trc_dimensions.txt", best_configuration.dimensions)
 safety_factors = best_configuration.safety_factors
 num_iterations

% WRITE DIMENSIONS IN TEXT FILE
fileID = fopen('C:\MCG4322B\MCG4322B\code\trc\thighcuff_dimensions.txt','w');
formatSpec = ['"userHeight" = %3.1f \n "shellLength" = %3.1f \n ' ...
    '"partialSidebarLength" = %3.1f \n "shell_outer_radius" = %3.1f \n' ...
    '"shell_inner_radius" = %3.1f \n' '"fin_platform_extrusion" = %3.1f \n'];
fprintf(fileID,formatSpec,user.height*1000,shellLength*1000, partialSidebarLength*1000, ...
    shell_outer_radius*1000, shell_inner_radius*1000, fin_platform_extrusion*1000);

fileID = fopen('C:\MCG4322B\MCG4322B\code\trc\thighFin_dimensions.txt','w');
formatSpec = ['"userHeight" = %3.1f \n "fin_hole_radius" = %3.1f \n "fin_thickness" = %3.1f \n ' ...
    '"fin_platform_width" = %3.1f \n "fin_platform_height" = %3.1f \n '];
fprintf(fileID,formatSpec,user.height*1000,fin_hole_radius*1000, fin_thickness*1000,  fin_platform_width*1000, fin_platform_height*1000);

fileID = fopen('C:\MCG4322B\MCG4322B\code\trc\velcroStrap_dimensions.txt','w');
formatSpec = '"userHeight" = %3.1f \n "velcro_inner_radius" = %3.1f \n ';
fprintf(fileID,formatSpec,user.height*1000, velcro_inner_radius*1000);
end 