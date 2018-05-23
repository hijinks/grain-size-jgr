% Surface_Colormaps and fan datum coordinates

clrs = struct();
ages = struct();

% Holocene palette
warm_colours = colormap(hot);

% Pleistocene palette
cold_colours = colormap(bone);
cold_colours2 = colormap(winter);

clrs.G10 = struct();
clrs.G8 = struct();
clrs.T1 = struct();
clrs.SR1 = struct();

l = 6;
d = floor(64/l);
clrs.G10.Surface_A = warm_colours(1*d, :);
clrs.G10.Surface_B = warm_colours(2*d, :);
clrs.G10.Surface_C = cold_colours2(1*d, :);
clrs.G10.Surface_D = cold_colours2(2*d, :);
clrs.G10.Surface_E = cold_colours(.5*d, :);
clrs.G10.F = cold_colours(4*d, :);

l = 4;
d = floor(64/l);
clrs.G8.Surface_A = warm_colours(1*d, :);
clrs.G8.Surface_B = warm_colours(2*d, :);
clrs.G8.Surface_C = cold_colours2(1*d, :);
clrs.G8.Surface_D = cold_colours2(2*d, :);

l = 4;
d = floor(64/l);
clrs.T1.Surface_A = warm_colours(1*d, :);
clrs.T1.Surface_C = cold_colours2(1*d, :);
clrs.T1.Surface_E = cold_colours(.5*d, :);

l = 4;
d = floor(64/l);

ages.G10.Surface_A = 'Holocene   ';
ages.G10.Surface_B = 'Holocene   ';
ages.G10.Surface_C = 'Pleistocene';
ages.G10.Surface_D = 'Pleistocene';
ages.G10.Surface_E = 'Pleistocene';
ages.G10.Surface_F = 'Pleistocene';

ages.G8.Surface_A = 'Holocene   ';
ages.G8.Surface_B = 'Holocene   ';
ages.G8.Surface_C = 'Pleistocene';
ages.G8.Surface_D = 'Pleistocene';

ages.T1.Surface_A = 'Holocene   ';
ages.T1.Surface_C = 'Pleistocene';
ages.T1.Surface_E = 'Pleistocene';

symbols.G10.Surface_A = '^';
symbols.G10.Surface_B = '+';
symbols.G10.Surface_C = 's';
symbols.G10.Surface_D = 'x';
symbols.G10.Surface_E = 'd';
symbols.G10.Surface_F = 'o';

symbols.G8.Surface_A = '^';
symbols.G8.Surface_B = '+';
symbols.G8.Surface_C = 's';
symbols.G8.Surface_D = 'x';

symbols.T1.Surface_A = '^';
symbols.T1.Surface_C = 's';
symbols.T1.Surface_E = 'd';


origins = struct('G10',[36.7765850388, -117.1271739900], ...
    'G8', [36.77300833333333, -117.11081944444445], ...
    'T1',[36.57948, -117.103]);