function out = repeatedMeasuresAnova(between,within,varargin)
% p = inputParser;
% addRequired(p,'between',@isnumeric);
% addOptional(p,'dimension',1,@isnumeric);
% addOptional(p,'decimal_places',3,@isnumeric);
% addOptional(p,'do_mean','Yes');
% parse(p,between,varargin{:});
% 
% dimension = p.Results.dimension;
% decimal_places = p.Results.decimal_places;

b_varNames = between.Properties.VariableNames;
w_varnames = within.Properties.VariableNames;

number_bet_factors = 0;
for ii = 1:length(b_varNames)
    cmdTxt = sprintf('colClass = class(between.%s);',b_varNames{ii});
    eval(cmdTxt);
    if strcmp(colClass,'categorical')
        number_bet_factors = number_bet_factors + 1;
        between_factors{number_bet_factors} = b_varNames{ii};
    end
end
number_wit_factors = size(within,2);
within_factors = within.Properties.VariableNames;
n=0;

%% define repeated measures model and do ranova
if number_bet_factors > 0
    wilk_text = '';
    for ii = 2:size(between,2)
        wilk_text = [wilk_text between.Properties.VariableNames{ii} ','];
    end
    wilk_text(end) = '~';
    wilk_text = [wilk_text between_factors{1}];
else
    wilk_text = '';
    for ii = 1:size(between,2)
        wilk_text = [wilk_text between.Properties.VariableNames{ii} ','];
    end
    wilk_text(end) = '~';
    wilk_text = [wilk_text '1'];
end

rm = fitrm(between,wilk_text);

if number_wit_factors == 2
    cmdTxt = sprintf('within.%s_%s = within.%s.*within.%s;',within_factors{1},within_factors{2},within_factors{1},within_factors{2});
    eval(cmdTxt);
    within_factors = within.Properties.VariableNames;
end

rm.WithinDesign = within;
if number_wit_factors == 2
    rm.WithinModel = [within_factors{1} '*' within_factors{2}];
else
    rm.WithinModel = within_factors{1};
end
out.rm = rm;
out.mauchly = mauchly(rm);
out.ranova = rm.ranova('WithinModel',rm.WithinModel);

%% find group stats and estimated marginal means
if number_bet_factors > 0
    cmdTxt = 'est_margmean = margmean(rm,{between_factors{1}';
    cmdTxt1 = 'grp_stats = grpstats(rm,{between_factors{1}';
    for ii = 1:number_wit_factors
        cmdTxt = [cmdTxt sprintf(',within_factors{%d}',ii)];
        cmdTxt1 = [cmdTxt1 sprintf(',within_factors{%d}',ii)];
    end
    cmdTxt = [cmdTxt '});'];     cmdTxt1 = [cmdTxt1 '});'];
    eval(cmdTxt); eval(cmdTxt1);
else
    cmdTxt = 'est_margmean = margmean(rm,{within_factors{1}';
    cmdTxt1 = 'grp_stats = grpstats(rm,{within_factors{1}';
    for ii = 2:number_wit_factors
        cmdTxt = [cmdTxt sprintf(',within_factors{%d}',ii)];
        cmdTxt1 = [cmdTxt1 sprintf(',within_factors{%d}',ii)];
    end
    cmdTxt = [cmdTxt '});'];     cmdTxt1 = [cmdTxt1 '});'];
    eval(cmdTxt); eval(cmdTxt1); 
end
combs = nchoosek(1:size(est_margmean,1),2); p = ones(size(combs,1),1);
cemm = size(grp_stats,2); grp_stats{:,cemm+1} = grp_stats.std./sqrt(grp_stats.GroupCount);
grp_stats.Properties.VariableNames{cemm+1} = 'StdErr';
out.grp_stats = grp_stats;
cemm = size(est_margmean,2);
est_margmean{:,cemm+1} = grp_stats{:,end};
est_margmean.Properties.VariableNames{cemm+1} = 'Formula_StdErr';
out.est_marginal_means = est_margmean;

