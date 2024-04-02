
% material properties: Al alloy 1100 
alum_1100 = dictionary("elastic_mod", 68900, "strength_yield", 24.1, "strength_ult", 75.8, "density", 2710);


% Polyethylene - to be changed 
polyethylene = dictionary("elastic_mod", 860, "strength_yield", 21.9, "strength_ult", 30, "density", 970);

function [] = anthropometry(user_weight, user_height, user_age, user_waist_circumference)

L_thigh = (0.53-0.285)*user_height; %m
hip_spring_length = 7/8*0.245*user_height;
waist_hip_length = 0.1*user_height;
waist_radius = user_waist_circumference/(2*pi);%m
stride_length = -2.234 + 0.106*user_age - 0.0008*user_age^2; % m 
cuff_disp = 7/8*L_thigh; %m

end