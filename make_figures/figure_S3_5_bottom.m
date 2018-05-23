% K-S tests for fans

addpath('lib');
% fannames = fieldnames(distance_sorted);

Y = 20.0;                  %# A3 paper size
X = 34.0;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)
f1 = figure('Menubar','none');
set(f1, 'Position', [0,0, 1200, 800])
set(f1, 'PaperSize',[X Y]);
set(f1, 'PaperPosition',[0 yMargin xSize ySize])
set(f1, 'PaperUnits','centimeters');


export = 0;
fan_names = {'G8', 'G10', 'T1'};
fan_data = {g8_data, g10_data, t1_data};
ks_percentage = 0.05;

% subplotNumbers = struct('G8', [1,4,7,10,13], 'G10', [2,5,8,11,14], 'T1', [3,9,15,15,15]);

total_percent = [];
fan_wolmans = {};
fan_sss = {};
    
for u=1:length(fan_names)
    
    current_fan = fan_data{u};
    current_fan_name = fan_names{u};
    
    current_fan_wolmans = [];
    current_fan_ss = [];
    
    for w=1:length(current_fan)
        
        surface_data = current_fan{w};
        ss = surface_data.ss;
        wol = surface_data.wolmans;
        
        current_fan_wolmans = [current_fan_wolmans; vertcat(ss{:})];
        current_fan_ss = [current_fan_ss; vertcat(wol{:})];
    end
    
    fan_sss = [fan_sss, vertcat(current_fan_wolmans)];
    fan_wolmans = [fan_wolmans, vertcat(current_fan_ss)];
        
end

prms = nchoosek(1:1:length(fan_names),2);
p_vals = [];
k_vals = [];
h_vals = [];
k_vals_ss = [];
h_vals_ss = [];
ktest_mat = zeros(length(fan_names), length(fan_names));
ktest_mat_ss = zeros(length(fan_names), length(fan_names));

for p=1:length(prms)
    t1 = fan_wolmans{prms(p,1)};
    t2 = fan_wolmans{prms(p,2)};
    t3 = fan_sss{prms(p,1)};
    t4 = fan_sss{prms(p,2)};
    [H,P, KSSTAT] = kstest2(t1, t2,'Alpha',ks_percentage);
    [H_ss,P_ss, KSSTAT_ss] = kstest2(t3, t4,'Alpha',ks_percentage);
    ktest_mat(prms(p,1),prms(p,2)) = H+1;
    ktest_mat_ss(prms(p,1),prms(p,2)) = H_ss+1;
    h_vals = [h_vals; H];
    k_vals = [k_vals; KSSTAT];
    h_vals_ss = [h_vals_ss; H_ss];
    k_vals_ss = [k_vals_ss; KSSTAT_ss];    
end

subplot(2,2,1);
k = tabulate(h_vals);
total_percent = [total_percent; k(1,3)];
ktest_mat = tril(ktest_mat, length(fan_wolmans))'+ktest_mat;
imagesc(flipud(ktest_mat));

cmap = jet(20);
cmap = flipud(cmap(1:10,:));

cmap(1,:) = [0 0 0];
cmap(2:end-1,:) = repmat([0 1 0], length(cmap(2:end-1,:)), 1);
cmap(end,:) = [1,1,1];
axis square;
caxis manual
caxis([0 2]);
colormap(cmap);
xx = get(gca, 'XLim');
yy = get(gca, 'YLim');
set(gca, 'XTickLabel', fan_names) % 10 ticks 
set(gca, 'YTickLabel', flip(fan_names)) % 20 ticks
set(gca,'XTick', (1:size(ktest_mat,2)))
set(gca,'YTick', (1:size(ktest_mat,1)))
set(gca,'TickLabelInterpreter','none')

if k(1,1) < 1
    textLoc([num2str(round(k(1,3))) '% pass'], {'SouthOutside', 0.1})
else
    textLoc([num2str(100-round(k(1,3))) '% pass'], {'SouthOutside', 0.1})
end

subplot(2,2,2);

k = tabulate(h_vals_ss);
total_percent = [total_percent; k(1,3)];
ktest_mat_ss = tril(ktest_mat_ss, length(ss))'+ktest_mat_ss;
g= imagesc(flipud(ktest_mat_ss));
cmap = jet(20);
cmap = flipud(cmap(1:10,:));

cmap(1,:) = [0 0 0];
cmap(2:end-1,:) = repmat([0 1 0], length(cmap(2:end-1,:)), 1);
cmap(end,:) = [1,1,1];
axis square;
caxis manual
caxis([0 2]);
colormap(cmap);

xx = get(gca, 'XLim');
yy = get(gca, 'YLim');
set(gca, 'XTick', linspace(xx(1),xx(2),12), 'XTickLabel', fan_names) % 10 ticks 
set(gca, 'YTick', linspace(yy(1),yy(2),12), 'YTickLabel', flip(fan_names)) % 20 ticks
set(gca,'XTick', (1:size(ktest_mat_ss,2)))
set(gca,'YTick', (1:size(ktest_mat_ss,1)))
set(gca,'TickLabelInterpreter','none')
if k(1,1) < 1
    textLoc([num2str(round(k(1,3))) '% pass'], {'SouthOutside', 0.1})
else
    textLoc([num2str(100-round(k(1,3))) '% pass'], {'SouthOutside', 0.1})
end

subplot(2,2,3);
for m=1:length(fan_wolmans)
    [f,x] = ecdf(fan_wolmans{m});
    plot(x,f);
    hold on;
end

ylabel('Frequency')
xlabel('mm');
legend(fan_names)
grid on
subplot(2,2,4);
for m=1:length(fan_sss)
    [f,x] = ecdf(fan_sss{m});
    plot(x,f);
    hold on;
end
ylabel('Frequency')
xlabel('\xi');
legend(fan_names)
grid on


print(f1, '-dpdf', ['../pdfs/figure_S3_5_bottom.pdf'])