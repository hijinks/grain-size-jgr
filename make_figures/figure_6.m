% Figure 6

% Plot per fan per surface self similarity curves

Y = 21.9;                  %# A3 paper size
X = 27.0;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)


export = 0;
fan_names = {'G8', 'G10', 'T1'};
fan_data = {g8_data, g10_data, t1_data};
f1 = figure('Menubar','none');
set(f1, 'Position', [0,0, 1200, 800])
set(f1, 'PaperSize',[X Y]);
set(f1, 'PaperPosition',[0 yMargin xSize ySize])
set(f1, 'PaperUnits','centimeters');

sub_coords = [1 2 3; 4 5 6; 7 8 9; 10 11 12; 13 14 15];

legend_items = {};

for u=1:length(fan_names)
    
    current_fan = fan_data{u};
    current_fan_name = fan_names{u};
    
    col = u;
    
    all_wolman = [];
    all_ss = [];
    
    for w=1:length(current_fan)
        
        surface_data = current_fan{w};
        
        surface_name = [current_fan_name ' ' surface_data.name];
        legend_items = [legend_items, surface_name];
        
        surface_ss = cell2mat(surface_data.ss');
        surface_wolman = cell2mat(surface_data.wolmans');
        
        subplot(2,2,1);
        cdfplot(surface_wolman);
        hold on;

        subplot(2,2,2);
        cdfplot(surface_ss);
        hold on;  
        
        all_ss = [all_ss; surface_ss];
        all_wolman = [all_wolman; surface_wolman];
    end
    
    subplot(2,2,3);
    cdfplot(all_wolman);
    xlim([0 300]);
    hold on;
    
    subplot(2,2,4);
    cdfplot(all_ss);
    xlim([-5 5]);
    hold on;  
end

subplot(2,2,1);
legend(legend_items);
title('Grain Size CDF - Surfaces');
xlim([0 300]);
xlabel('mm');
hold on;

subplot(2,2,2);
legend(legend_items);
title('\xi CDF - Surfaces');
xlim([-5 5]);
xlabel('\xi');
hold on;  
        
subplot(2,2,3);
legend(fan_names);
title('Grain Size CDF - Fans');
xlabel('mm');

subplot(2,2,4);
legend(fan_names);
title('\xi CDF - Fans');
xlabel('\xi');

print(f1, '-dpdf', ['../pdfs/figure_6.pdf']);

