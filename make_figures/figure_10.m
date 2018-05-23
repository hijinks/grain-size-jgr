% Figure 10

% Relative mobility plots

Y = 20.0;                  %# A3 paper size
X = 34.0;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

csv_dir = ['.' filesep '..' filesep 'jfits'];

dir_search = subdir(csv_dir);

surfaces = [];
ag = nan(length(dir_search),1);
bg = nan(length(dir_search),1);
cg = nan(length(dir_search),1);
C1 = nan(length(dir_search),1);
C2 = nan(length(dir_search),1);
CV = nan(length(dir_search),1);
row_names = cell(length(dir_search),1);
fan_names = {'G8', 'G10', 'T1'};
fans = {g8_data, g10_data, t1_data};

fan_surface_data = struct();
fan_wolmans = struct('G8', struct('H', [], 'P', []), 'G10', struct('H', [], 'P', []), 'T1', struct('H', [], 'P', []));

for o=1:length(fan_names);
    fdat = fans{o};
    sdat = struct();
    
    for k=1:length(fdat)
        sdat.(fdat{k}.name) = fdat{k};
        age = ages.(fan_names{o}).(['Surface_' fdat{k}.name]);
        surf_dist_dat = distance_sorted.(fan_names{o}).(['Surface_' fdat{k}.name]);
        wol = cell2mat(surf_dist_dat(:,2));
        if (strcmp(age, 'Pleistocene')) < 1
           fan_wolmans.(fan_names{o}).H = [fan_wolmans.(fan_names{o}).H; wol];
        else
           fan_wolmans.(fan_names{o}).P = [fan_wolmans.(fan_names{o}).P; wol];
        end
    end
    
    fan_surface_data.(fan_names{o}) = sdat;
    fan_wolmans.(fan_names{o}).H(isnan(fan_wolmans.(fan_names{o}).H))= [];
    fan_wolmans.(fan_names{o}).P(isnan(fan_wolmans.(fan_names{o}).P))= [];
end



fnames = {};
fan_categories = {};
surfaces = {};

f1 = figure();
%set(f1, 'Position', [0,0, 1200, 800])
set(f1, 'PaperSize',[X Y]);
set(f1, 'PaperPosition',[0 yMargin xSize ySize])
set(f1, 'PaperUnits','centimeters');
% set(f1, 'Visible', 'off');

ss_cumul = [];
gs_cumul = [];
J_values = {};
gs_predictions = {};
subplotNumbers = struct('G8', [1 2], 'G10', [3 4], 'T1', [5 6]);

fit_ss = [];
fit_fraction = [];

ha = tight_subplot(3, 2, [.02 .01], [.1 .05], [.15 .05]);
plot_titles = {};

J_1 = struct('G8', struct('Surface_A', 0, 'Surface_B', 0, 'Surface_C', 0, 'Surface_D', 0), ...
    'G10', struct('Surface_A', 0, 'Surface_B', 0, 'Surface_C', 0, 'Surface_D', 0),...
    'T1', struct('Surface_A', 0, 'Surface_C', 0, 'Surface_E', 0));
gs_ranges = struct();

gs_fits = struct('G8', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'G10', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'T1', struct('A', 0, 'C', 0, 'E', 0));
CVs = struct('G8', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'G10', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'T1', struct('A', 0, 'C', 0, 'E', 0));

stdev_s = struct('G8', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'G10', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'T1', struct('A', 0, 'C', 0, 'E', 0));
means_s = struct('G8', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'G10', struct('A', 0, 'B', 0, 'C', 0, 'D', 0), 'T1', struct('A', 0, 'C', 0, 'E', 0));

vert_position1 = [1,2,3];
vert_position2 = [4,5,6];

upper_bounds = nan(length(dir_search),2);
lower_bounds = nan(length(dir_search),2);

