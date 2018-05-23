% North Fork Toutle River Fit

X = 21.0;                  %# A3 paper size
Y = 14.0;                  %# A3 paper size
xMargin = 0;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

addpath('north_fork_toutle');
addpath('../j-tools/J_functions');

fd_fit_import;
 
CV_fd = 0.7;
global C1_fd;
C1_fd = 0.75;
global C2_fd;
C2_fd = C1_fd/CV_fd;
global inc;
inc = 0.2;

ag = 0.02; 
bg = 2.0;
cg = 0.1;

ag1 = 0.14;
bg1 = 2.10;
cg1 = 0.264;

% ds_sorted = distance_sorted.G8.C;
% surface_data = g8_data{3};

%[ss_var, field_x, field_y] =  surface_process(ds_surface, surface_data, inc);

field_x = xi2;
field_y = f2';

[v,resnorm,residuals,exitflag,output,lambda,jacobian] = lsqcurvefit(@fractionOnly,[ag,bg,cg], field_x, ...
    field_y', [1e-4,1e-4,1e-4]);


ag = v(1);
bg = v(2);
cg = v(3);

ss_var = -5:inc:6;

[J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, ...
    int_constant_ana, fraction] = calcFraction([0.1,4.5,cg], ss_var, C1_fd, C2_fd, inc);


f1 = figure();
set(f1, 'PaperSize',[X Y]);
set(f1, 'PaperPosition',[0 yMargin xSize ySize])
set(f1, 'PaperUnits','centimeters');
% set(f1, 'Visible', 'off');

subplot(1,2,1);
plot(xi,f, 'x', 'Color', [0.6 0.6 0.6]);
hold on;
plot(field_x,field_y, 'k-', 'LineWidth', 1);
hold on;
plot(ss_var,fraction, 'b-', 'LineWidth', 1.5);
xlim([-4 4]);
xlabel('\xi');
ylabel('Frequency');
textLoc({'\bf ag\rm = 0.1';'\bf bg\rm = 4.5';'\bf cg\rm = 0.08'}, 'northwest', 'FontSize', 12);
legend({'North Fork Toutle River', 'Distribution Fit', 'Analytical Fit'}, 'Location', 'SouthOutside'); 
set(gca, 'FontSize', 12);
title('\xi Distributions')

subplot(1,2,2);
plot(ss_var,J, 'b-', 'LineWidth', 1.5);
xlim([-4 4]);
ylim([0 2]);
title('J relative to \xi');
xlabel('\xi');
ylabel('J');
set(gca, 'FontSize', 12);

print(f1, '-dpdf', ['../pdfs/figure_S5_2' '.pdf'])
