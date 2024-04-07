function [adjustment_SF] = compute_adjustment_SF (components, user, al6061)
    adjustment = components.adjustment;
    backplate = components.backplate;

    %load comes from donning and doffing, assumign someone applies 200N of
    %force separating the back plates
    adjustment.load = 2*user.weight*9.81; % Func. of user weight, assumes they press with their full body weight %
    adjustment.moment = adjustment.load*(adjustment.thickness/2 + backplate.thickness/2);
    adjustment.sigma_bending = adjustment.moment * (adjustment.thickness/2) / (adjustment.height*adjustment.thickness^3/12);
    adjustment.sigma_axial = adjustment.load/adjustment.thickness*adjustment.height;
    adjustment.sigma_a_max = adjustment.sigma_bending+adjustment.sigma_axial;
    adjustment_SF = al6061.yield / adjustment.sigma_a_max;
end