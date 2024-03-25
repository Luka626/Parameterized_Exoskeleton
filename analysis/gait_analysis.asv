% USER DATA

user_weight = 85.3; %kg
user_height = 1.731; %m
user_age = 81; 

user_waist_circumference = 0.90; %m

% GAIT DATA
gait_param = readmatrix('left_right_thigh_angles.csv');

% ANTRHO DATA
L_thigh = (0.53-0.285)*user_height; %m
hip_spring_length = 7/8*0.245*user_height;
waist_hip_length = 0.1*user_height;
waist_radius = user_waist_circumference/(2*pi);%m
stride_length = -2.234 + 0.106*user_age - 0.0008*user_age^2; % m 


% EXOSKELETON CONSTANTS
LA_pulley_center = 0.08; %m
waist_cuff_thickness = 0.010; %m, should it be constant or change with weight?
length_pin = 0.030; % m
LA_length = 1/4*stride_length - waist_radius - length_pin - waist_cuff_thickness
hip_pulley_length = waist_cuff_thickness + length_pin + LA_length + waist_radius + LA_pulley_center;
cuff_disp = 7/8*L_thigh %m
spring_coeff = 500; %N/m

% ISSUE: max/min forces may not occur at same spot depending on ratio of LA
% length to thigh length
max_force_right_angle = gait_param(46,3)
min_force_right_angle= gait_param(1,3)
%max_x_force_angle = gait_param(46,15)*pi/180;
%max_y_force_angle = gait_param(15,15)*pi/180;
%min_x_force_angle = gait_param(1, 15)*pi/180;
%min_y_force_angle = gait_param(36,15)*pi/180;

% PEAK FLEXION
og_y_length = cuff_disp*sin(min_force_right_angle);
og_x_length = LA_length - cuff_disp*cos(min_force_right_angle);
og_spring_length = (og_x_length^2 + og_y_length^2)^(1/2);

max_force_param = find_spring_force(spring_coeff, cuff_disp, max_force_right_angle, og_spring_length, hip_pulley_length)
min_force_param = find_spring_force(spring_coeff, cuff_disp, min_force_right_angle, og_spring_length, hip_pulley_length)
%max_x_force_param = find_spring_force(spring_coeff, LA_length, cuff_disp, max_x_force_angle, og_spring_length)
%min_x_force_param = find_spring_force(spring_coeff, LA_length, cuff_disp, min_x_force_angle, og_spring_length)
%max_y_force_param = find_spring_force(spring_coeff, LA_length, cuff_disp, max_y_force_angle, og_spring_length)
%min_y_force_param = find_spring_force(spring_coeff, LA_length, cuff_disp, min_y_force_angle, og_spring_length)


function [force_param] = find_spring_force(spring_coeff, cuff_disp, thigh_LA_angle, og_spring_length, hip_pulley_length)
spring_y_length = cuff_disp*sin(thigh_LA_angle)
spring_x_length = hip_pulley_length - cuff_disp*cos(thigh_LA_angle)
cable_LA_angle = atan(spring_y_length/spring_x_length);

spring_length = (spring_x_length^2 + spring_y_length^2)^(1/2);
spring_force = spring_coeff*(spring_length - og_spring_length);
spring_x_force = spring_force*cos(cable_LA_angle);
spring_y_force = spring_force*sin(cable_LA_angle);

cable_thigh_angle = pi -thigh_LA_angle - cable_LA_angle;

force_param = [spring_length, spring_force, spring_x_force, spring_y_force,thigh_LA_angle, cable_thigh_angle];

end