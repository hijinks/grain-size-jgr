function [area_data, gs_data] = import_data(root)
    paths = {};
    filenames = {};
    exts = {};
    sub_dirs = {};
    dir_search = subdir(root);
    extensions = {'.csv'};

    for j=1:(length(dir_search)),
        [pathstr,name,ext] = fileparts(dir_search(j).name);
        if strmatch(ext, extensions)
            paths = [paths;pathstr];
            filenames = [filenames;name];
            exts = [exts;ext];
            C = strsplit(pathstr,filesep);
            for l=3:(length(C))
                n = l-2;
                if length(sub_dirs) < n
                    sub_dirs{n} = {};
                end
                sub_dirs{n} = [sub_dirs{n};C{l}];
            end
        end
    end

    k = size(paths);
    y = k(1);

    col_l = length(sub_dirs) + 2;

    f_vals = cell(y, col_l);

    col_names = {};

    for g=1:length(sub_dirs)
        col_names{g} = strcat('Dir_',num2str(g));
        f_vals(1:y,g) = sub_dirs{g};
    end

    f_vals(1:y,(col_l - 1)) = filenames;
    col_names{col_l - 1} = 'Filenames';
    f_vals(1:y, col_l) = exts;
    col_names{col_l} = 'Extension';
    T = cell2table(f_vals,'VariableNames',col_names);

    areas = unique(T.Dir_1);
    area_data = {};
    gs_data = struct();

    for a=1:length(areas)

        % For each area

        ad = {};
        gs_data.(areas{a}) = struct();

        a_data = T(find(strcmp(areas{a},T.Dir_1)), :);
        surfaces = unique(a_data.Dir_2);
        dim1 = size(surfaces);

        for b=1:dim1(1)

            % For each surface
            s_data = a_data(find(strcmp(surfaces{b},a_data.Dir_2)), :);
            dim2 = size(s_data);

            % ASSUMES ALL SITE NAMES ARE UNIQUE

            s_d50s = zeros(dim2(1),1);
            s_d84s = zeros(dim2(1),1);
            s_means = zeros(dim2(1),1);
            s_cvs = zeros(dim2(1),1);
            s_ss = cell(dim2(1),1);
            s_stds = zeros(dim2(1),1);
            s_wolmans = cell(dim2(1),1);

            dd = s_data.Properties.VariableNames;
            s = regexp(dd, 'Dir');
            dir_len = length(cell2mat(s));
             
            gs_surface = {};
            
            for c=1:dim2(1)

                % For each site

                tdat = s_data(c,:);

                dir_vars = [];
                for dv = 1:dir_len
                    dir_vars = [dir_vars filesep tdat.(['Dir_' num2str(dv)]){1}];
                end
            
            
                fpath = strcat(root, dir_vars, filesep, tdat.Filenames, tdat.Extension); 
                wdata = csvread(fpath{1},2,0);
                wdata = reshape(wdata, numel(wdata), 1);

                m = mean(wdata);
                d50 = prctile(wdata, 50);
                d84 = prctile(wdata, 84);
                stdev = std(wdata);
                cv_mean = stdev/m;

                sorted_data = sort(wdata);

                ss_data = arrayfun(@(x)((x-m)/stdev),sorted_data);

                s_d50s(c) = d50;
                s_d84s(c) = d84;
                s_means(c) = m;
                s_cvs(c) = cv_mean;
                s_ss{c} = ss_data;
                s_stds(c) = stdev;
                s_wolmans{c} = wdata;

                gs_row = {[], wdata, []};
                gs_surface = [gs_surface;gs_row];
            end

            s_struct = struct();
            s_struct.name = surfaces{b};
            s_struct.d84 = s_d84s;
            s_struct.d50 = s_d50s;
            s_struct.mean = s_means;
            s_struct.stdev = s_stds;
            s_struct.wolmans = s_wolmans;
            s_struct.cv_mean = s_cvs;
            s_struct.ss = s_ss;

            ad = [ad, s_struct];
            gs_data.(areas{a}).(surfaces{b}) = gs_surface;
        end
        area_data = [area_data, {ad}];
    end

end

