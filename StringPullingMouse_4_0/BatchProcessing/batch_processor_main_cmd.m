% clear all
clc
mainFolder = 'G:\OneDrives\OneDrive\Data\String_Pulling\Surjeet';
pdfFolder = 'G:\OneDrives\OneDrive\Data\String_Pulling\Surjeet\pdfs';
mainFolder = 'E:\Users\samsoon.inayat\OneDrive - University of Lethbridge\Data\StringPulling\Surjeet';
pdfFolder = 'E:\Users\samsoon.inayat\OneDrive - University of Lethbridge\Data\StringPulling\Surjeet\pdfs';

dataFolders = {'Pantomime_OLD_Whole_body';'Pantomime_PARK_Whole_body';'Real_OLD_Whole_body';'REAL_PARK_Whole_body'};
metaFiles = {'vid_name_range (1).mat';'vid_name_range (1).mat';'vid_name_range.mat';'vid_name_range.mat'};
dii = 4;
data_folder = fullfile(mainFolder,dataFolders{dii});
filename = fullfile(data_folder,metaFiles{dii});

file_list = load(filename);
vid_files = file_list.vid_name_range;

for ii = 1:length(vid_files)
    files_to_process{ii} = vid_files(ii).name;
end
files_to_process_indices = 1:length(files_to_process);
image_resize_factor = 4; imrf = image_resize_factor; % define both variables because both are being used in different files
readConfigs = 0; setEpochs = 0; defineZoomWindows = 0; defineZoomWindowsICA = 1; miscFunc = 0; processData = 1;
%% Load Config Files
if readConfigs
    for ii = 1:length(vid_files)
        pd_folder = fullfile(data_folder,sprintf('%s_processed_data',files_to_process{ii}(1:(end-4))));
        config = get_config_file(pd_folder);
        [success,d] = load_meta_data(config);
        config.md = d;
        config.file_name = files_to_process{ii};
        config.file_path = data_folder;
        config_info{ii} = config;
    end
    return;
end

%% set Epochs
if setEpochs
    for ii = 1:length(vid_files)
        config = config_info{ii};
        data = {vid_files(ii).startstopF(1),vid_files(ii).startstopF(2)};
        setParameter(config,'Epochs',data);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        config_info{ii} = config;
    end
    return;
end

%% defining zoom windows
if defineZoomWindows
    for ii = 1:length(vid_files)
        if ~ismember(files_to_process_indices,ii)
            continue;
        end
%         ii =  1;
        config = config_info{ii}; config1 = config;
        [sfn,efn] = getFrameNums(config);
        [success,config.data] = load_data(config,sfn:efn);
        [success,config1.data] = load_data(config,1:5);
        no_gui_set_zoom_window_manually(config1,1);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        zw = getParameter(config,'Auto Zoom Window');
        zw = [zw(1)-100 zw(2)-200 zw(3)+100 zw(4)];
        if zw(1) < 0
            zw(1) = 1;
        end
        if zw(2) < 0
            zw(2) = 1;
        end
        if zw(3) > config1.data.frame_size(2)
            zw(3) = config1.data.frame_size(2);
        end
        if zw(4) > config1.data.frame_size(1)
            zw(4) = config1.data.frame_size(1);
        end
        setParameter(config,'Auto Zoom Window',zw);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        playFrames(config,10);
        no_gui_set_scale(config1,1);
        config = rmfield(config,'data');
        config_info{ii} = config;
        n = 0;
    end
    return;
end

%% defining zoom windows
if defineZoomWindowsICA
    for ii = 1:length(vid_files)
        if ~ismember(files_to_process_indices,ii)
            continue;
        end
%         ii =  1;
        config = config_info{ii}; config1 = config;
        [sfn,efn] = getFrameNums(config);
        [success,config.data] = load_data(config,sfn:efn);
        rfact = 0.125;
        frames = config.data.frames;
        for fn = 1:length(frames)
            fn
            temp = rgb2gray(frames{fn});
