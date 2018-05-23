
% Side-cut grain size count convergence

[~, ~, raw] = xlsread('../side_cut_data/G8-B5/G8-B5-Complete.xlsx','Sheet1');
raw = raw(3:102,2:12);
raw = raw(:,[1,2,3,4,5,6,7,8,9,10,11]);
data = reshape([raw{:}],size(raw));

G8_B5 = struct(...
    'surface', [data(:,1),data(:,2),data(:,3),data(:,4),data(:,5)],...
    'side', [data(:,6),data(:,7),data(:,8),data(:,9),data(:,10)],...
    'wolman', data(:,11)...
);

[~, ~, raw] = xlsread('../side_cut_data/G8-B1/G8-B1-Complete.xlsx','Sheet1');
raw = raw(4:103,:);
raw = raw(:,[1,2,3,4,5,7,8,9,10,11,14]);
data = reshape([raw{:}],size(raw));

G8_B1 = struct(...
    'side', [data(:,1),data(:,2),data(:,3),data(:,4),data(:,5)],...
    'surface', [data(:,6),data(:,7),data(:,8),data(:,9),data(:,10)],...
    'wolman', data(:,11)...
);

% Running means
G8_B5.side_running = zeros(100,5);
G8_B5.surface_running = zeros(100,5);
G8_B1.side_running = zeros(100,5);
G8_B1.surface_running = zeros(100,5);
G8_B5.side_running_d84 = zeros(100,5);
G8_B5.surface_running_d84 = zeros(100,5);
G8_B1.side_running_d84 = zeros(100,5);
G8_B1.surface_running_d84 = zeros(100,5);
G8_B5.side_running_d50 = zeros(100,5);
G8_B5.surface_running_d50 = zeros(100,5);
G8_B1.side_running_d50 = zeros(100,5);
G8_B1.surface_running_d50 = zeros(100,5);

