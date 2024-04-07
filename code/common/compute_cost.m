% compute cost of a given configuration %
function [weighted_average_cost] = compute_cost (safety_factors, weights)
arguments
    safety_factors struct
    weights = ones([1, numel(fieldnames(safety_factors))]) % initialize 0 weights unless specified %
end

    GOAL_SF = 2.5;
    components = fieldnames(safety_factors);
    total_cost = 0;
    for comp_index=1:numel(components)
        sf = safety_factors.(components{comp_index});
        value = sf - GOAL_SF * weights(comp_index);

        % penalize any safety factors below requirment %
        if value < 0
            value = value * 20;
        end

        total_cost = total_cost + abs(value);
    end
    weighted_average_cost = total_cost / numel(components);
end