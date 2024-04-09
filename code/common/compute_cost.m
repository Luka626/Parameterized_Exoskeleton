% compute cost of a given configuration %
function [weighted_average_cost] = compute_cost (safety_factors, weights)
arguments
    safety_factors struct
    weights = ones([1, numel(fieldnames(safety_factors))]) % initialize 0 weights unless specified %
end
    ordered_sf = orderfields(safety_factors);
    GOAL_SF = 2.5;
    components = fieldnames(ordered_sf);
    total_cost = 0;
    for comp_index=1:numel(components)
        sf = ordered_sf.(components{comp_index});
        value = ((sf - GOAL_SF) * weights(comp_index))^2;

        % penalize any safety factors below requirment %
        if (sf - GOAL_SF) < 0
            value = value * (50^2);
        end

        total_cost = total_cost + value;
    end
    weighted_average_cost = total_cost / numel(components);
end