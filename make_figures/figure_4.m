% Figure 4

% Generate cumulative frequency and box plots for each fan

addpath('../');
addpath('../scripts/');

fans = {g10_data, g8_data, t1_data};

fannames = fieldnames(distance_sorted);

X = 42.0;                  %# A3 paper size
Y = 29.7;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 2;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

f = figure('Menubar','none');
set(f, 'Position', [0,0, 1200, 800])
set(f, 'PaperSize',[X Y]);
set(f, 'PaperPosition',[0 yMargin xSize ySize])
set(f, 'PaperUnits','centimeters');

meta;
bigval = nan(5e5,1);

for fn=1:length(fannames)
    cf = distance_sorted.(fannames{fn});
    current_fan_data = fans{fn};
    s_names = fieldnames(cf);
    subplot(2,3,fn);
    surface_wolmans = [];
    surface_d84s = [];
    
    for sn=1:length(s_names)

        h = title([fannames{fn} ' - Surface ' s_names{sn}]);
        surface_data = current_fan_data{sn};
        surface = cf.(s_names{sn});
        
        surface_d84s = [surface_d84s,prctile(cell2mat(surface(:,2)), 84)];
        
        surface_wolman = cell2mat(surface(:,2));
        surface_wolman(isnan(surface_wolman)) = [];
        dif = length(bigval) - length(surface_wolman);
        pad = nan(dif,1);
        surface_wolman = [surface_wolman;pad];
        surface_wolmans = [surface_wolmans,surface_wolman];
        
        age = ages.(fannames{fn}).(s_names{sn});
        if (strcmp(age, 'Pleistocene')) < 1
           color = warm_colours(20, :);
           t = 0;
        else
           color = cold_colours(30, :);
           t = 1;
        end
        len = length(surface(:,1));
        for k=1:len
            h = cdfplot(surface{k,2}); 
            set(h,'Color',color)
            hold on;
            if t
               last_pleistocene = h;
            else
               last_holocene = h; 
            end
        end
        set(h.Parent, 'xlim', [0 250]);
        set(gca,'FontSize', 12);
    end
    title(fannames{fn});
    xlabel('Grain size');
    d84_line = plot([0,300], [.84,.84], 'k--');
    d50_line = plot([0,300], [.5, .5], 'b:');
    
    subplot(2,3,fn+3);

    boxplot(surface_wolmans, 'DataLim', [0 201], 'ExtremeMode', 'clip', 'symbol', '','Labels', s_names);
    hold on;
    sd = plot(surface_d84s, 'kx-');
    xlabel('Surfaces');
    ylabel('Grain size (mm)');
    ylim([-5 200]);
    set(gca,'xtick',1:length(s_names), 'xticklabel',s_names)
    legend(sd, 'D84')
    title(fannames{fn});
    set(gca,'FontSize', 12);
end
% subplot(1,3,3);
% plot([] , []);
% textLoc('Comparison of Wolman vs. Photogrammetry', 'center');

legend([last_holocene, last_pleistocene, d84_line, d50_line], {'Holocene', 'Late-Pleistocene', 'D84', 'D50'}, 'Location', 'southeast');
set(gca,'FontSize', 12);

print(f, '-dpdf', ['../pdfs/' 'figure_4.pdf'])
%print(f, '-depsc', ['../pdfs/figure_4' '.eps'])
