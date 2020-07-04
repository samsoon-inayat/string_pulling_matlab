function offline_processing

variablesToGetFromBase = {'pdfFolder','config_b','config_w','frames_b','frames_w'};
for ii = 1:length(variablesToGetFromBase)
    cmdTxt = sprintf('%s = evalin(''base'',''%s'');',variablesToGetFromBase{ii},variablesToGetFromBase{ii});
    eval(cmdTxt);
end

%%

allProcessingFunctions = {'descriptive_statistics','find_temporal_xics','find_PCs','find_ICs','find_fractal_dimensions_and_entropy'};
sel = [4 5]; sel_bw = [1 1]; animal_numbers = [1:5];
selectProcessingFunctions = allProcessingFunctions(sel);
tic
for iii = 1:length(animal_numbers)
    ii = animal_numbers(iii)
    if sel_bw(1) == 1
        config = config_b{ii};
        [sfn,efn] = getFrameNums(config);    
        runFunctions(selectProcessingFunctions,config,sfn,efn);
    end
    if sel_bw(2) == 1
        config = config_w{ii};
        [sfn,efn] = getFrameNums(config);
        runFunctions(selectProcessingFunctions,config,sfn,efn);
    end
end
time_taken = toc
% save('Time_Taken_offline_processing.mat','time_taken');


function runFunctions(pfs,config,sfn,efn)
for jj = 1:length(pfs)
    if strcmp(pfs{jj},'find_fractal_dimensions_and_entropy')
        cmdTxt = sprintf('%s(config);',pfs{jj})
    else
        cmdTxt = sprintf('%s(config,sfn:efn);',pfs{jj})
    end
    eval(cmdTxt);
end
