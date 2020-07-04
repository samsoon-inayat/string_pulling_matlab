function metaAnalysis_ica

variablesToGetFromBase = {'ics_b','ics_w','config_b','config_w','fd_ent_b','fd_ent_w','pdfFolder'};
for ii = 1:length(variablesToGetFromBase)
    cmdTxt = sprintf('%s = evalin(''base'',''%s'');',variablesToGetFromBase{ii},variablesToGetFromBase{ii});
    eval(cmdTxt);
end
%%
runthis = 0;
if runthis
an_b = 1; an_w = 1;
viewFrames_ICs(config_b{an_b},ics_b{an_b},{pdfFolder,'ics_b_frames'});
viewFrames_ICs(config_w{an_w},ics_w{an_w},{pdfFolder,'ics_w_frames'});
return;
end
%%
runthis = 1;
if runthis
viewICs_min_max(config_b{1},ics_b{1},{pdfFolder,'ics_b'});
viewICs_min_max(config_w{1},ics_w{1},{pdfFolder,'ics_w'});
return;
end

%%
runthis = 0;
if runthis == 1
ds_types_vars = {'Img','Motion'};
ds_types = {'Max-IC-Position','Max-IC-Speed'};
fes = get_2d_image_xics(fd_ent_b,fd_ent_w,ds_types_vars,{'Max IC'});
n = 0;

