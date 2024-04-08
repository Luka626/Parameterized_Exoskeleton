function [anthro, design_inputs, material_data] = system_design(app)

    log_to_output(app, sprintf("[system_design] Received user data."))
    log_to_output(app, sprintf("[system_design] Deriving anthropometric data."))
    anthro = configure_anthropometry(app, app.user_data);
    log_to_output(app, sprintf("[system_design] Fetching design requirements."))
    design_inputs = configure_design_inputs(app, app.user_data, anthro);
    log_to_output(app, sprintf("[system_design] Querying material database:"))
    material_data = configure_material_data(app);
    log_to_output(app, sprintf("[material_db]     Accessed al6061 data."))
    log_to_output(app, sprintf("[material_db]     Accessed al1100 data."))
    log_to_output(app, sprintf("[material_db]     Accessed hdpe data."))

    log_to_output(app, sprintf("[system_design] Initiating WRC, LA, TRC analysis."))
    wrc_safety_factors = wrc_design(app, anthro, design_inputs, material_data);
    log_to_output(app, sprintf("[system_design] Returned successfully from WRC [1/3]."))
    la_safety_factors = la_design(app, anthro, design_inputs, material_data);
    log_to_output(app, sprintf("[system_design] Returned successfully from LA [2/3]."))
    trc_safety_factors = trc_design(app, anthro, design_inputs, material_data);
    log_to_output(app, sprintf("[system_design] Returned successfully from TRC [3/3]."))
    
    log_to_output(app, sprintf("[system_design] System design complete."))   
end

function [anthro] = configure_anthropometry(app, user_data)
arguments
    app
    user_data (1,1) struct
end
    anthro = struct();
    anthro.height = user_data.height/100;
    anthro.weight = user_data.weight;
    anthro.age = user_data.age;
    anthro.waist_circumference = user_data.waist_circumference/100;
    anthro.waist_radius = (user_data.waist_circumference/100)/(2*pi);
    log_to_output(app, sprintf("[configure_anthropometry] Anthropometric modelling complete."))

end

function [design_inputs] = configure_design_inputs(app, user_data, anthro)
arguments
    app
    user_data (1,1) struct
    anthro (1,1) struct

end
    design_inputs = struct();
    design_inputs.pain_pressure = 521490;
    design_inputs.strength = 16.2;
    design_inputs.blood_pressure = 16000;
    design_inputs.external_loads = gait_analysis(anthro);

end

function [material_data] = configure_material_data(app)
   
    al1100 = struct( ...
        'density', 2710, ...
        'yield', 24.1e6, ...
        'modulus', 68.9e9, ...
        'ultimate', 75.8e6);
    al6061 = struct(...
        'density', 2700, ...
        'yield', 350e6, ...
        'ultimate', 310e6, ...
        'modulus', 186e9);

    hdpe = struct(...
        'density', 970, ...
        'bending', (9.1e07 - 1.65e7)/2, ...
        'yield', (60.7e6 - 2.69e6)/2, ...
        'modulus', 0.860e9, ...
        'ultimate', 30e6);
    
    material_data = dictionary("hdpe",hdpe, "al6061", al6061, "al1100", al1100);

end
