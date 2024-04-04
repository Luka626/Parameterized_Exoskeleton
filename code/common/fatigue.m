function [SF] = fatigue(stresses, material_data, axialLoading, C)
arguments
    stresses (1,2) {mustBeNumeric} % min(1) and max(2)
    material_data (1,1) struct
    axialLoading (1,1) logical = false
    C.s (1,1) double {mustBeNumeric} = 0.9 % machined
    C.t (1,1) double {mustBeNumeric} = 1.0
    C.r (1,1) double {mustBeNumeric} = 0.868 % 95% reliability
    C.l (1,1) double {mustBeNumeric} = 1.0
    C.g (1,1) double {mustBeNumeric} = 1.0 % assume bending
    C.g_axial (1,1) double {mustBeNumeric} = 0.9 % use this is axial
end

if axialLoading
    C.g = C.g_axial;
end

stress_max = stresses(2);
stress_min = stresses(1);
uts = material_data.ultimate;

stress_mean = (stress_max + stress_min)/2;
stress_alt =  stress_max - stress_min;



S_n_prime = 0.5*uts;
S_n = S_n_prime*C.l*C.g*C.s*C.t*C.r;

SF = S_n/stress_alt + uts/stress_mean;

end
