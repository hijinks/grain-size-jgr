
function AutoJ(Jprocess)
    
    FIT = 1;
    s_mean = [];
    s_stdev = [];
    
    surfaces = fieldnames(Jprocess);
    
    surface_letters = {};
    fan_categories = surfaces';
    
    a_constant = {};
    b_constant = {};
    c_constant = {};
    
    for p=1:length(surfaces)

        sd = Jprocess.(surfaces{p});

        ds_surface = sd{1};
        surface_data = sd{2};
        surface_name = surfaces{p};
        surface_letters{p} = surface_data.name;

        ds_size = size(ds_surface);
        total_wolmans = [];
        
        for j=1:ds_size(1)
            wol = ds_surface{j,2};
            wol(isnan(wol)) = [];
            total_wolmans = [total_wolmans; wol];
        end
        
        mean_wol = mean(total_wolmans);
        stdev_wol = std(total_wolmans);
        CV_mean = stdev_wol/mean_wol;
        
        
        ss_total = (total_wolmans-mean_wol)./stdev_wol;
        
        C1_av = 0.55;
        C2_av = C1_av/CV_mean;
        %C1_av = C1_m;
        %C2_av = C2_m;
        
        ed = -5.5:.5:5.5;
        xp = [-5:.5:5.5];
        ss_var = -5:.5:6;
        total = 0;
        
        if total > 0
            [N,edges] = histcounts(ss_total, xp);
            fD = N./sum(N);

            sums_total = 0;
            bin_totals = zeros(1,length(xp)-1);

            field_y = fD;
            field_x = xp(1:end-1);
        else
            ss = surface_data.ss;
            all_x = [];
            all_y = [];

            sums_total = 0;
            bin_totals = zeros(1,length(xp)-1);

            for k=1:length(ss)
               [N,edges] = histcounts(ss{k}, xp);
               all_x = [all_x; xp];

               sums_total = sums_total+sum(N);

               % Frequency Density
               fD = N./sum(N);
               bin_totals = bin_totals+N;
               all_y = [all_y; fD];
            end

            field_y = bin_totals./sums_total;
            field_x =xp(1:end-1);        
            
        end
        ag = .02;
        bg = 2;
        cg = .1;
        
        ag_range = [];
        bg_range = [];
        cg_range = [];
        
        
        if FIT > 0 
            [v,resnorm,residuals,exitflag,output,lambda,jacobian] = ...
                lsqcurvefit(@fractionOnly, [ag,bg,cg], field_x, ...
                field_y',[1e-4 1e-4 1e-4],[]);
            
            conf = nlparci(v,residuals,'jacobian',jacobian);
            lower = conf(:,1);
            upper = conf(:,2);
            ag = v(1);
            bg = v(2);
            cg = v(3);
            
            for l=1:3
                
                for m=1:2
                    
                    if m > 1
                        if l == 1
                            x0 = [upper(1), bg, cg];
                            lb = [upper(1) lower(2) lower(3)];
                            ub = [upper(1) upper(2) upper(3)];
                        end

                        if l == 2
                            x0 = [ag, upper(2), cg];
                            lb = [lower(1) upper(2) lower(3)];
                            ub = [upper(1) upper(2) upper(3)];
                        end

                        if l == 3
                            x0 = [ag, bg, upper(3)];
                            lb = [lower(1) lower(2) upper(3)];
                            ub = [upper(1) upper(2) upper(3)];
                        end
                        
                    else
                
                        if l == 1
                            x0 = [lower(1), bg, cg];
                            lb = [lower(1) lower(2) lower(3)];
                            ub = [lower(1) upper(2) upper(3)];
                        end

                        if l == 2
                            x0 = [ag, lower(2), cg];
                            lb = [lower(1) lower(2) lower(3)];
                            ub = [upper(1) lower(2) upper(3)];
                        end

                        if l == 3
                            x0 = [ag, bg, lower(3)];
                            lb = [lower(1) lower(2) lower(3)];
                            ub = [upper(1) upper(2) lower(3)];
                        end
                    end
                    
                    [v,resnorm,residuals,exitflag,output,lambda,jacobian] = ...
                        lsqcurvefit(@fractionOnly, x0, field_x, ...
                        field_y',lb,ub);
                    
                    ag_range = [ag_range; v(1)];
                    bg_range = [bg_range; v(2)];
                    cg_range = [cg_range; v(3)];
                end

            end
            

        else
            residuals = 0;
            resnorm = 0;
        end

        [J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, ...
        int_constant_ana, fraction] = calcFraction([ag,bg,cg], ss_var, C1_av, C2_av);     

%         if cg > 1
%             anomaly = [surfaces{p}, k];
% 
%             plot(ss_var, fraction, 'r', 'LineWidth',3);
%             hold on;
% 
%         else
%             plot(ss_var, fraction, 'b');
%             hold on;
%         end
        
        a_constant{p} = ag;
        b_constant{p} = bg;
        c_constant{p} = cg;

        output_location = './jfits';

        saveData = struct();
        saveData.J = J;
        saveData.Jprime = Jprime;
        saveData.phi = phi;
        saveData.sym = sym;
        saveData.sigma = sigma;
        saveData.expsym = expsym;
        saveData.intsysmeps = intsysmeps;
        saveData.fraction = fraction;
        saveData.ss_var = ss_var';
        saveData.int_constant_ana = int_constant_ana;
        saveData.residuals = residuals;
        saveData.resnorm = resnorm;
        saveData.ag = ag;
        saveData.bg = bg;
        saveData.cg = cg;
        saveData.mean = mean_wol;
        saveData.stdev = stdev_wol;
        saveData.field_x = field_x';
        saveData.field_y = field_y';
        saveData.C1 = C1_av;
        saveData.C2 = C2_av;
        saveData.CV = CV_mean;
        saveData.upper = conf(:,1);
        saveData.lower = conf(:,2);
        saveData.ag_range = ag_range;
        saveData.bg_range = bg_range;
        saveData.cg_range = cg_range;
        
        file = [surface_name,'.csv'];

        struct2csv(saveData,[output_location '/' file]);     
    end
    
    save('constants', 'a_constant', 'b_constant', 'c_constant');
    
    function fraction = fractionOnly(j_params, ss_data)
        [J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, int_constant_ana, fraction] = calcFraction(j_params, ss_data, C1_av, C2_av);
    end

    function [J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, ...
        int_constant_ana, fraction] = calcFraction(j_params, ss_var, C1, C2)

        jfunc = @(x) (j_params(1)*(exp(-j_params(2)*x))+j_params(3));

        J = arrayfun(jfunc, ss_var, 'UniformOutput', true)';
        Jprime = zeros(length(ss_var), 1);
        phi = zeros(length(ss_var), 1);
        sym = zeros(length(ss_var), 1);
        expsym = zeros(length(ss_var), 1);
        intsysmeps = zeros(length(ss_var), 1);
        sigma = zeros(length(ss_var), 1);

        for p=1:length(ss_var)    
            if p == 1
                k1 = p;
                k2 = p+1;     
            else
                k1 = p-1;
                k2 = p;
            end
            ss_change = ss_var(k1)-ss_var(k2);
            J_change = J(k1)-J(k2);
            Jprime(p) = J_change/ss_change;
            phi(p) = (1/(C1*(1+(C2/C1)*ss_var(p))))*(1-(1/J(p)))-(Jprime(p)/J(p));
            phi_change = phi(k1)+phi(k2);
            sym(p) = 0.5*phi_change*ss_change;   
        end

        for y=1:length(sym)
            if y > 1
                sigma(y) = sigma(y-1)+sym(y);
            else
                sigma(y) = sym(y);
            end
            expsym(y) = exp(-sigma(y));
        end

        for r=1:length(sigma)
            if r == 1
                k1 = r;
                k2 = r+1;
            else
                k1 = r-1;
                k2 = r;      
            end

            ss_change = abs(ss_var(k1)-ss_var(k2));
            expsym_change = expsym(k1)+expsym(k2);
            intsysmeps(r) = 0.5*expsym_change*ss_change;
        end

        int_val = sum(intsysmeps);
        int_constant_ana = 1/int_val;
        fraction = intsysmeps*int_constant_ana;
    end

    % Scan every fan


end


