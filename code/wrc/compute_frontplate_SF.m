function [hinge_SF, frontplate_SF] = compute_frontplate_SF (components, user, al6061, hdpe)
    %% FRONT PLATE CALCULATIONS
    hinge = components.hinge;
    frontplate = components.frontplate;
    belt = components.belt;

    % HINGE %
    hinge.reaction_x = -1*belt.tension;
    hinge.reaction_y = 0;
    hinge.reaction_z = frontplate.mass*9.81+frontplate.load;
    hinge.m_x = -(frontplate.mass*9.81*user.waist_radius*2/2*(2/3) + frontplate.load*user.waist_radius*2/2);
    hinge.m_y = 0;
    hinge.m_z = -belt.tension*user.waist_radius*2/2;

    hinge.sigma_a = hinge.reaction_z/(pi/4)*hinge.diameter^2;
    hinge.sigma_bending = (hinge.m_x*hinge.diameter/2)/((hinge.diameter/2)^4*pi/4);
    hinge.tau = 4*hinge.reaction_x/(3*(pi/4)*hinge.diameter^2);
    hinge.sigma_a_max = hinge.sigma_a - hinge.sigma_bending;
    hinge.tau_torsion = (hinge.m_z)*(hinge.diameter/2)/((pi/2)*(hinge.diameter/2)^4);

    hinge.von_mises = sqrt(hinge.sigma_a_max^2 + 3*(hinge.tau_torsion+hinge.tau)^2);
    hinge_SF = al6061.yield/hinge.von_mises;

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
    frontplate_SF = hdpe.yield/frontplate.von_mises;
end