%% do all mulitple comparisons
if number_bet_factors > 0
    ii = 1;
    nameOfVariable = sprintf('mcs.%s',between_factors{ii});
    rhs = sprintf('multcompare(rm,between_factors{ii},''ComparisonType'',''bonferroni'');');
    cmdTxt = sprintf('%s = %s',nameOfVariable,rhs); eval(cmdTxt)
    for ii = 1:length(within_factors)
        nameOfVariable = sprintf('mcs.%s',within_factors{ii});
        rhs = sprintf('multcompare(rm,within_factors{ii},''ComparisonType'',''bonferroni'');');
        cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
        nameOfVariable = sprintf('mcs.%s_by_%s',between_factors{1},within_factors{ii});
        rhs = sprintf('multcompare(rm,between_factors{1},''By'',within_factors{ii},''ComparisonType'',''bonferroni'');');
        cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
        nameOfVariable = sprintf('mcs.%s_by_%s',within_factors{ii},between_factors{1});
        rhs = sprintf('multcompare(rm,within_factors{ii},''By'',between_factors{1},''ComparisonType'',''bonferroni'');');
        cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
    end
else
    for ii = 1:length(within_factors)
        nameOfVariable = sprintf('mcs.%s',within_factors{ii});
        rhs = sprintf('multcompare(rm,within_factors{ii},''ComparisonType'',''bonferroni'');');
        cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
    end
    if length(within_factors) > 1
        combs_with_factors = nchoosek(1:length(within_factors),2);
        for ii = 1:size(combs_with_factors,1)
            ind1 = combs_with_factors(ii,1); ind2 = combs_with_factors(ii,2);
            nameOfVariable = sprintf('mcs.%s_by_%s',within_factors{ind1},within_factors{ind2});
            rhs = sprintf('multcompare(rm,within_factors{%d},''By'',within_factors{%d},''ComparisonType'',''bonferroni'');',ind1,ind2);
            cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
            nameOfVariable = sprintf('mcs.%s_by_%s',within_factors{ind2},within_factors{ind1});
            rhs = sprintf('multcompare(rm,within_factors{%d},''By'',within_factors{%d},''ComparisonType'',''bonferroni'');',ind2,ind1);
            cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
        end
    end
end
out.mcs = mcs;
out.sig_mcs = find_sig_mcs(mcs);

%% find combs and ps for multiple comparisons to make figure and show asterisks where required
if number_bet_factors > 0
    if number_wit_factors == 1
        factor1 = est_margmean.Properties.VariableNames{1};
        factor2 = est_margmean.Properties.VariableNames{2};
        cmdTxt = sprintf('mc_w_by_b = mcs.%s_by_%s;',factor2,factor1); eval(cmdTxt);
        cmdTxt = sprintf('mc_b_by_w = mcs.%s_by_%s;',factor1,factor2); eval(cmdTxt);
        for rr = 1:size(combs,1)
            row1 = combs(rr,1); row2 = combs(rr,2);
            group_val_1 = est_margmean{row1,1};
            with_level_1_1 = est_margmean{row1,2};
            group_val_2 = est_margmean{row2,1};
            with_level_1_2 = est_margmean{row2,2};

%             disp([group_val_1 w12_1 group_val_2 w12_2])

            error
        end
    end
    if number_wit_factors == 2
        factor1 = est_margmean.Properties.VariableNames{1};
        factor2 = est_margmean.Properties.VariableNames{2};
        factor3 = est_margmean.Properties.VariableNames{3};
        cmdTxt = sprintf('mc_w_by_b = mcs.%s_%s_by_%s;',factor2,factor3,factor1); eval(cmdTxt);
        cmdTxt = sprintf('mc_b_by_w = mcs.%s_by_%s_%s;',factor1,factor2,factor3); eval(cmdTxt);
        for rr = 1:size(combs,1)
            row1 = combs(rr,1); row2 = combs(rr,2);
            group_val_1 = est_margmean{row1,1};
            with_level_1_1 = est_margmean{row1,2};
            with_level_2_1 = est_margmean{row1,3};
            w12_1 = categorical(with_level_1_1).*categorical(with_level_2_1);

            group_val_2 = est_margmean{row2,1};
            with_level_1_2 = est_margmean{row2,2};
            with_level_2_2 = est_margmean{row2,3};
            w12_2 = categorical(with_level_1_2).*categorical(with_level_2_2);

