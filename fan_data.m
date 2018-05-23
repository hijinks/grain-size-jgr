% fan_data.m
% Process grain size distributions and output fan-surface data

function [s_data] = fan_data(root_dir, fan, index_point, coord_file)

    s_data = {};
    paths = {};
    filenames = {};
    exts = {};
    sub_dirs = {};
    [ix,iy,iu,iutm1] = wgs2utm(index_point(1),index_point(2));
    coord_table = get_coords(coord_file);
    
    dir_search = subdir(root_dir);
    extensions = {'.csv', '.yml'};
    for j=1:(length(dir_search))
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
    f_data = T(find(strcmp(fan,T.Dir_1)), :);
    surfaces = unique(f_data.Dir_2);

    surface_tables = {};

    for su=1:length(surfaces)
        surface = surfaces{su};
        surface_data = f_data(find(strcmp(surface,f_data.Dir_2)), :);

        sites = unique(surface_data.Dir_3);

        data_files = {};

        for s=1:length(sites)
            site_data = surface_data(find(strcmp(sites(s),surface_data.Dir_3)), :);
            types = {};
            data_files{s} = {};
            cur_dat = data_files{s};
            fn = site_data.Filenames;
            for u=1:length(fn)
                fnp = char(fn(u));
                if strcmp(fnp(1), '_') > 0
                    types = [types;'?'];
                else
                    exp = '(?<name>[\s\w]+)_(?<type>\w+)';
                    res = regexp(fnp, exp, 'names');
                    if strcmp(res.type, 'old') < 1
                        types = [types;res.name];
                    end
                end
            end
            types = unique(types);
            for r=1:length(types)
                if strcmp(char(types(r)), '?') > 0
                    meta_name = strcat('_', 'meta');
                    wolman_name = strcat('_', 'wolman');
                    dat.type = char('?');
                else
                    meta_name = strcat(char(types(r)),'_', 'meta');
                    wolman_name = strcat(char(types(r)),'_', 'wolman');
                    dat.type = char(types(r));
                end
                dat.site = sites(s);

                dat.meta = strcat(fan,'/',surface,'/',sites(s),'/',meta_name, '.yml');
                dat.wolman = strcat(fan,'/',surface,'/',sites(s),'/',wolman_name, '.csv');
                cur_dat = [cur_dat,dat];
                
            end
            data_files{s} = cur_dat;
        end

        wolmans = {};
        meta = {};
        coords = {};    

        for d=1:length(data_files)
           df = data_files{d};
           if ~isempty(df)
               for pp=1:length(df)
                   dat = df{pp};
                   fname = strcat(root_dir, filesep, dat.wolman);
                   mname = strcat(root_dir, filesep, dat.meta);
                   coord_name = strcat(fan,'-',surface,'-',dat.site{1});
                   disp(mname{1});
                   meta_data = YAML.read(mname{1});
                   meta_data.c_name = coord_name;
                   meta = [meta, meta_data];
                   
                   disp(coord_name);
                   if sum(strcmp(coord_table.Properties.RowNames, coord_name)) > 0
                       coord_row = coord_table({coord_name}, :);
                       coords = [coords;[coord_row.lat, coord_row.lon, 0]];
                   else
                       location = strsplit(meta_data.location,' ');
                       disp(location);
                       coords = [coords;[str2num(char(location{1})), str2num(char(location{2})), 1]];
                   end
                   
                   wolmans = [wolmans,csvread(fname{1})];
                end
            end
        end

        d84_dat = [];
        d50_dat = [];
        distances = [];
        means = [];
        ss_datas = {};
        stdevs = [];
        metas = {};
        cv_means = [];
        cv_norms = [];
        cv_medians = [];
        cv_d84s = [];
        all_wolmans = {};
        utm_coords = [];
        surface_columns = zeros(200,length(data_files));
        surface_col_names = {};

        for w=1:length(wolmans)
            surface_columns(3:(length(wolmans{w})+2),w) = wolmans{w};
            stdDev = std(wolmans{w});
            

            d50 = prctile(wolmans{w},50);
            d84 = prctile(wolmans{w},84);
            d84_dat = [d84_dat,d84];
            d50_dat = [d50_dat,d50];
            m = mean(wolmans{w});
            means = [means,m];
            cmeta = meta{w};
            cmeta.w_id = w;
            metas = [metas,cmeta];
            all_wolmans = [all_wolmans,wolmans{w}];
            stdevs = [stdevs,stdDev];
            surf_name = [cmeta.name, '_', cmeta.site];
            
            if max(wolmans{w}) > 700
                disp('Too big');
                disp([cmeta.surface '_' surf_name]);
            end
            
            s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            randString = s( ceil(rand(1,5)*length(s)));
            surface_col_names{w} = ['V',randString,'_', strrep(surf_name, ' ', '_')];


            % Coefficient of variation (using mean)
            cv_mean = stdDev/m;
            cv_norm = (1+(1/(length(wolmans{w}))))*cv_mean;
            % Coefficient of variation (using median)
            cv_median = stdDev/d50;
            cv_d84 = stdDev/d84;
            cv_means = [cv_means, cv_mean];
            cv_norms = [cv_norms, cv_norm];
            cv_medians = [cv_medians, cv_median];
            cv_d84s = [cv_d84s, cv_d84];
            sorted_data = sort(wolmans{w});

            ss_data = arrayfun(@(x)((x-m)/stdDev),sorted_data);
            ss_datas{w} = ss_data;
            c1 = coords{w};
            
            if c1(3)
               x1 = c1(1);
               y1 = c1(2);
            else
               [x1,y1,u1,utm1] = wgs2utm(c1(1),c1(2)); 
            end
            
            utm_coords = [utm_coords; [x1, y1]];
            d = sqrt((ix-x1)^2+(iy-y1)^2);
            if d > 10000
                disp([cmeta.surface '_' surf_name]);
            end
            distances = [distances,d];
            surface_columns(1,w) = d;
            if isstrprop(cmeta.cover, 'digit')
                surface_columns(2,w) = str2num(cmeta.cover);
            else
                surface_columns(2,w) = 100;
            end
        end

        surface_columns(sum(~any(surface_columns,length(data_files)),2)==length(data_files), :) = [];    
        T = array2table(surface_columns, 'VariableNames',surface_col_names);
        writetable(T,strcat('output/',surface,'_', fan, '.csv'));
        sd.name = surface;
        sd.d84 = d84_dat;
        sd.d50 = d50_dat;
        sd.mean = means;
        sd.stdev = stdevs;
        sd.meta = metas;
        sd.coords = utm_coords;
        sd.wolmans = all_wolmans;
        sd.cv_mean = cv_means;
        sd.cv_norm = cv_norms;
        sd.cv_median = cv_medians;
        sd.cv_d84 = cv_d84s;
        sd.ss = ss_datas;
        sd.distance = distances;
        s_data{su} = sd;
    end
end