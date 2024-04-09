% logs each field, value pair of "dimensions" in a log file "path"%
function [] = log_dimensions (path, dimensions, append)
arguments
    path string
    dimensions struct
    append  logical = false
end
    if append
        log_file = fopen(path, 'a');
    else
        log_file = fopen(path, 'w');
    end
    
    global_variables = fieldnames(dimensions);
    for var_index=1:length(global_variables)
        fprintf(log_file, '"%6s"=%4.8f\n', global_variables{var_index}, dimensions.(global_variables{var_index}));
    end
    fclose(log_file);
end