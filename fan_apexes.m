% Load fan apex coordinates

function [apex_data] = fan_apexes

    filename = '../coordinates/fan_apexes.csv';
    delimiter = ',';
    startRow = 2;
    formatSpec = '%s%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);
    Name = dataArray{:, 1};
    Latitude = dataArray{:, 2};
    Longitude = dataArray{:, 3};
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    apex_data = struct();
    for p = 1:length(Name)
        [nx, ny, utm] = wgs2utm(Latitude(p), Longitude(p));
        apex_data.(strtrim(Name{p})) = [nx, ny];
    end
end