% Run relative mobility functions 

addpath('./scripts');
addpath('./j-tools');

csv_dir = ['.' filesep 'jfits'];

output_gs = distance_sorted;
output_stats = {g10_data, g8_data, t1_data};
fans = fan_names;

fan_data = output_stats;

Jprocess = struct();

previous_params = false;

% Run all surfaces? auto = 1;
auto = 1;

for u=1:length(fans)
    fan_surfaces = output_gs.(fans{u});
    current_fan = fan_data{u};
    surfaces_names = fieldnames(fan_surfaces);
    for w=1:length(surfaces_names)
        ds_surface = fan_surfaces.(surfaces_names{w});
        surface_data = current_fan{w};
        surface_name = [fans{u} '_' surface_data.name];
        %surface_data.C1 = s_C1.(fans{u}).(surfaces_names{w});
        %surface_data.C2 = s_C2.(fans{u}).(surfaces_names{w});
        if isstruct(previous_params)
            if isfield(previous_params,surface_name)
                Jprocess.(surface_name) = {ds_surface,surface_data, previous_params.(surface_name)};
            else
                Jprocess.(surface_name) = {ds_surface,surface_data};
            end
        else
            Jprocess.(surface_name) = {ds_surface,surface_data};
        end
    end
end

if auto > 0
    AutoJ(Jprocess);
else
    JtweakOptions(Jprocess);
end