for j=1:5
    G8_B5.side_running(:,j) = arrayfun(@(i) mean(G8_B5.side(1:i,j)),(1:100)');
    G8_B5.surface_running(:,j) = arrayfun(@(i) mean(G8_B5.surface(1:i,j)),(1:100)');
    G8_B1.side_running(:,j) = arrayfun(@(i) mean(G8_B1.side(1:i,j)),(1:100)');
    G8_B1.surface_running(:,j) = arrayfun(@(i) mean(G8_B1.surface(1:i,j)),(1:100)');

    G8_B5.side_running_d50(:,j) = arrayfun(@(i) prctile(G8_B5.side(1:i,j),50),(1:100)');
    G8_B5.surface_running_d50(:,j) = arrayfun(@(i) prctile(G8_B5.surface(1:i,j),50),(1:100)');
    G8_B1.side_running_d50(:,j) = arrayfun(@(i) prctile(G8_B1.side(1:i,j),50),(1:100)');
    G8_B1.surface_running_d50(:,j) = arrayfun(@(i) prctile(G8_B1.surface(1:i,j),50),(1:100)');
    
    G8_B5.side_running_d84(:,j) = arrayfun(@(i) prctile(G8_B5.side(1:i,j),84),(1:100)');
    G8_B5.surface_running_d84(:,j) = arrayfun(@(i) prctile(G8_B5.surface(1:i,j),84),(1:100)');
    G8_B1.side_running_d84(:,j) = arrayfun(@(i) prctile(G8_B1.side(1:i,j),84),(1:100)');
    G8_B1.surface_running_d84(:,j) = arrayfun(@(i) prctile(G8_B1.surface(1:i,j),84),(1:100)');
    
end

line_colours = [0.2000 0.6700 0.1900; 0.2000 0.5000 1.0000];

X = 25;                  
Y = 20;                  
xMargin = 0;               %# left/right margins from page borders
yMargin = 2;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;
ySize = Y - 2*yMargin;

f = figure('Menubar','none');
set(f, 'Position', [0,0, 1200, 800])
set(f, 'PaperSize',[X Y]);
set(f, 'PaperPosition',[0 yMargin xSize ySize])
set(f, 'PaperUnits','centimeters');

b5_mean_wolman = mean(G8_B5.wolman);
subplot(2,2,3);
b5_fill = fill([0 0 100 100], [b5_mean_wolman+5 b5_mean_wolman-5 ...
    b5_mean_wolman-5 b5_mean_wolman+5], [0.9 0.9 0.9], 'EdgeColor','none');
hold on;
b5_sideplots = plot(G8_B5.side_running, 'Color', line_colours(1,:));
hold on;
b5_surface_plots = plot(G8_B5.surface_running, 'Color', line_colours(2,:));
ylim([0 200]);
hold on
b5_sidewolman = plot([0 100], [mean(G8_B5.wolman) mean(G8_B5.wolman)], '--k',...
    'LineWidth',1);
xlabel('Count');
ylabel('mm');
legend([b5_sideplots(1), b5_surface_plots(1), b5_sidewolman, b5_fill],...
    {'Side cut photo mean', 'Surface photo mean ', 'Field count',...
    '\pm5mm envelope'});
title('G8-B5 Mean Convergence');

b1_mean_wolman = mean(G8_B1.wolman);
subplot(2,2,1);
b1_fill = fill([0 0 100 100], [b1_mean_wolman+5 b1_mean_wolman-5 ...
    b1_mean_wolman-5 b1_mean_wolman+5], [0.9 0.9 0.9], 'EdgeColor','none');
hold on;
b1_sideplots = plot(G8_B1.side_running, 'Color', line_colours(1,:));
hold on;
b1_surface_plots = plot(G8_B1.surface_running, 'Color', line_colours(2,:));
hold on;
b1_sidewolman = plot([0 100], [b1_mean_wolman b1_mean_wolman], '--k',...
    'LineWidth',1);
ylim([0 200]);
title('G8-B1 Mean Convergence');
xlabel('Count');
ylabel('mm');
legend([b1_sideplots(1), b1_surface_plots(1), b1_sidewolman, b1_fill],...
    {'Side cut photo mean', 'Surface photo mean', 'Field count',...
    '\pm5mm envelope'});

b5_d84_wolman = prctile(G8_B5.wolman,84);
subplot(2,2,4);
b5_fill = fill([0 0 100 100], [b5_d84_wolman+10 b5_d84_wolman-10 ...
    b5_d84_wolman-10 b5_d84_wolman+10], [0.9 0.9 0.9], 'EdgeColor','none');
hold on;
b5_sideplots = plot(G8_B5.side_running_d84, 'Color', line_colours(1,:));
hold on;
b5_surface_plots = plot(G8_B5.surface_running_d84, 'Color', line_colours(2,:));
ylim([0 200]);
hold on
b5_sidewolman = plot([0 100], [b5_d84_wolman b5_d84_wolman], '--k',...
    'LineWidth',1);
xlabel('Count');
ylabel('mm');
title('G8-B5 D_{84} Convergence');
legend([b5_sideplots(1), b5_surface_plots(1), b5_sidewolman, b5_fill],...
    {'Side cut photo D_{84}', 'Surface photo D_{84}', 'Field count',...
    '\pm10mm envelope'});

b1_d84_wolman = prctile(G8_B1.wolman,84);
subplot(2,2,2);
b1_fill = fill([0 0 100 100], [b1_d84_wolman+10 b1_d84_wolman-10 ...
    b1_d84_wolman-10 b1_d84_wolman+10], [0.9 0.9 0.9], 'EdgeColor','none');
hold on;
b1_sideplots = plot(G8_B1.side_running_d84, 'Color', line_colours(1,:));
hold on;
b1_surface_plots = plot(G8_B1.surface_running_d84, 'Color', line_colours(2,:));
hold on;
b1_sidewolman = plot([0 100], [prctile(G8_B1.wolman,84) prctile(G8_B1.wolman,84)], '--k',...
    'LineWidth',1);
ylim([0 200]);
title('G8-B1 D_{84} Convergence');
xlabel('Count');
ylabel('mm');
legend([b1_sideplots(1), b1_surface_plots(1), b1_sidewolman, b1_fill],...
    {'Side cut photo D_{84}', 'Surface photo D_{84}', 'Field count',...
    '\pm10mm envelope'});

print(f, '-dpdf', '../pdfs/figure_S3_3.pdf');