%             tempR = imresize(temp,rfact);
            rgbFramesO(:,:,fn) = temp;
        end
        d_rgbFrames = diff(rgbFramesO,1,3);
        md_rgbFrames = max(d_rgbFrames,[],3);
        for fn = 1:size(d_rgbFrames,3)
            fn
            figure(100);clf;imagesc(d_rgbFrames(:,:,fn));axis equal;
            pause(0.1)
        end
        nrows = size(rgbFrames,1); ncols = size(rgbFrames,2); nFrames = size(rgbFrames,3);
        nics = floor(nFrames/2);
        fs = double(reshape(rgbFrames,nrows*ncols,nFrames));
        [pcm.coeff,pcm.score,pcm.latent,pcm.tsquared,pcm.explained,pcm.mu] = pca(fs);
        [Z, W, T, mu] = fastICA(fs',nics,'kurtosis',1);%,type,flag)
        Zp = Z';
        ics = reshape(Zp,nrows,ncols,nics);
        max_ics = max(ics,[],3); max_ics_r = imresize(max_ics,1/rfact);
        min_ics = min(ics,[],3); min_ics_r = imresize(min_ics,1/rfact);
        maxMask = max_ics_r > mean(max_ics_r(:)); minMask = min_ics_r < mean(min_ics_r(:));
        mask = maxMask | minMask; mask = bwconvhull(mask);
        figure(100);clf;imagesc(mask);axis equal;
        
        [success,config1.data] = load_data(config,1:5);
        no_gui_set_zoom_window_manually(config1,1);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        zw = getParameter(config,'Auto Zoom Window');
        zw = [zw(1)-100 zw(2)-200 zw(3)+100 zw(4)];
        if zw(1) < 0
            zw(1) = 1;
        end
        if zw(2) < 0
            zw(2) = 1;
        end
        if zw(3) > config1.data.frame_size(2)
            zw(3) = config1.data.frame_size(2);
        end
        if zw(4) > config1.data.frame_size(1)
            zw(4) = config1.data.frame_size(1);
        end
        setParameter(config,'Auto Zoom Window',zw);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        playFrames(config,10);
        no_gui_set_scale(config1,1);
        config = rmfield(config,'data');
        config_info{ii} = config;
        n = 0;
    end
    return;
end

%% check the epoch frame numbers
for ii = 1:length(vid_files)
    config = config_info{ii};
    [sfn,efn] = getFrameNums(config);
    if vid_files(ii).startstopF(1) == sfn && vid_files(ii).startstopF(2) == efn
        disp(sprintf('%d = good',ii));
    else
        disp(sprintf('%d = bad',ii));
        error
    end
end


%% checking zoom window and epochs
if miscFunc
    for ii = 1:length(vid_files)
        if ~ismember(files_to_process_indices,ii)
            continue;
        end
%         ii =  1;
        config = config_info{ii};
%         winopen(config.pd_folder);
%         [sfn,efn] = getFrameNums(config);
%         [success,temp] = load_data(config);
%         [success,config.data] = load_data(config,sfn:efn);
%         tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        scale(ii) = getParameter(config,'Scale');
        zw(ii,:) = getParameter(config,'Auto Zoom Window');
        
%         playEpoch(config,1,10);
    end
    return;
end


%% Whole Body Analysis
if processData
    find_temporal_xics_options = [1 2 3];%{'Entropy','Higuchi Fractal Dimension','Fano Factor'};
    for ii = 1:length(vid_files)
        if ~ismember(files_to_process_indices,ii)
            continue;
        end
        config = config_info{ii};
        [success,config.data] = load_data(config);
        tconfig = get_config_file(config.pd_folder); config.names = tconfig.names; config.values = tconfig.values;
        estimate_motion(config);
        descriptive_statistics(config);
        find_temporal_xics(config);
        find_PCs(config);
        find_ICs(config);
        find_fractal_dimensions_and_entropy(config);
        clear config;
    end
end
