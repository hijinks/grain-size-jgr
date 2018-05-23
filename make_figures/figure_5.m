% Figure 5

% Downstream change in grain size for each fan surface with corresponding
% downstream change in coefficient of variation

Y = 21.0;                  %# A3 paper size
X = 29.7;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)
f = figure('Menubar','none');
set(f, 'Position', [0,0, 1200, 800])
set(f, 'PaperSize',[X Y]);
set(f, 'PaperPosition',[0 yMargin xSize ySize])
set(f, 'PaperUnits','centimeters');
%set(f, 'Visible', 'off');

meta;
[apex_data] = fan_apexes;

% Downstream fining plots
fannames = {'G8', 'G10', 'T1'};

fans = {g8_data, g10_data, t1_data};


fannames = fieldnames(distance_sorted);

plot_i = 0;
for fn=1:length(fannames)
    fan_name = fannames{fn};
    cf = distance_sorted.(fannames{fn});
    s_names = fieldnames(cf);
    surface_names = s_names;
    legend_items = [];
    legend_labels = {};
    surface_wolmans = [];
    surface_d84s = [];
    
    
    plot_i = plot_i +1;
    plot_ds = plot_i;
    plot_i = plot_i+1;
    plot_ss = plot_i;
    
    for sn=1:length(s_names)
        
        surface = cf.(s_names{sn});

        bigval = nan(5e5,1);
        surface_d84s = [surface_d84s,prctile(cell2mat(surface(:,2)), 84)];
        surface_wolman_all = cell2mat(surface(:,2));
        surface_wolman = cell2mat(surface(:,2));
        surface_wolman(isnan(surface_wolman)) = [];
        dif = length(bigval) - length(surface_wolman);
        pad = nan(dif,1);
        surface_wolman = [surface_wolman;pad];
        surface_wolmans = [surface_wolmans,surface_wolman];
        len = length(surface(:,1));
        distances = cell2mat(surface(:,1));
        sites = cell2mat(surface(:,3));

        [apex_distance, relative_distances] = fan_apex_relative(sites, ...
            apex_data.(fan_name), origins.(fan_name)); 

        wolmans = cell2mat(surface(:,2)');
        d84s = zeros(1,len);
        errors = zeros(1,len);
        cv= zeros(1, len);
        
        for j=1:len
            d84s(1,j) = prctile(wolmans(:,j), 84);
            errors(1,j) = (prctile(wolmans(:,j), 90)-prctile(wolmans(:,j), 80))/2;
            wm = wolmans(:,j);
            wm(isnan(wm)) = [];
            cv(1,j) = std(wm)/mean(wm);
        end
        
        
        subplot(3,2, plot_ds);
        
        d = plot(relative_distances, d84s, ['-' symbols.(fannames{fn}).(s_names{sn})], 'Color', clrs.(fannames{fn}).(s_names{sn}));
        %d = boundedline(relative_distances, d84s, errors, ['-' symbols.(fannames{fn}).(s_names{sn})], 'alpha', 'cmap', clrs.(fannames{fn}).(s_names{sn}));
        ylim([0,150]);
        
        if strcmp(fan_name, 'G10') > 0
            xlim([-1000,1500]);
        else
            xlim([-1000,2500]);
        end
        
        xlabel('Downstream distance (m)');
        ylabel('Grain size (mm)');
        set(gca, 'FontSize', 12)
        hold on;
        legend_labels = [legend_labels surface_names{sn}];
        legend_items = [legend_items,d];
        subplot(3,2, plot_ss);
        ss = plot(relative_distances, cv,  symbols.(fannames{fn}).(s_names{sn}), 'Color', clrs.(fannames{fn}).(s_names{sn}));
        set(gca, 'FontSize', 12)
        hold on;
    end
    
    subplot(3,2, plot_ds);
    text(0+30, 30, '- Fan apex');
    %textLoc('Bounds: D80-D90', 'southeast');
    legend(legend_items,char(legend_labels));
    textLoc(['\bf', fannames{fn}, ' - D84'], 'northwest', 'FontSize', 12);
    plot([0,0], [-10,200], 'k--');
    subplot(3,2, plot_ss);
    ylim([0,1.2]);
    
    if strcmp(fan_name, 'G10') > 0
        xlim([-1000,1500]);
    else
        xlim([-1000,2500]);
    end
        
    plot([0,0], [-1,3], 'k--');
    text(0+30, .2, '- Fan apex');
    set(gca, 'FontSize', 12)
    hold on;
    %legend(legend_labels, 'Location', 'southeast');
    textLoc(['\bf', fannames{fn}, ' - CV'], 'northwest', 'FontSize', 12);
    xlabel('Downstream distance (m)');
    ylabel('Cv');    
    set(gca, 'FontSize', 12)
end

print(f, '-dpdf', ['../pdfs/figure_5' '.pdf'])
%print(f, '-depsc', ['../pdfs/figure_5' '.eps'])
