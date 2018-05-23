% Convert absolute fan apex distances into a relative distance

function [apex_distance, relative_distances] = fan_apex_relative(sites, apex_location, origin_location)

    [ox, oy, utm] = wgs2utm(origin_location(1),  origin_location(2));
    relative_distances = zeros(length(sites), 1);
    distances = zeros(length(sites), 1);

    ix = apex_location(1);
    iy = apex_location(2);
    apex_distance = sqrt((ix-ox)^2+(iy-oy)^2);

    for d=1:length(distances)
        x1 = sites(d,1);
        y1 = sites(d,2);
        distances(d) = sqrt((x1-ox)^2+(y1-oy)^2);
        relative_distances(d) = sqrt((x1-ix)^2+(y1-iy)^2);
    end

    k = find(distances<apex_distance);
    relative_distances(k) = relative_distances(k)*-1;

end

