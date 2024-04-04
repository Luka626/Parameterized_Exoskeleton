function [safety_factors] = wrc_design(anthro, design_inputs, material_data)
    hdpe = material_data("hdpe");
    al6061 = material_data("al6061");

    backplate = struct();
    adjustment = struct();
    frontplate = struct();
    belt = struct();
    padding = struct();
    spring = struct();
    hinge = struct();

    % Anthropometry
    user = anthro;
    user.waist_diameter = 0.580/pi;

    % Force Inputs
    spring.x = design_inputs.external_loads.max_force.spring_x_force;
    spring.y = design_inputs.external_loads.max_force.spring_y_force;

    %% MASS CALCULATIONS

    % BACKPLATE %
    backplate.height = 0.30;
    backplate.thickness = 0.0075;

    % Assuming 2 backplates cover 75% of the width of the user's back
    backplate.width = 0.75 * user.waist_diameter*pi / 4;

    backplate.volume = backplate.height * backplate.thickness * backplate.width;
    backplate.mass = backplate.volume * hdpe.density; %kg


    % FRONTPLATE %
    belt.width = user.waist_diameter*pi / 10;
    frontplate.height = 0.04;
    frontplate.length = user.waist_diameter*pi / 4 - belt.width/2;

    % Assuming the consistent 40mm thickness is load-bearing
    frontplate.thickness = 0.04;

    % Thickness increases with taper until dowel pin insertion
    frontplate.thickness_total = (frontplate.thickness + 0.03*1/2*(frontplate.length-frontplate.height));

    frontplate.volume = frontplate.height*frontplate.length*frontplate.thickness_total;
    frontplate.mass = frontplate.volume*hdpe.density;


    % ADJUSTMENT %
    adjustment.height = 0.02;
    adjustment.length = 0.04;
    adjustment.thickness = 0.00635;
    adjustment.volume = adjustment.height*adjustment.length*adjustment.thickness;
    adjustment.mass = adjustment.volume*al6061.density;

    % HINGE %
    hinge.diameter = 0.008;
    hinge.area = (pi/4)*hinge.diameter^2;
    hinge.length = frontplate.height;
    hinge.volume = hinge.area*hinge.length;
    hinge.mass = hinge.volume*al6061.density;


    %% BACK PLATE CALCULATIONS
    %Padding:
    backplate.friction = spring.y + backplate.mass*2 + adjustment.mass*2 + frontplate.mass*2;
    backplate.load = spring.y*(user.waist_diameter/2+0.160) / (-2*backplate.height/3);

    padding.area_total = backplate.load/design_inputs.pain_pressure;

    %assuming 85% of the back plate is covered in padding:
    padding.SF = (2*backplate.volume/backplate.height)/padding.area_total;

    %Back plate thickness:
    backplate.M = backplate.load*backplate.height/2;
    backplate.c = backplate.thickness/2;
    backplate.I = backplate.thickness^3*backplate.width/12;
    backplate.bending = backplate.M*backplate.c/backplate.I;

    backplate.SF =  hdpe.bending/backplate.bending;

    %% ADJUSTMENT CALCULATIONS
    %load comes from donning and doffing, assumign someone applies 200N of
    %force separating the back plates
    adjustment.load = 200;
    adjustment.moment = adjustment.load*(adjustment.thickness/2 + backplate.thickness/2);
    adjustment.sigma_bending = adjustment.moment * (adjustment.thickness/2) / (adjustment.height*adjustment.thickness^3/12);
    adjustment.sigma_axial = adjustment.load/adjustment.thickness*adjustment.height;
    adjustment.sigma_a_max = adjustment.sigma_bending+adjustment.sigma_axial;
    adjustment.SF = al6061.yield / adjustment.sigma_a_max;

    %future work: integrate this adjustment load case with the stifness and
    %geometry <- which changes
    %of the back plate to form a parametrization loop

    %% FRONT PLATE CALCULATIONS
    frontplate.load = 1.885*30;
    belt.release_radius = 0.09;
    belt.roller_radius = 0.06;
    belt.tension = design_inputs.strength*belt.release_radius/belt.roller_radius;

    % HINGE %
    hinge.reaction_x = -1*belt.tension;
    hinge.reaction_y = 0;
    hinge.reaction_z = frontplate.mass*9.81+frontplate.load;
    hinge.m_x = -(frontplate.mass*9.81*user.waist_diameter/2*(2/3) + frontplate.load*user.waist_diameter/2);
    hinge.m_y = 0;
    hinge.m_z = -belt.tension*user.waist_diameter/2;

    hinge.sigma_a = hinge.reaction_z/hinge.area;
    hinge.sigma_bending = (hinge.m_x*hinge.diameter/2)/((hinge.diameter/2)^4*pi/4);
    hinge.tau = 4*hinge.reaction_x/(3*hinge.area);
    hinge.sigma_a_max = hinge.sigma_a - hinge.sigma_bending;
    hinge.tau_torsion = (hinge.m_z)*(hinge.diameter/2)/((pi/2)*(hinge.diameter/2)^4);

    hinge.von_mises = sqrt(hinge.sigma_a_max^2 + 3*(hinge.tau_torsion+hinge.tau)^2);
    hinge.SF = al6061.yield/hinge.von_mises;

    % FRONT PLATE %
    %assuming peak loading occurs at interface with hinge joint
    frontplate.reaction_x = hinge.reaction_x;
    frontplate.reaction_y = hinge.reaction_y;
    frontplate.reaction_z = hinge.reaction_z;
    frontplate.m_x = hinge.m_x;
    frontplate.m_y = 0;
    frontplate.m_z = hinge.m_z;

    frontplate.sigma_a = frontplate.reaction_z/(frontplate.height*frontplate.thickness);
    frontplate.sigma_bending = (frontplate.m_x*frontplate.height/2)/((frontplate.thickness*frontplate.height^3)/12);
    frontplate.tau = 3*frontplate.reaction_x/(2*frontplate.height*frontplate.thickness);
    frontplate.sigma_a_max = frontplate.sigma_a - frontplate.sigma_bending;
    frontplate.tau_torsion = (frontplate.m_z)*(frontplate.height/2)/((frontplate.thickness^3*frontplate.height)/12);
    frontplate.tau_max = frontplate.tau+frontplate.tau_torsion;

    frontplate.von_mises = sqrt(frontplate.sigma_a_max^2 + 3*frontplate.tau_max^2);
    frontplate.SF = hdpe.yield/frontplate.von_mises;

    %% SAFETY FACTORS:

    safety_factors = struct(...
        'backplate_SF', backplate.SF, ...
        'frontplate_SF', frontplate.SF, ...
        'adjustment_SF', adjustment.SF, ...
        'hinge_SF', hinge.SF, ...
        'padding_SF', padding.SF);
end
