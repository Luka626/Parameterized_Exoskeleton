function [anthro, design_inputs, material_data] = system_design(user_data)
arguments
    user_data (1,1) struct
end

    anthro = configure_anthropometry(user_data);
    design_inputs = configure_design_inputs(user_data, anthro);
    material_data = configure_material_data();

    wrc_safety_factors = wrc_design(anthro, design_inputs, material_data);
    %la_safety_factors = la_design(anthro, design_inputs, material_data);
    %trc_safety_factors = trc_design(anthro, design_inputs, material_data)

    fprintf("System design complete!\n")    
end

function [anthro] = configure_anthropometry(user_data)
arguments
    user_data (1,1) struct
end

    anthro = struct();
    anthro.height = user_data.height;
    anthro.weight = user_data.weight;
    anthro.age = user_data.age;
    anthro.waist_circumference = user_data.waist_circumference/100;
    anthro.waist_radius = (user_data.waist_circumference/100)/(2*pi);

end

function [design_inputs] = configure_design_inputs(user_data, anthro)
arguments
    user_data (1,1) struct
    anthro (1,1) struct

end
    design_inputs = struct();
    design_inputs.pain_pressure = 521490;
    design_inputs.strength = 16.2;
    design_inputs.blood_pressure = 16000;
    design_inputs.external_loads = gait_analysis(anthro);

end

function [material_data] = configure_material_data()
   
    al1100 = struct( ...
        'density', 2710, ...
        'yield', 24.1e6, ...
        'modulus', 68.9e9, ...
        'ultimate', 75.8e6);
    al6061 = struct(...
        'density', 2700, ...
        'yield', 350e6, ...
        'modulus', 186e9);

    hdpe = struct(...
        'density', 970, ...
        'bending', (9.1e07 - 1.65e7)/2, ...
        'yield', (60.7e6 - 2.69e6)/2, ...
        'modulus', 0.860e9, ...
        'ultimate', 30e6);
    
    material_data = dictionary("hdpe",hdpe, "al6061", al6061, "al1100", al1100);



      % usage:
    % [design_inputs, material_data] = system_design(user_data);
    % trc_material = material_data("al1100");
    % trc_material.density 
end
