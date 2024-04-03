function [SF_TRC] = trc_design(external_loads,anthro, design_inputs, material_data)
hdpe = material_data("hdpe");

% ANTHROPOMETRY 
user = anthro;

% FORCE PARAMETERS
min_force = external_loads.min_force;
max_force = external_loads.max_force;

% DIMENSIONS

V= 60*10^-3; %m, constant
t= 30*10^-3; %m, constant
s = 40*10^-3; %m, constant

if(user.height>1850)
    velcro_inner_radius = 0.092;
    shell_outer_radius = 0.086;
    shell_inner_radius = 0.077;
else
    velcro_inner_radius = 0.074;
    shell_outer_radius = 0.070;
    shell_inner_radius = 0.065;
end 

shellLength = user.height/13.07; %
fin_hole_radius = (8*1500/user.height)*10^-3; %m "fin_hole_radius"  -> should this be kept constant?
w = shell_outer_radius; %m "shell_outer_radius"
k = shellLength; %m "shellLength"
a = 0.07*10^-2; %distance from top of sidebar to velcro slot (will not change)
fin_thickness = 5*user.height/1500;

%VARIABLE DIMENSIONS
partialSidebarLength = (user.height*1000 * 0.245 - 180)*10^-3; 
L =partialSidebarLength + shellLength;
fin_platform_extrusion = 60*user.height/1.7; %m "fin_platform_extrusion"  TO BE PARAMETRIZED (I THINK)

%PARAMETRIZATION INITIALIZATIONS
count = 0;
cost_lowest = [L, fin_platform_extrusion, 900000];
SF_best = [-10,-10,-10,-10,-10,-10, -10,-10];

while count<10
  
    % deflection/pressure on wearer SF -> divide/multiply sidebar length 
    
    max_deflection = L*tan(7/180*2*pi);
    
    I_x_x = t*(w -shell_inner_radius)^3/12; %not counter balanced with thigh bar breaking 
    
    deflection_force = 6*max_deflection*hdpe.modulus*I_x_x/(a^2*(3*L-a)) %not the same result as working analysis, even with same Ixx used
    velcro_area = 55*pi*velcro_inner_radius*10^3; %mm^2
    deflection_pressure = deflection_force/velcro_area;

    max_pressure = 20.532*10^-3; %MPa

    SF_pressure = deflection_pressure/max_pressure;


    % fatigue SF -> divide/multiply fin radii
    
    K_f = 2.5; %assumed constant since small variation in R-r
    fin_area = 2*pi*(fin_platform_extrusion-fin_hole_radius)^2; %m^2, check equation
    stress_max = K_f*max_force.spring_force*sin(max_force.thigh_LA_right_angle)/(fin_area*10^6); %N/mm^2
    stress_min = K_f*min_force.spring_force*sin(min_force.thigh_LA_right_angle)/(fin_area*10^6); %N/mm^2
    
    SF_cyclical = fatigue([stress_min, stress_max], hdpe, true); %??? need to add C parameter?
    
    current_SF = [SF_pressure, SF_cyclical];


    increase = 0;
    cost = 0;
    for SF = current_SF
        if SF < 2.5
            increase = 1;
            cost = cost+10000*(2.5-SF); %large cost for SF under 2.5
        else 
            cost = cost+0.001*(SF-2.5); %small cost for SF exceeding 2.5
        end
    end

    if cost<cost_lowest(1,3)
        cost_lowest = [L,fin_platform_extrusion,cost]; %store dimensions which give lowest cost
        SF_best = current_SF;
    end 

    if increase == 1
        L = L*1.02;
        fin_platform_extrusion = fin_platform_extrusion*1.02;
    else
        L = L*0.98;
        fin_platform_extrusion= fin_platform_extrusion*0.98;
    end

    count = count + 1;
end

SF_TRC = SF_best;

% WRITE DIMENSIONS IN TEXT FILE
fileID = fopen('C:\MCG4322B\MCG4322B\analysis\trc_dimensions.txt','w');
formatSpec = ['"userHeight" = %3.1f \n "shellLength" = %3.1f \n ' ...
    '"partialSidebarLength" = %3.1f \n "fin_platform_extrusion" = %3.1f \n '];
fprintf(fileID,formatSpec,user_height,shellLength, partialSidebarLength, fin_platform_extrusion);
end 