maxY = 12; ySpacing = 0.5; params = {'ENT',maxY ySpacing};
[hf,ha] = param_figure(1000,[12 8 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Spatial Entropy'});changePosition(ylh,[0.1 1 0])
changePosition(ha,[0.02 -0.02 -0.01 -0.01]);
ylim([4 maxY]);
legs = {'Black mice (N = 5)','White mice (N = 5)',[0.5 0.5 maxY 1.5]};
putLegend(ha,legs,'colors',{'k','b'},'sigR',{[],'','k',6},'lineWidth',5);
save_pdf(hf,pdfFolder,'PC Ent',600);

maxY = 1.7; ySpacing = 0.1; params = {'FD',maxY ySpacing};
[hf,ha] = param_figure(1001,[12 5 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Hausdorff FD'});changePosition(ylh,[-0.4 0.67 0]);
changePosition(ha,[0.1 -0.02 -0.015 -0.01]);
ylim([1.4 maxY]);
save_pdf(hf,pdfFolder,'PC FD',600);

maxY = 0.05; ySpacing = 0.01; params = {'SN',maxY ySpacing};
[hf,ha] = param_figure(1002,[12 2 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Shaprness'});changePosition(ylh,[0.1 0 0])
changePosition(ha,[0.1 -0.02 -0.02 -0.01]);
ylim([0.01 maxY]);
save_pdf(hf,pdfFolder,'PC SN',600);
return;
end

%%
runthis = 0;
if runthis == 1
ds_types_vars = {'Img','Motion'};
ds_types = {'Min-IC-Position','Min-IC-Speed'};
fes = get_2d_image_xics(fd_ent_b,fd_ent_w,ds_types_vars,{'Min IC'});
n = 0;

maxY = 12; ySpacing = 0.5; params = {'ENT',maxY ySpacing};
[hf,ha] = param_figure(1000,[12 8 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Spatial Entropy'});changePosition(ylh,[0.1 2.5 0])
changePosition(ha,[0.08 -0.02 -0.01 -0.01]);
ylim([4 maxY]);
legs = {'Black mice (N = 5)','White mice (N = 5)',[0.5 0.5 maxY 1.5]};
putLegend(ha,legs,'colors',{'k','b'},'sigR',{[],'','k',6},'lineWidth',5);
save_pdf(hf,pdfFolder,'PC Ent',600);

maxY = 1.9; ySpacing = 0.1; params = {'FD',maxY ySpacing};
[hf,ha] = param_figure(1001,[12 5 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Hausdorff FD'});changePosition(ylh,[-0.4 0.67 0]);
changePosition(ha,[0.1 -0.02 -0.015 -0.01]);
ylim([1.4 maxY]);
save_pdf(hf,pdfFolder,'PC FD',600);

maxY = 0.05; ySpacing = 0.01; params = {'SN',maxY ySpacing};
[hf,ha] = param_figure(1002,[12 2 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Shaprness'});changePosition(ylh,[0.1 0 0])
changePosition(ha,[0.1 -0.02 -0.02 -0.01]);
ylim([0.01 maxY]);
save_pdf(hf,pdfFolder,'PC SN',600);
return;
end
%%
runthis = 1;
if runthis == 1
ds_types_vars = {'Img','Motion'};
ds_types = {'Max-IC-Position','Max-IC-Speed'};
fes = get_2d_image_xics(fd_ent_b,fd_ent_w,ds_types_vars,{'Max IC-PC'});
n = 0;

maxY = 12; ySpacing = 0.5; params = {'ENT',maxY ySpacing};
[hf,ha] = param_figure(1000,[12 8 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Spatial Entropy'});changePosition(ylh,[0.1 1 0])
changePosition(ha,[0.02 -0.02 -0.01 -0.01]);
ylim([4 maxY]);
legs = {'Black mice (N = 5)','White mice (N = 5)',[0.5 0.5 maxY 1.5]};
putLegend(ha,legs,'colors',{'k','b'},'sigR',{[],'','k',6},'lineWidth',5);
save_pdf(hf,pdfFolder,'PC Ent',600);

maxY = 1.7; ySpacing = 0.1; params = {'FD',maxY ySpacing};
[hf,ha] = param_figure(1001,[12 5 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Hausdorff FD'});changePosition(ylh,[-0.4 0.67 0]);
changePosition(ha,[0.1 -0.02 -0.015 -0.01]);
ylim([1.4 maxY]);
save_pdf(hf,pdfFolder,'PC FD',600);

maxY = 0.05; ySpacing = 0.01; params = {'SN',maxY ySpacing};
[hf,ha] = param_figure(1002,[12 2 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Shaprness'});changePosition(ylh,[0.1 0 0])
changePosition(ha,[0.1 -0.02 -0.02 -0.01]);
ylim([0.01 maxY]);
save_pdf(hf,pdfFolder,'PC SN',600);
return;
end

%%
runthis = 1;
if runthis == 1
ds_types_vars = {'Img','Motion'};
ds_types = {'Min-IC-Position','Min-IC-Speed'};
fes = get_2d_image_xics(fd_ent_b,fd_ent_w,ds_types_vars,{'Min IC-PC'});
n = 0;

maxY = 10; ySpacing = 0.5; params = {'ENT',maxY ySpacing};
[hf,ha] = param_figure(1000,[12 8 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Spatial Entropy'});changePosition(ylh,[0.1 1.5 0])
changePosition(ha,[0.08 -0.02 -0.01 -0.01]);
ylim([4 maxY]);
legs = {'Black mice (N = 5)','White mice (N = 5)',[0.5 0.5 maxY 1]};
putLegend(ha,legs,'colors',{'k','b'},'sigR',{[],'','k',6},'lineWidth',5);
save_pdf(hf,pdfFolder,'PC Ent',600);

maxY = 1.9; ySpacing = 0.1; params = {'FD',maxY ySpacing};
[hf,ha] = param_figure(1001,[12 5 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Hausdorff FD'});changePosition(ylh,[-0.4 0.67 0]);
changePosition(ha,[0.1 -0.02 -0.015 -0.01]);
ylim([1.4 maxY]);
save_pdf(hf,pdfFolder,'PC FD',600);

maxY = 0.05; ySpacing = 0.01; params = {'SN',maxY ySpacing};
[hf,ha] = param_figure(1002,[12 2 1.5 1],ds_types,fes,params);
set(gca,'FontSize',7,'FontWeight','Bold','TickDir','out');
xlh = xlabel(''); ylh = ylabel({'Shaprness'});changePosition(ylh,[0.1 0 0])
changePosition(ha,[0.1 -0.02 -0.02 -0.01]);
ylim([0.01 maxY]);
save_pdf(hf,pdfFolder,'PC SN',600);
return;
end
