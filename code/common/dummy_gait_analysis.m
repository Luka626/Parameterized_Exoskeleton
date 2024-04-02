function [external_loads] = dummy_gait_analysis()
    external_loads = struct();
    external_loads.spring_length = 10;
    external_loads.spring_force = 10;
    external_loads.spring_x_force = -74.40;
    external_loads.spring_y_force = -35.87;
    external_loads.thigh_LA_angle = 10;
    external_loads.cable_thigh_angle = 10;
end

