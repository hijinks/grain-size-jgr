% Self similarity curves for each fan with non-linear regressions

addpath('../j-tools/J_functions');

X = 29.7;                  %# A3 paper size
Y = 21.0;                  %# A3 paper size               
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

csv_dir = ['.' filesep '..', filesep, 'jfits'];

dir_search = subdir(csv_dir);

surfaces = [];
ag = nan(length(dir_search),1);
bg = nan(length(dir_search),1);
cg = nan(length(dir_search),1);
C1 = nan(length(dir_search),1);
C2 = nan(length(dir_search),1);
CV = nan(length(dir_search),1);
row_names = cell(length(dir_search),1);
fnames = {};
fan_categories = {};
surfaces = {};
f = figure('Menubar','none');
set(f, 'Position', [0,0, 1200, 800])
set(f, 'PaperSize',[X Y]);
set(f, 'PaperPosition',[0 yMargin xSize ySize])
set(f, 'PaperUnits','centimeters');
set(f, 'Visible', 'off');

meta;

% fdata = struct('G8', struct('A', fans{1}{1}, 'B', fans{1}{2}, 'C', fans{1}{3}, ...
%     'D', fans{1}{4}), 'G10', struct('A', fans{2}{1}, 'B', fans{2}{2}, 'C', fans{2}{3}, ...
%     'D', fans{2}{4}), 'T1', struct('A', fans{3}{1}, 'C', fans{3}{2}, 'E', fans{3}{3}));

fdata = struct('G8', struct('A', fans{1}{1}, 'B', fans{1}{2}, 'C', fans{1}{3}, ...
    'D', fans{1}{4}), 'G10', struct('A', fans{2}{1}, 'B', fans{2}{2}, 'C', fans{2}{3}, ...
    'D', fans{2}{4}, 'E', fans{2}{5}), 'T1', struct('A', fans{3}{1}, 'C', fans{3}{2}, 'E', fans{3}{3}));

subplotNumbers = struct('G8', [1,4,7,10,13], 'G10', [2,5,8,11,14], 'T1', [3,9,15,15,15]);
ha = tight_subplot(5, 3, [.015 .015], [.05 .05], [.15 .05]);
fan_abc = struct('G8', struct(), 'G10', struct(), 'T1', struct());

nG10 = 0;
nG8 = 0;
nT1 = 0;

fan_legends = struct('G8', struct('items', 0, 'labels', 0), 'G10', struct('items', 0, 'labels', 0), 'T1', struct('items', 0, 'labels', 0));

all_fits = [];
all_a = [];
all_b = [];
all_c = [];

for j=1:(length(dir_search)),
    [pathstr,fname,ext] = fileparts(dir_search(j).name);
    if strcmp(ext,'.csv') > 0
        row_names{j} = fname;
        fnames{j} = fname;
        if isempty(fname) < 1

            d = strsplit(fname, '_');
            fan_categories = [fan_categories, fname];
            surfaces = [surfaces, d{2}];
            delimiter = ',';
            startRow = 2;
            surface_data = fdata.(d{1}).(d{2});
            formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';


            %% Open the text file.
            fileID = fopen(dir_search(j).name,'r');
            subplot_positions = subplotNumbers.(d{1});
            
            textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
            
            fclose(fileID);

            ss = surface_data.ss;
    
             J1 = dataArray{:, 1};
             model_fraction = str2double(dataArray{:, 8});
             ss_var1 = str2double(dataArray{:, 9});
             field_ss = str2double(dataArray{:, 18});
             field_fraction = str2double(dataArray{:, 19});
             C1 = str2double(dataArray{1, 20}{1});
             C2 = str2double(dataArray{1, 21}{1});
             a_range = str2double(dataArray{:, 25});
             b_range = str2double(dataArray{:, 26});
             c_range = str2double(dataArray{:, 27});
             %c_range = [0.1 0.1 0.1 0.1 0.1 0.1]
             
             
             model_fractions = zeros(length(ss_var1), 6);
             
             for k=1:6
                 
                 [J, Jprime, phi, sym, expsym, intsysmeps, sigma, ...
                     int_val,int_constant_ana, fraction] = ...
                     calcFraction([a_range(k), b_range(k), c_range(k)], ss_var1, C1, C2, 0.5);
                 
                 model_fractions(:,k) = fraction;
             end
             
            n1 = subplot_positions(1);
            if n1 == 1
                nG8 = nG8+1;
                axes(ha(subplot_positions(nG8)));
                pos = nG8;
                
            elseif n1 == 2
                    
                nG10 = nG10+1;
                axes(ha(subplot_positions(nG10)));
                pos = nG10;
                
            elseif n1 == 3
                nT1 = nT1+1;
                axes(ha(subplot_positions(nT1)));
                pos = nT1;
            end

            aglist = dataArray{1, 13};
            ag = str2double(aglist{1});

            bglist = dataArray{1, 14};
            bg = str2double(bglist{1});

            cglist = dataArray{1, 15};
            cg = str2double(cglist{1});
            
            %cg = 0.1;
            
            fan_abc.(d{1}).(d{2}) = [ag, bg, cg];
            all_a = [all_a; ag];
            all_b = [all_b; bg];
            
            ed = -5.5:.5:5.5;
            xp = [-5:.5:5.5];

            for k=1:6
               plot(ss_var1, model_fractions, 'Color', [.6,.6,.6])
               hold on;
            end
            
            pv = plot(field_ss, field_fraction, 'xb--');
            hold on;
            all_fits = [all_fits, model_fraction];
            mv = plot(ss_var1, model_fraction, 'k-', 'LineWidth', 2, 'Color', [0.1, 0.1, 0.1]);
            items = fan_legends.(d{1}).('items');
            labels = fan_legends.(d{1}).('labels');
            if iscell(labels) < 1
                labels = {};
            end
            
            
            items = [items, clrs.(d{1}).(['Surface_' d{2}])];
            labels = [labels, d{2}, ''];
            fan_legends.(d{1}).('items') = items;
            fan_legends.(d{1}).('labels') = labels;
            
            set(gca,'fontsize',8);
            xlim([-5,5]);
            ylim([0, .4]);
            if pos == 4
                xlabel('\xi');
            else
                set(gca,'XTicklabel',[]);
            end
            
            if n1 == 1
                ylabel('Frequency');
            else
                set(gca,'YTicklabels',[]);
            end
            
            hold on;


            clearvars filename delimiter startRow formatSpec fileID dataArray ans;
        end
    end