for j=1:(length(dir_search)),
    [pathstr,fname,ext] = fileparts(dir_search(j).name);
    if strcmp(ext,'.csv') > 0
        row_names{j} = fname;
        fnames{j} = fname;
        if isempty(fname) < 1

            d = strsplit(fname, '_');
            fan_categories = [fan_categories, fname];
            surfaces = [surfaces, d{2}];
            surface_data = fan_surface_data.(d{1}).(d{2});
            delimiter = ',';
            startRow = 2;

            formatSpec = '%f%f%f%f%f%f%f%f%f%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

            %% Open the text file.
            fileID = fopen(dir_search(j).name,'r');

            textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

            fclose(fileID);
            spp = subplotNumbers.(d{1});
            

            
             J1 = dataArray{:, 1};
        %     Jprime1 = dataArray{:, 2};
        %     phi1 = dataArray{:, 3};
        %     sym1 = dataArray{:, 4};
        %     sigma2 = dataArray{:, 5};
        %     expsym1 = dataArray{:, 6};
        %     intsysmeps1 = dataArray{:, 7};
             fraction1 = dataArray{:, 8};
             ss_var1 = dataArray{:, 9};
        %     int_constant_ana1 = dataArray{:, 10};
             ag1 = dataArray{:, 13};
             bg1 = dataArray{:, 14};
             cg1 = dataArray{:, 15};
             means = dataArray{:, 16};
             stdev = dataArray{:, 17};
             CV = dataArray{1, 22};
             CV = str2num(CV{1});
             upper = dataArray{:, 23};
             upper_bounds(j,:) = [str2double(upper{1}),str2double(upper{2})];
            
             lower = dataArray{:, 24};
             lower_bounds(j,:) = [str2double(lower{1}),str2double(lower{2})];
             
             a_range = str2double(dataArray{:, 25});
             b_range = str2double(dataArray{:, 26});
             
            a = str2num(ag1{1});
            b = str2num(bg1{1});
            c = str2num(cg1{1});

            
            stdev = surface_data.stdev;
            means = surface_data.mean;
            
            m_stdev = mean(stdev);
            m_mean = mean(means);          
            J_vals = c:.005:3;
            [ss_vals] = ss_range(a_range, b_range);
            ss_vars = -log((J_vals-c)/a)/b;
            ss_1 = -log((1-c)/a)/b;
            ss_transport = -log((1.5-c)/a)/b;
            ss_substrate = -log((.5-c)/a)/b;

            
            % Remove trailing zeros

            gs_predict = (ss_vars.*mean(stdev))+mean(means);
            Infindexes = find(isinf(gs_predict));
            gs_predict(Infindexes) = [];
            ss_vars(Infindexes) = [];
            
            Jtypes = fieldnames(ss_vals);
            
            f=fit(ss_vars',gs_predict','poly1');
            gs_predictions = [gs_predictions, gs_predict'];                

            gs_1 = f.p1*ss_1+f.p2;
            gs_transport = f.p1*ss_transport+f.p2;
            gs_substrate = f.p1*ss_substrate+f.p2;
            
            gs_J_predictions = struct();
            for o=1:numel(Jtypes)
                
                ssv = ss_vals.(Jtypes{o});
                
                gs_upper = f.p1*ssv(1)+f.p2;
                gs_lower = f.p1*ssv(2)+f.p2;

                gs_J_predictions.(Jtypes{o}) = [gs_upper, gs_lower];

            end
            
            J_1.(d{1}).(['Surface_' d{2}]) = gs_1;
            J_transport.(d{1}).(['Surface_' d{2}]) = gs_transport;
            J_substrate.(d{1}).(['Surface_' d{2}]) = gs_substrate;
            gs_ranges.(d{1}).(['Surface_' d{2}]) = gs_J_predictions;
            J_1_upper.(d{1}).(['Surface_' d{2}]) = gs_upper;
            J_1_lower.(d{1}).(['Surface_' d{2}]) = gs_lower;
            CVs.(d{1}).(['Surface_' d{2}]) = CV;
            means_s.(d{1}).(['Surface_' d{2}]) = mean(means);
            stdev_s.(d{1}).(['Surface_' d{2}]) = mean(stdev);
            gs_fits.(d{1}).(['Surface_' d{2}]) = mean(stdev);

            ss_cumul = [ss_cumul; ss_vars'];
            gs_cumul = [gs_cumul; gs_predict'];
            gs_predictions = [gs_predictions, gs_predict'];
            J_values = [J_values, J_vals'];
            fit_fraction = [fit_fraction,fraction1];
            fit_ss = [fit_ss, ss_var1];
            
        end
    end
end

% Prep fan data
color_map = [[0 0.4980 0]; [0.8706 0.4902 0]; [0.8 0 0]; [0.2039 0.3020 0.4941]; [1 0 1]; [0 0 0]];
line_styles = {'-','-k','-g','-r','-b','-c'};
point_styles = {'xm','xk','xg','xr','xb','xc'};
line_point_styles = {'x-','xk-','xg-','xr-','xb-','xc-'};
% Downstream fining plots
fannames = {'G8', 'G10', 'T1'};

fans = {g8_data, g10_data, t1_data};

fannames = fieldnames(distance_sorted);

plot_i = 0;

p_means = struct('G8', [], 'G10', [], 'T1', []);
h_means = struct('G8', [], 'G10', [], 'T1', []);
p_equal_mobile = struct('G8', [], 'G10', [], 'T1', []);
h_equal_mobile = struct('G8', [], 'G10', [], 'T1', []);

for fn=1:length(fannames)

    cf = distance_sorted.(fannames{fn});
    s_names = fieldnames(cf);
    surface_names = s_names;
    legend_items = {};
    legend_labels = [];
    surface_wolmans = [];
    surface_d84s = [];
    surface_d50s = [];
    J_values = [];
    J_transport_values = [];
    J_substrate_values = [];
    J1_pos = [];
    J1_neg = [];
    Jtran_pos = [];
    Jtran_neg = [];
    Jsubs_pos = [];
    Jsubs_neg = [];
    CV_values = [];
    stdev_values = [];
    means_values = [];
    J_labels = s_names;
    
    for sn=1:length(s_names)
        surface = cf.(s_names{sn});
        bigval = nan(5e5,1);
        surface_d84s = [surface_d84s,prctile(cell2mat(surface(:,2)), 84)];
        surface_d50s = [surface_d50s,prctile(cell2mat(surface(:,2)), 84)];
%         sdat = surface(:,2);
%         sdat(isnan(sdat)) = [];
%         d84 = prctile((sdat), 84);
%         d50 = prctile((sdat), 50);
%         average_gs = mean(sdat);
        
        
        surface_wolman_all = cell2mat(surface(:,2));
        surface_wolman = cell2mat(surface(:,2));
        surface_wolman(isnan(surface_wolman)) = [];
        dif = length(bigval) - length(surface_wolman);
        pad = nan(dif,1);
        surface_wolman = [surface_wolman;pad];
        surface_wolmans = [surface_wolmans,surface_wolman];
        len = length(surface(:,1));
        distances = cell2mat(surface(:,1));
        max_dist = max(distances);
        norm_dist = distances./max_dist;
        wolmans = cell2mat(surface(:,2)');
        d84s = zeros(1,len);
        errors = zeros(1,len);
        
        J1_v = J_1.(fannames{fn}).(s_names{sn});
        Jtran_v = J_transport.(fannames{fn}).(s_names{sn}); 
        Jsubs_v = J_substrate.(fannames{fn}).(s_names{sn});
        
        J_values = [J_values; J1_v];
        J_transport_values = [J_transport_values; Jtran_v];
        J_substrate_values = [J_substrate_values; Jsubs_v];
        
        gs_range = gs_ranges.(fannames{fn}).(s_names{sn});
        
        J1_range = gs_range.J1;
        Jtran_range = gs_range.Jtransport;
        Jsubs_range = gs_range.Jsubstrate;
        
        J1_pos = [J1_pos; (J1_range(1)-J1_v)];
        J1_neg = [J1_neg; (J1_v-J1_range(2))];
        
        Jtran_pos = [Jtran_pos; (Jtran_range(1)-Jtran_v)];
        Jtran_neg = [Jtran_neg; (Jtran_v-Jtran_range(2))];
        
        Jsubs_pos = [Jsubs_pos; (Jsubs_range(1)-Jsubs_v)];
        Jsubs_neg = [Jsubs_neg; (Jsubs_v-Jsubs_range(2))];
        
        CV_values = [CV_values; CVs.(fannames{fn}).(s_names{sn})];
        stdev_values = [stdev_values; stdev_s.(fannames{fn}).(s_names{sn})];
        means_values = [means_values; means_s.(fannames{fn}).(s_names{sn})];
        age = ages.(fannames{fn}).(s_names{sn});

        if (strcmp(age, 'Pleistocene')) < 1
           h_means.(fannames{fn}) = [h_means.(fannames{fn}); means_s.(fannames{fn}).(s_names{sn})];
           h_equal_mobile.(fannames{fn}) = [h_equal_mobile.(fannames{fn});J1_v];
        else
           p_means.(fannames{fn}) = [p_means.(fannames{fn}); means_s.(fannames{fn}).(s_names{sn})];
           p_equal_mobile.(fannames{fn}) = [p_equal_mobile.(fannames{fn});J1_v];
        end
%         surface_d84s = [surface_d84s; d84];
%         surface_d50s = [surface_d50s; d50];
    end
    left_color = [0 0 0];
    right_color = [.6 .6 .6];
    
    subplot(2,3,vert_position1(fn));
    ax = gca;
    %yyaxis left
    
%    jsub = plot(1:1:length(s_names), J_substrate_values, '-*');
%    hold on;
%    errorbar(1:1:length(s_names),J_substrate_values, Jsubs_pos, Jsubs_neg);
    
    hold on;
    %%yyaxis left
    j1 = plot(1:1:length(s_names), J_values, '-kx');
    hold on;
    errorbar(1:1:length(s_names),J_values, J1_pos, J1_neg, 'Color', 'k');
   %% ax.YColor = left_color;
%     hold on;
%     yyaxis left 
%     jtransport = plot(1:1:length(s_names), J_transport_values, '-o');
%     hold on;
%     errorbar(1:1:length(s_names),J_transport_values, Jtran_pos, Jtran_neg);

    ylabel('Grain size (mm)');
      hold on;
     mean_plot = plot(1:1:length(s_names),means_values, '--d', 'Color', left_color);
     ylim([0, 70]);
     ax.YColor = left_color;
     
    %%yyaxis right
     hold on;
     %cv_plot = plot(CV_values, '-o', 'Color', right_color);
     %%ylim([.5, 1]);
     %ylabel('Cv');
     end_v = length(s_names)+.5;
     xlim([.5, end_v]);
     set(gca,'xtick',1:length(s_names), 'xticklabel',s_names)
     title([fannames{fn}])
     xlabel('Surfaces');
    %% ax.YColor = right_color;
    
    
     subplot(2,3,vert_position2(fn));
     [fh,x] = ecdf(fan_wolmans.(fannames{fn}).H);
     [fp,x] = ecdf(fan_wolmans.(fannames{fn}).P);
     average_h_j = round(max(h_equal_mobile.(fannames{fn})));
     average_p_j = round(max(p_equal_mobile.(fannames{fn})));
     h1 = fh(average_h_j)
     p1 = fp(average_p_j)
     cdfplot(fan_wolmans.(fannames{fn}).H);
     hold on;
     plot([0 average_h_j average_h_j], [h1 h1 0]);
     hold on;
     plot([0 average_p_j average_p_j], [p1 p1 0]);
     hold on;
     cdfplot(fan_wolmans.(fannames{fn}).P);
     xlim([0, 300]);
%     
%     legend([jsub, j1, jtransport, mean_plot, cv_plot], 'J = 1.5 (Substrate)','J = 1 (Largest mobile clast)', ...
%       'J = 0.5 (Transport)', 'Mean grain size',...
%      'Coefficient of Variation (Cv)',    

end
%subplot(1,4,4);
      %legend([j1, mean_plot, cv_plot], 'J = 1 (Largest mobile clast)', ...
      %  'Mean grain size',...
      % 'Coefficient of Variation (Cv)','Location','EastOutside')   
print(f1, '-dpdf', ['../pdfs/figure_10' '.pdf'])
%print(f1, '-depsc', ['../pdfs/figure_10' '.eps'])