%             disp([group_val_1 w12_1 group_val_2 w12_2])

            if group_val_1 == group_val_2
                all_g_vals = mc_w_by_b{:,1};
                tmc = mc_w_by_b(all_g_vals == group_val_1,2:end);
                value_to_check = w12_1; row_col1 = tmc{:,1}==value_to_check;
                value_to_check = w12_2; row_col2 = tmc{:,2}==value_to_check;
                rowN = find(row_col1 & row_col2);
                p(rr) = tmc{rowN,5};
            else
                if w12_1 == w12_2
                    all_w12 = mc_b_by_w{:,1};
                    tmc = mc_b_by_w(all_w12 == w12_1,2:end);
                    value_to_check = group_val_1; row_col1 = tmc{:,1}==value_to_check;
                    value_to_check = group_val_2; row_col2 = tmc{:,2}==value_to_check;
                    rowN = find(row_col1 & row_col2);
                    p(rr) = tmc{rowN,5};
                else
                    n = 0;
                end
            end
        end
    end
else
   if number_wit_factors == 1
        factor1 = est_margmean.Properties.VariableNames{1};
        cmdTxt = sprintf('mc_tbl = mcs.%s;',factor1); eval(cmdTxt);
        for rr = 1:size(combs,1)
            row1 = combs(rr,1); row2 = combs(rr,2);
            with_level_1_1 = est_margmean{row1,1};
            with_level_1_2 = est_margmean{row2,1};
            tmc = mc_tbl;
            value_to_check = with_level_1_1; row_col1 = tmc{:,1}==value_to_check;
            value_to_check = with_level_1_2; row_col2 = tmc{:,2}==value_to_check;
            rowN = find(row_col1 & row_col2);
            p(rr) = tmc{rowN,5};
        end
    end
    if number_wit_factors == 2
        factor1 = est_margmean.Properties.VariableNames{1};
        factor2 = est_margmean.Properties.VariableNames{2};
        cmdTxt = sprintf('mc_tbl = mcs.%s_%s;',factor1,factor2); eval(cmdTxt);
        for rr = 1:size(combs,1)
            row1 = combs(rr,1); row2 = combs(rr,2);
            with_level_1_1 = est_margmean{row1,1};
            with_level_2_1 = est_margmean{row1,2};
            w12_1 = categorical(with_level_1_1).*categorical(with_level_2_1);

            with_level_1_2 = est_margmean{row2,1};
            with_level_2_2 = est_margmean{row2,2};
            w12_2 = categorical(with_level_1_2).*categorical(with_level_2_2);
            
            tmc = mc_tbl;
            value_to_check = w12_1; row_col1 = tmc{:,1}==value_to_check;
            value_to_check = w12_2; row_col2 = tmc{:,2}==value_to_check;
            rowN = find(row_col1 & row_col2);
            p(rr) = tmc{rowN,5};
        end
    end
end
out.mcs.combs = combs;
out.mcs.p = p;
out.mcs.h = p<0.05;

out.sig_mcs.combs = combs;
out.sig_mcs.p = p;
out.sig_mcs.h = p<0.05;

function sig_mcs = find_sig_mcs(mcs)

field_names = fields(mcs);
for ii = 1:length(field_names)
    cmdTxt = sprintf('thisTable = mcs.%s;',field_names{ii});
    eval(cmdTxt);
    if strcmp(thisTable.Properties.VariableNames{3},'Difference')
        sig_thisTable = find_sig_mctbl(thisTable,5);
    else
        sig_thisTable = find_sig_mctbl(thisTable,6);
    end
    cmdTxt = sprintf('sig_mcs.%s = sig_thisTable;',field_names{ii});
    eval(cmdTxt);
end


