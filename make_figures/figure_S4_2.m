% Self-similar Grain size CDFs per surface

Y = 29.7;                  %# A3 paper size
X = 21.0;                  %# A3 paper size
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

for u=1:length(fan_names)
    
    current_fan = fan_data{u};
    current_fan_name = fan_names{u};
    
    col = u;
    
    for w=1:length(current_fan)

        surface_data = current_fan{w};
        ss = surface_data.ss;
        
        nc = sub_coords(w,col);
        xp = -5:.5:5;

        if export < 1
            %figure;
            subplot(5,3,nc);
        end
        
        sums_total = 0;
        bin_totals = zeros(1,length(xp)-1);
        all_y = [];
        
        for k=1:length(ss)
           cdfplot(ss{k});
           hold on;
        end
        
        xlim([-5 5]);
        
        if export < 1
           title([current_fan_name ' ' surface_data.name]);
        else
            [file,path] = uiputfile('*.csv', 'Save Charts', ...
                [current_fan_name '_' surface_data.name]);
            dlmwrite([path file],[xp(2:end)',all_y],'delimiter',',','precision',3)
        end
    end
end

print(f1, '-dpdf', ['../pdfs/figure_S4_2.pdf']);

