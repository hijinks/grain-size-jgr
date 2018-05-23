% K-S tests for surfaces

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


bigval = nan(5e5,1);

surface_names = {};
surface_wolmans = {};
surface_sss = {};

export = 0;

total_percent = [];

% Lump all of the surface wolmans together
for u=1:length(fan_names)
    
    current_fan = fan_data{u};
    current_fan_name = fan_names{u};
    
    for w=1:length(current_fan)
        
        surface_data = current_fan{w};
        ss = surface_data.ss;
        wol = surface_data.wolmans;
        
        surface_names = [surface_names, [fan_names{u} surface_data.name]];
        surface_sss = [surface_sss; vertcat(ss{:})];
        surface_wolmans = [surface_wolmans; vertcat(wol{:})];
    end
end

% Find all the possible iterations to compare surfaces

prms = nchoosek(1:1:length(surface_wolmans),2);
p_vals = [];
k_vals = [];
h_vals = [];
k_vals_ss = [];
h_vals_ss = [];
ktest_mat = zeros(length(surface_wolmans), length(surface_wolmans));
ktest_mat_ss = zeros(length(surface_wolmans), length(surface_wolmans));

% Test surface-surface two sample KS test
% Null hypothesis - the two test distributions are from the same
% distribution.

% H = 1 - we can reject hypothesis, hence distributions are not the same
% H = 0 - we cannot reject hypothesis, hence the distributions are the same

% For the sake of plotting values, I add 1 to the matrix of H values...
% For reference...
% H = 2 - Distributions are different
% H = 1 - Distributions are the same


for p=1:length(prms)
    t1 = surface_wolmans{prms(p,1)};
    t2 = surface_wolmans{prms(p,2)};
    t3 = surface_sss{prms(p,1)};
    t4 = surface_sss{prms(p,2)};
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
ktest_mat = tril(ktest_mat, length(surface_wolmans))'+ktest_mat;
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
set(gca, 'XTick', linspace(xx(1),xx(2),12), 'XTickLabel', surface_names) % 10 ticks 
set(gca, 'YTick', linspace(yy(1),yy(2),12), 'YTickLabel', flip(surface_names)) % 20 ticks
set(gca,'XTick', (1:size(ktest_mat,2)))
set(gca,'YTick', (1:size(ktest_mat,1)))
set(gca,'FontSize', 7);
set(gca,'TickLabelInterpreter','none');

if k(1,1) < 1
    textLoc([num2str(round(k(1,3))) '% pass'], {'SouthOutside', 0.05})
else
    textLoc([num2str(100-round(k(1,3))) '% pass'], {'SouthOutside', 0.05})
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
set(gca, 'XTick', linspace(xx(1),xx(2),12), 'XTickLabel', surface_names) % 10 ticks 
set(gca, 'YTick', linspace(yy(1),yy(2),12), 'YTickLabel', flip(surface_names)) % 20 ticks
set(gca,'XTick', (1:size(ktest_mat_ss,2)))
set(gca,'YTick', (1:size(ktest_mat_ss,1)))
set(gca,'FontSize', 7);
set(gca,'TickLabelInterpreter','none');

if k(1,1) < 1
    textLoc([num2str(round(k(1,3))) '% pass'], {'SouthOutside', 0.05})
else
    textLoc([num2str(100-round(k(1,3))) '% pass'], {'SouthOutside', 0.05})
end

subplot(2,2,3);
for m=1:length(surface_wolmans)
    [f,x] = ecdf(surface_wolmans{m});
    plot(x,f);
    hold on;
end

ylabel('Frequency')
xlabel('mm');
legend(surface_names, 'Interpreter','none')
grid on
subplot(2,2,4);
for m=1:length(surface_sss)
    [f,x] = ecdf(surface_sss{m});
    plot(x,f);
    hold on;
end
ylabel('Frequency')
xlabel('\xi');
legend(surface_names, 'Interpreter','none')
grid on

print(f1, '-dpdf', ['../pdfs/figure_S3_5_top.pdf'])
