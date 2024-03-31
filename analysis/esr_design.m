%ESR Calculations and Trigonometry 

 

patient_height=173.1; 

knee_height=0.285*patient_height; 

hip_height=0.53*patient_height; 

TCH_position_from_knee=10; 

thigh_cuff_height=knee_height+TCH_position_from_knee; 

 

straight_line_knee_hip=hip_height-thigh_cuff_height; 

LA_lever_arm_length=20; 

ESR_triangle_needed=sqrt((straight_line_knee_hip)^2+(LA_lever_arm_length)^2); 

 

bowden_cable_diameter=0.5; 

minimum_bending_radius_waist=(42/2)*bowden_cable_diameter; %7by19 configuration equation below 

minimum_bending_radius_pulley=6*bowden_cable_diameter;%steel cable approximation 

pulley_diameter=9; 

safety_factor=pulley_diameter/minimum_bending_radius_pulley;%pulley safety factor 

 

 

spring_length_at_rest=15.24; 

WRI_bowden_cable_length=29; 

LA_bowden_cable_length=14; 

LA_ESR_interface=10; 

ESR_WRI_interface=10; 

wire_length=7; 

carabiner_length=8.1; 

 

TOTAL_ESR_length=(2*spring_length_at_rest)+WRI_bowden_cable_length+(2*LA_bowden_cable_length)+(2*LA_ESR_interface)+(2*ESR_WRI_interface)+(2*wire_length)+(2*carabiner_length); 

TOTAL_bowden_cable_length=TOTAL_ESR_length-(2*LA_ESR_interface)-(2*wire_length)+(2*carabiner_length); 

TOTAL_sheath_length=TOTAL_bowden_cable_length-(2*LA_ESR_interface); 

 

 

 