% 
% function out = repeatedMeasuresAnova(between,within,varargin)
% 
% 
% % p = inputParser;
% % addRequired(p,'between',@isnumeric);
% % addOptional(p,'dimension',1,@isnumeric);
% % addOptional(p,'decimal_places',3,@isnumeric);
% % addOptional(p,'do_mean','Yes');
% % parse(p,between,varargin{:});
% % 
% % dimension = p.Results.dimension;
% % decimal_places = p.Results.decimal_places;
% 
% 
% b_varNames = between.Properties.VariableNames;
% w_varnames = within.Properties.VariableNames;
% 
% number_bet_factors = 0;
% for ii = 1:length(b_varNames)
%     cmdTxt = sprintf('colClass = class(between.%s);',b_varNames{ii});
%     eval(cmdTxt);
%     if strcmp(colClass,'categorical')
%         number_bet_factors = number_bet_factors + 1;
%         between_factors{number_bet_factors} = b_varNames{ii};
%     end
% end
% number_wit_factors = size(within,2);
% within_factors = within.Properties.VariableNames;
% n=0;
% %%
% if number_bet_factors == 0 && number_wit_factors == 1
%     wilk_text = '';
%     for ii = 1:size(between,2)
%         wilk_text = [wilk_text b_varNames{ii} ','];
%     end
%     wilk_text(end) = '~';
%     wilk_text = [wilk_text '1'];
%     rm = fitrm(between,wilk_text);
%     rm.WithinDesign = within;
%     rm.WithinModel = within_factors{1};
%     out.rm = rm;
%     out.mauchly = mauchly(rm);
%     out.ranova = rm.ranova('WithinModel',rm.WithinModel);
%     for ii = 1:length(within_factors)
%         nameOfVariable = sprintf('mc_%s',within_factors{ii});
%         rhs = sprintf('find_sig_mctbl(multcompare(rm,within_factors{ii},''ComparisonType'',''bonferroni''),5);');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%     end
%     eval(sprintf('mc_within = %s;',nameOfVariable));
%     est_margmean = margmean(rm,{within_factors{1}});
%     combs = nchoosek(1:size(est_margmean,1),2); p = ones(size(combs,1),1);
%     if ~isempty(mc_within)
%         for ii = 1:size(mc_within,1)
%             num1 = mc_within{ii,1};
%             num2 = mc_within{ii,2};
%             ind = find(ismember(categorical(combs),[num1,num2],'rows'));
%             p(ind) = mc_within{ii,5};
%         end
%     end
%     eval(sprintf('out.%s = %s;',nameOfVariable,nameOfVariable));
%     [~,sem] = findMeanAndStandardError(between{:,:});
%     cemm = size(est_margmean,2);
%     est_margmean{:,cemm+1} = sem';
%     est_margmean.Properties.VariableNames{cemm+1} = 'Formula_StdErr';
%     out.est_marginal_means = est_margmean;
%     out.combs = combs;
%     out.p = p;
%     return;
% end
% %%
% if number_bet_factors == 1 && number_wit_factors == 1
%     wilk_text = '';
%     for ii = 2:size(between,2)
%         wilk_text = [wilk_text b_varNames{ii} ','];
%     end
%     wilk_text(end) = '~';
%     wilk_text = [wilk_text between_factors{1}];
%     rm = fitrm(between,wilk_text);
%     rm.WithinDesign = within;
%     rm.WithinModel = within_factors{1};
%     out.rm = rm;
%     out.mauchly = mauchly(rm);
%     out.ranova = rm.ranova('WithinModel',rm.WithinModel);
%     mc_between_by_within = find_sig_mctbl(multcompare(rm,between_factors{1},'By',within_factors{1},'ComparisonType','bonferroni'),6);
%     mc_within_by_between = find_sig_mctbl(multcompare(rm,within_factors{1},'By',between_factors{1},'ComparisonType','bonferroni'),6);
%     mc_between = find_sig_mctbl(multcompare(rm,between_factors{1},'ComparisonType','bonferroni'),5);
%     mc_within = find_sig_mctbl(multcompare(rm,within_factors{1},'ComparisonType','bonferroni'),5);
%     est_margmean = margmean(rm,{between_factors{1},within_factors{1}});
%     combs = nchoosek(1:size(est_margmean,1),2); p = ones(size(combs,1),1);
%     if ~isempty(mc_between_by_within)
%         for ii = 1:size(mc_between_by_within,1)
%             wit = mc_between_by_within{ii,1};
%             bet1 = mc_between_by_within{ii,2};
%             num1 = find(ismember(est_margmean{:,1:2},[bet1,wit],'rows'));
%             bet2 = mc_between_by_within{ii,3};
%             num2 = find(ismember(est_margmean{:,1:2},[bet2,wit],'rows'));
%             ind = find(ismember(combs,[num1,num2],'rows'));
%             p(ind) = mc_between_by_within{ii,6};
%         end
%     end
%     if ~isempty(mc_within_by_between)
%         for ii = 1:size(mc_within_by_between,1)
%             bet = mc_within_by_between{ii,1};
%             wit1 = mc_within_by_between{ii,2};
%             num1 = find(ismember(est_margmean{:,1:2},[bet,wit1],'rows'));
%             wit2 = mc_within_by_between{ii,3};
%             num2 = find(ismember(est_margmean{:,1:2},[bet,wit2],'rows'));
%             ind = find(ismember(combs,[num1,num2],'rows'));
%             p(ind) = mc_within_by_between{ii,6};
%         end
%     end
%     out.mc_between = mc_between;
%     out.mc_within = mc_within;
%     out.mc_between_by_within = mc_between_by_within;
%     out.mc_within_by_between = mc_within_by_between;
%     cemm = size(est_margmean,2);
%     est_margmean{:,cemm+1} = NaN(size(est_margmean,1),1);
%     for rr = 1:size(est_margmean,1)
%         group_val = est_margmean{rr,1};
%         with_level = est_margmean{rr,2};
%         all_bet_vals = between{:,1};
%         col_num = find(within{:,1} == with_level)+1;
%         values = between{all_bet_vals == group_val,col_num};
%         est_margmean{rr,cemm+1} = std(values)/sqrt(length(values));
%     end
%     est_margmean.Properties.VariableNames{cemm+1} = 'Formula_StdErr';
%     out.est_marginal_means = est_margmean;
%     out.combs = combs;
%     out.p = p;
%     return;
% end
% %%
% if number_bet_factors == 1 && number_wit_factors == 2
%     wilk_text = '';
%     for ii = 2:size(between,2)
%         wilk_text = [wilk_text between.Properties.VariableNames{ii} ','];
%     end
%     wilk_text(end) = '~';
%     wilk_text = [wilk_text between_factors{1}];
%     
%     rm = fitrm(between,wilk_text);
%     cmdTxt = sprintf('within.%s_%s = within.%s.*within.%s;',within_factors{1},within_factors{2},within_factors{1},within_factors{2});
%     eval(cmdTxt);
%     within_factors = within.Properties.VariableNames;
% %     for ii = 0:3
% %         cmdTxt = sprintf('within.%s_%s_%d = within.%s.*circshift(within.%s,-ii);',within_factors{3},within_factors{3},ii,within_factors{3},within_factors{3});
% %         eval(cmdTxt);
% %         within_factors = within.Properties.VariableNames;
% %     end
%     
%     rm.WithinDesign = within;
%     rm.WithinModel = [within_factors{1} '*' within_factors{2}];
%     out.rm = rm;
%     out.mauchly = mauchly(rm);
%     out.ranova = rm.ranova('WithinModel',rm.WithinModel);
%     est_margmean = margmean(rm,{between_factors{1},within_factors{1},within_factors{2}});
%     grp_stats = grpstats(rm,{between_factors{1},within_factors{1},within_factors{2}});
%     combs = nchoosek(1:size(est_margmean,1),2); p = ones(size(combs,1),1);
%     cemm = size(grp_stats,2);
%     grp_stats{:,cemm+1} = grp_stats.std./sqrt(grp_stats.GroupCount);
%     grp_stats.Properties.VariableNames{cemm+1} = 'StdErr';
%     out.grp_stats = grp_stats;
%     cemm = size(est_margmean,2);
%     est_margmean{:,cemm+1} = grp_stats{:,end};
%     est_margmean.Properties.VariableNames{cemm+1} = 'Formula_StdErr';
%     out.est_marginal_means = est_margmean;
%     
%     ii = 1;
%     nameOfVariable = sprintf('out.mc_%s',between_factors{ii});
%     rhs = sprintf('find_sig_mctbl(multcompare(rm,between_factors{ii},''ComparisonType'',''bonferroni''),5);');
%     cmdTxt = sprintf('%s = %s',nameOfVariable,rhs); eval(cmdTxt)
%     for ii = 1:length(within_factors)
%         nameOfVariable = sprintf('out.mc_%s',within_factors{ii});
%         rhs = sprintf('find_sig_mctbl(multcompare(rm,within_factors{ii},''ComparisonType'',''bonferroni''),5);');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%         nameOfVariable = sprintf('out.mc_%s_by_%s',between_factors{1},within_factors{ii});
%         rhs = sprintf('find_sig_mctbl(multcompare(rm,between_factors{1},''By'',within_factors{ii},''ComparisonType'',''bonferroni''),6);');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%         nameOfVariable = sprintf('out.mc_%s_by_%s',within_factors{ii},between_factors{1});
%         rhs = sprintf('find_sig_mctbl(multcompare(rm,within_factors{ii},''By'',between_factors{1},''ComparisonType'',''bonferroni''),6);');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%     end
%     
%     for ii = 1:length(within_factors)
%         nameOfVariable = sprintf('out.mco_%s',within_factors{ii});
%         rhs = sprintf('multcompare(rm,within_factors{ii},''ComparisonType'',''bonferroni'');');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%         nameOfVariable = sprintf('out.mco_b_by_w_%d',ii);
%         rhs = sprintf('multcompare(rm,between_factors{1},''By'',within_factors{ii},''ComparisonType'',''bonferroni'');');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%         nameOfVariable = sprintf('out.mco_w_by_b_%d',ii);
%         rhs = sprintf('multcompare(rm,within_factors{ii},''By'',between_factors{1},''ComparisonType'',''bonferroni'');');
%         cmdTxt = sprintf('%s = %s;',nameOfVariable,rhs); eval(cmdTxt)
%     end
%     mc_w_by_b = out.mco_w_by_b_3;
%     mc_b_by_w = out.mco_b_by_w_3;
%     for rr = 1:size(combs,1)
%         row1 = combs(rr,1); row2 = combs(rr,2);
%         group_val_1 = est_margmean{row1,1};
%         with_level_1_1 = est_margmean{row1,2};
%         with_level_2_1 = est_margmean{row1,3};
%         w12_1 = categorical(with_level_1_1).*categorical(with_level_2_1);
%         
%         group_val_2 = est_margmean{row2,1};
%         with_level_1_2 = est_margmean{row2,2};
%         with_level_2_2 = est_margmean{row2,3};
%         w12_2 = categorical(with_level_1_2).*categorical(with_level_2_2);
%         
%         disp([group_val_1 w12_1 group_val_2 w12_2])
%         
%         if group_val_1 == group_val_2
%             all_g_vals = mc_w_by_b{:,1};
%             tmc = mc_w_by_b(all_g_vals == group_val_1,2:end);
%             value_to_check = w12_1; row_col1 = tmc{:,1}==value_to_check;
%             value_to_check = w12_2; row_col2 = tmc{:,2}==value_to_check;
%             rowN = find(row_col1 & row_col2);
%             p(rr) = tmc{rowN,5};
%         else
%             if w12_1 == w12_2
%                 all_w12 = mc_b_by_w{:,1};
%                 tmc = mc_b_by_w(all_w12 == w12_1,2:end);
%                 value_to_check = group_val_1; row_col1 = tmc{:,1}==value_to_check;
%                 value_to_check = group_val_2; row_col2 = tmc{:,2}==value_to_check;
%                 rowN = find(row_col1 & row_col2);
%                 p(rr) = tmc{rowN,5};
%             else
%                 n = 0;
%             end
%         end
%     end
%     out.combs = combs;
%     out.p = p;
%     return;
% end