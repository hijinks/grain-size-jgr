function [J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, ...
    int_constant_ana, fraction] = calcFraction(j_params, ss_var, C1, C2, inc)

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
        sym(p) = inc*phi_change*ss_change;    
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
        intsysmeps(r) = inc*expsym_change*ss_change;
    end

    int_val = sum(intsysmeps);
    int_constant_ana = 1/int_val;
    fraction = intsysmeps*int_constant_ana;   
end