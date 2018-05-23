function [ss_var, field_x, field_y] =  surface_process(ds_surface, surface_data, inc)
        
    s_mean = [];
    s_stdev = [];

    ds_size = size(ds_surface);

    for j=1:ds_size(1)
        wol = ds_surface{j,2};
        wol(isnan(wol)) = [];
        s_mean = [s_mean; mean(wol)];
        s_stdev = [s_stdev; std(wol)];
    end

    ds_dist = cell2mat(ds_surface(:,1));
    ds_norm = ds_dist./max(ds_dist);

    ss = surface_data.ss;

    xp = -5:inc:5;
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
    
    % CRITICAL
    field_x =xp(2:end);
    
    ss_var = -5:inc:6;
end