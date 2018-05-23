function [ss_vals] = ss_range(a_vals, b_vals)
    
    ss_outputs = [];
    c = 0.1;
    S1 = [];
    ss_vals = struct();
    
    % Substrate
    j_substrate = zeros(length(a_vals),1);
    
    % Equal
    j1 = zeros(length(a_vals),1);
    
    % Transport
    j_transport = zeros(length(a_vals),1);
    
    for i=1:length(a_vals)
        a = a_vals(i);
        b = b_vals(i);
    
        J_vals = c:.005:3;
        j1(i) = -log((1-c)/a)/b;
        j_substrate(i) = -log((.5-c)/a)/b;
        j_transport(i) = -log((1.5-c)/a)/b;
    end
    
    
    upper_J1 = max(j1);
    lower_J1 = min(j1);
    
    upper_Jsubstrate = max(j_substrate);
    lower_Jsubstrate = min(j_substrate);

    upper_Jtransport = max(j_transport);
    lower_Jtransport = min(j_transport);
    
    ss_vals.J1 = [upper_J1, lower_J1];
    ss_vals.Jtransport = [upper_Jtransport,lower_Jtransport];
    ss_vals.Jsubstrate = [upper_Jsubstrate, lower_Jsubstrate];
end
