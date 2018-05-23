
function fraction = fractionOnly(j_params, ss_data)
    C1 = getC1;
    C2 = getC2;
    inc = getInc;
    
    
    [J, Jprime, phi, sym, expsym, intsysmeps, sigma, int_val, int_constant_ana, fraction] = calcFraction(j_params, ss_data, C1, C2, inc);
end