end
axes(ha(1))
title('\rmFan\bf G8');
s_names = fieldnames(fan_abc.('G8'));
abc_params = {};
plots = cell(1,length(s_names));
for u=1:length(s_names)
    axes(ha(subplotNumbers.G8(u)))
    abcs = fan_abc.('G8').(s_names{u});
    abc_params = ['\bf a\rm: ' num2str(sprintf('%.2f',abcs(1))) '\bf b\rm: ' num2str(sprintf('%.2f',abcs(2))) '\bf c\rm: ' num2str(sprintf('%.2f',abcs(3)))];
    textLoc(abc_params, 'northeast', 'FontSize', 8);
    textLoc(['\bf' s_names{u}], 'northwest');

end
axes(ha(2));
title('\rmFan \bfG10');
s_names = fieldnames(fan_abc.('G10'));
abc_params = {};

for u=1:length(s_names)
    axes(ha(subplotNumbers.G10(u)))
    abcs = fan_abc.('G10').(s_names{u});
    abc_params = ['\bf a\rm: ' num2str(sprintf('%.2f',abcs(1))) '\bf b\rm: ' num2str(sprintf('%.2f',abcs(2))) '\bf c\rm: ' num2str(sprintf('%.2f',abcs(3)))];
    textLoc(abc_params, 'northeast', 'FontSize', 8);
    textLoc(['\bf' s_names{u}], 'northwest');
end
axes(ha(3));
title('\rmFan \bfT1');
s_names = fieldnames(fan_abc.('T1'));
abc_params = {};
for u=1:length(s_names)
    axes(ha(subplotNumbers.T1(u)))
    abcs = fan_abc.('T1').(s_names{u});
    abc_params = ['\bf a\rm: ' num2str(sprintf('%.2f',abcs(1))) '\bf b\rm: ' num2str(sprintf('%.2f',abcs(2))) '\bf c\rm: ' num2str(sprintf('%.2f',abcs(3)))];
    textLoc(abc_params, 'northeast', 'FontSize', 8);
    textLoc(['\bf' s_names{u}], 'northwest');
end

% axes(ha(12));
% M = mean(all_fits,2)
% plot(ss_var1, M, 'k', 'LineWidth', 1);
% ylim([0 .5]);
% textLoc('Average Fit', 'northwest');
% set(gca,'YTicklabels',[]);
% xlabel('\xi');
% set(gca,'fontsize',8);
% xlim([-6,6]);
% abc_params = ['\bf a\rm: ' num2str(sprintf('%.2f',mean(all_a))) '\bf b\rm: ' num2str(sprintf('%.2f',mean(all_b))) '\bf c\rm: ' num2str(sprintf('%.2f',mean(all_c)))];
% textLoc(abc_params, 'northeast', 'FontSize', 8);
print(f, '-dpdf', ['../pdfs/figure_S5_1' '.pdf']);
%print(f, '-depsc', ['../pdfs/figure_S5_1' '.eps']);
