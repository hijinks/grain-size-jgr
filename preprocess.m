% Grain size analysis scripts to processes raw data, generate stats and
% process the 

addpath('./scripts');
addpath('./lib');

root_dir = './2015_data';

% Grapevine fans G10 and G8
% Grotto Canyon fan (T1)

g10_data = fan_data(root_dir, 'G10',[36.7765850388, -117.1271739900], 'coordinates/G10_coords.csv');
g8_data = fan_data(root_dir, 'G8',[36.77300833333333, -117.11081944444445], 'coordinates/G8_coords.csv');
t1_data = fan_data(root_dir, 'T1', [36.57948, -117.103], 'coordinates/T1_coords.csv');


fan_names = {'G10', 'G8', 'T1'};
fans = {g10_data, g8_data, t1_data};

[distance_sorted] = surface_stats(fan_names, fans);
