% recalculates masses, in case properties change %
function [backplate_mass, frontplate_mass, adjustment_mass, hinge_mass] = compute_masses (wrc, hdpe, al6061)
arguments
    wrc, hdpe, al6061 struct
end

    backplate = wrc.backplate;
    frontplate = wrc.frontplate;
    adjustment = wrc.adjustment;
    hinge = wrc.hinge;

    % BACK PLATE %
    backplate_volume = backplate.height * backplate.thickness * backplate.width;
    backplate_mass = backplate_volume * hdpe.density; %kg


    % FRONTPLATE %
    frontplate_volume = frontplate.height*frontplate.length*frontplate.thickness_total;
    frontplate_mass = frontplate_volume*hdpe.density;

    % ADJUSTMENT %
    adjustment_volume = adjustment.height*adjustment.length*adjustment.thickness;
    adjustment_mass = adjustment_volume*al6061.density;

    % HINGE %
    hinge.area = (pi/4)*hinge.diameter^2;
    hinge_volume = hinge.area*hinge.length;
    hinge_mass = hinge_volume*al6061.density;

end