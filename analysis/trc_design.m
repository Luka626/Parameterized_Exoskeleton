function [SF_TRC] = trc_design(user_age, user_height, user_waist_circumference)
% DIMENSIONS

V= 60*10^-3; %m, constant
t= 30*10^-3; %m, constant
s = 40*10^-3; %m, constant

if(user_height>1850)
    velcro_inner_radius = 0.092;
    shell_outer_radius = 0.086;
    shell_inner_radius = 0.077;
else
    velcro_inner_radius = 0.074;
    shell_outer_radius = 0.070;
    shell_inner_radius = 0.065;
end 

shellLength = user_height/13.07; %
fin_hole_radius = (8*1500/user_height)*10^-3; %m "fin_hole_radius"  -> should this be kept constant?
w = shell_outer_radius; %m "shell_outer_radius"
k = shellLength; %m "shellLength"
a = 0.07*10^-2; %distance from top of sidebar to velcro slot (will not change)
fin_thickness = 5*user_height/1500;
%VARIABLE DIMENSIONS
partialSidebarLength = (user_height*1000 * 0.245 - 180)*10^-3; 
L =partialSidebarLength + shellLength;
fin_platform_extrusion = 60*user_height/1.7; %m "fin_platform_extrusion"  TO BE PARAMETRIZED (I THINK)

%PARAMETRIZATION INITIALIZATIONS
count = 0;
cost_lowest = [L, fin_platform_extrusion, 900000];
SF_best = [-10,-10,-10,-10,-10,-10, -10,-10];

while count<10
  
    % deflection/pressure on wearer SF -> divide/multiply sidebar length 
    
    max_deflection = L*tan(7/180*2*pi);
    
    I_x_x = t*(w -shell_inner_radius)^3/12; %not counter balanced with thigh bar breaking 
    
    deflection_force = 6*max_deflection*polyethylene("elastic_mod")*I_x_x/(a^2*(3*L-a)) %not the same result as working analysis, even with same Ixx used
    velcro_area = 55*pi*velcro_inner_radius*10^3; %mm^2
    deflection_pressure = deflection_force/velcro_area;

    max_pressure = 20.532*10^-3; %MPa

    SF_pressure = deflection_pressure/max_pressure;


    % fatigue SF -> divide/multiply fin radii
    
    loading = 1; % axial
    K_f = 2.5; %assumed constant since small variation in R-r
    fin_area = 2*pi*(fin_platform_extrusion-fin_hole_radius)^2; %m^2, check equation
    stress_max = K_f*max_force_param(:,2)*sin(max_force_right_angle)/(fin_area*10^6); %N/mm^2
    stress_min = K_f*min_force_param(:,2)*sin(min_force_right_angle)/(fin_area*10^6); %N/mm^2
    
    SF_cyclical = SF_fatigue(stress_max, stress_min, loading, polyethylene);
    
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

% CYCLICAL SF 
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
    
    Stress_mean = (stress_max + stress_min)/2;
    
    Stress_alt = stress_max - stress_min;
    
    S_n_prime = 0.5*polyethylene("strength_ult");
    S_n = S_n_prime*C_L*C_G*C_S*C_T*C_R;
    
    SF= S_n/Stress_alt + polyethylene("strength_ult")/Stress_mean;
end
