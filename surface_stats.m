function [distance_sorted] = surface_stats(fan_names, fans)

    distance_sorted = struct();
    figures = struct();
    
    for j=1:length(fans)
        fan = fans{j};
        fan_surface_names = {};
        fan_name = fan_names{j};
        groups = {};

        % For each surface
       for si=1:length(fan)

        % Current surface
        cs = fan(si);
        cs = cs{1};
        s_group = cell(1,2);

        site_wolmans = struct();

        fan_surface_names = [fan_surface_names, ['Surface_' cs.name]];

        % Loop over sites
        for ri=1:length(cs.meta)

            cs_meta = cs.meta{ri};
            cover = cs_meta.cover;
            c_name = cs_meta.c_name;
            cda.name = cs_meta.name;
            cda.cover = cover;
            cda.coords = cs.coords(ri,:);
            cda.id = cs_meta.w_id;
            cda.distance = cs.distance(cda.id);
            cda.wolman = cs.wolmans{cda.id};
            sp = strsplit(cs_meta.name, '_');
            samp_prefix = sp{1};
            t = isstrprop(samp_prefix, 'digit');
            gname = '';

            for tt=1:length(t)
               if t(tt) > 0
                gname = [gname, num2words_fast(str2num(samp_prefix(tt)))];
               else
                gname = [gname, samp_prefix(tt)];
               end
            end

            if strcmp(gname,'')
                gname = 'nil';
            end
            
            gname = strrep(gname, ' ', '_');

            % Check if site name exists (eg. t1E-9)
            if sum(strcmp(s_group(:,1), c_name)) > 0
                idx = find(strcmp(c_name,s_group(:,1)));

                % Does sample name prefix exist?
                current_fieldnames = fieldnames(s_group{idx,2});
                rank = [];

                for f=1:length(current_fieldnames)
                    % Comparing
                    rank = [rank, strdist(gname, current_fieldnames{f})];
                end

                [M,I] = min(rank);
                if M > 2
                    s_group{idx,2}.(gname) = cda;
                else
                    fname = current_fieldnames{I};
                    s_group{idx,2}.(fname) = [s_group{idx,2}.(fname), cda];         
                end

            else
                strcat(gname, c_name);
                s_group = [s_group;{c_name, struct(gname, cda)}];
            end
            
            if max(cda.wolman) > 600
               disp([cs.name ' '  c_name])
            end
        end
        
        s_group(1,:) = [];
        groups{si} = s_group;

       end

        for gg=1:length(groups)

            % For each surface
            % Current surface
            cd = groups(gg);
            for ggg=1:length(cd)

                % Site list
                si = cd(ggg);
                si = si{1};
                slist = {};

                for siss=1:length(si)

                    % Current site
                    sisss = si(siss, 2);
                    sisss = sisss{1};

                    fnames = fieldnames(sisss);

                    wolman_distances = {};

                    if length(fnames) > 0

                        s_weights = {};
                        s_wolmans = {};
                        
                        % For each site group
                        for f=1:length(fnames)
                            % Current site group
                            % E.g. when there are two fines for calibration
                            
                            fn = fnames(f);
                            csg = sisss.(fn{1});
                            
                            sg_wolmans = [];
                            sg_weights = [];
                            sg_distances = [];
                            
                            for p=1:length(csg)
                                gsd = csg(p);
                                sg_distances = [sg_distances,gsd.distance];
                                if strcmp(gsd.cover, 'full') > 0
                                   cover = 100; 
                                else
                                   cover = str2num(gsd.cover);
                                end
                                sg_weights = [sg_weights,floor(cover)];
                                sg_wolmans = [sg_wolmans;gsd.wolman];
                            end
                            
                            s_weights{f} = mean(sg_weights);
                            s_wolmans{f} = sg_wolmans;
                            s_distances{f} = mean(sg_distances);
                        end
                        
                        s_coords = gsd.coords;

                        wolman_matrix = [];
                        for www=1:length(s_weights)
                            wolman_m = nan(500,s_weights{www});
                            wolman_m(1:length(s_wolmans{www}),1:s_weights{www}) = repmat(s_wolmans{www}, 1, s_weights{www});
                            wolman_matrix = [wolman_matrix, wolman_m];
                        end

                        wolman_column = reshape(wolman_matrix,numel(wolman_matrix),1);
                        
                        if length(wolman_column) < 55000
                            dif = 55000 - length(wolman_column);
                            pad = nan(dif,1);
                            wolman_column = [wolman_column;pad];
                        end

                        slist = [slist; {s_distances{1},wolman_column, s_coords}];
                    end
                end
                site_wolmans.(fan_surface_names{gg}) = slist;
            end
        end

        sw_fn = fieldnames(site_wolmans);
        
        surface_sorted = struct();
        
        for o=1:length(fan_surface_names)
           % Sort by distance
           sw_n = sw_fn(o);
           f1 = figure;
           set(f1, 'visible', 'off')
           sw = site_wolmans.(sw_n{1});
           d_sorted = sortrows(sw,1);
           r = d_sorted(:,2);
           
           try
               wm = cell2mat(r');
           catch
               warning('Cell2mat failed');
               rt = r
           end
           
           
           ss = size(wm);
           for y=1:ss(2)
                hold on;
                cdfplot(wm(:,y));
           end
           f2 = figure;
           set(f2, 'visible', 'off');
           boxplot(wm);
           
           % Save distance sorted to master struct
           surface_sorted.(sw_n{1}) = d_sorted;
           
           title(strcat(fan_name, ' ', sw_n{1}, ' Sites'));
           
        end
        
        distance_sorted.(fan_name) = surface_sorted;
    end
end


