function find_ears(handles,fn)
set(handles.pushbutton_stop_processing,'userdata',fn);
frames = get_frames(handles);
thisFrame = frames{fn};
M = populateM(handles,thisFrame,fn);
thisFrame = M.thisFrame;
% masksMap = {'body','ears','hands','nose','string'};
% Ie = get_masks(handles,fn,2);
string_thickness = floor((getParameter(handles,'String Thickness in Pixels')/2));
% Ie = find_mask_grid_way(handles,thisFrame,getColors(handles,'Ears',4:6,0),string_thickness,0.5);
Ie = get_mask(handles,fn,'ears');

Cs{1} = getRegions(handles,fn,'body',1);
if isempty(Cs{1})
    displayMessageBlinking(handles,sprintf('Can not find ears in frame %d ... find body first',fn),{'ForegroundColor','r'},2);
    return;
end
try
    Cs{2} = getRegions(handles,fn-1,'right ear');
    Cs{3} = getRegions(handles,fn-1,'left ear');
catch
    Cs{2} = [];
    Cs{3} = [];
end

if isempty(Cs{2}) & isempty(Cs{3})
    firstFrame = 1;
else
    firstFrame = 0;
end
if ~firstFrame
    M.sRight = Cs{2};
    M.sLeft = Cs{3};
end
MAx = Cs{1}.MajorAxisLength;
mAx = Cs{1}.MinorAxisLength;
ec = str2double(get(handles.edit_expansion_compression_ratio,'String'));

if MAx/mAx > 1.3
    if ec ==1
        Ie1 = Ie&~Cs{1}.cIn;
    else
        Ie1 = Ie&~expandOrCompressMask(Cs{1}.cIn,ec);
    end
else
    Ie1 = Ie;
end
Ih = imfill(Ie1,'holes');
Ih = bwareaopen(Ih,str2double(get(handles.edit_smallest_area_to_neglect_ears,'String')),8);
Ih = bwconvhull(Ih,'objects');
s_r1 = findRegions(Ih,str2double(get(handles.edit_smallest_area_to_neglect_ears,'String')));
plotStringAndRegions(100,thisFrame,[],M,{s_r1},[]);
pause(0.15);

Cm = Cs{1};
if Cm.Orientation < 0
    x = Cm.Major_axis_xs(1);
    y = Cm.Major_axis_ys(1);
else
    x = Cm.Major_axis_xs(2);
    y = Cm.Major_axis_ys(2);
end
if get(handles.checkbox_check_relationship_regions_ears,'Value')
    centroids = getRegionValues(s_r1,'Centroid');
    inds = centroids(:,2) > (Cm.Centroid(2) - abs((y-Cm.Centroid(2))/4)) | centroids(:,2) < (y-abs((y-Cm.Centroid(2))/4));
    s_r1(inds) = [];
    plotStringAndRegions(100,thisFrame,[],M,{s_r1},[]);
    pause(0.15);
end

try
if length(s_r1) > 1
    s_r1 = reduceRegionsBySpatialClusteringEars(M,s_r1);
end
catch
end
plotStringAndRegions(100,thisFrame,[],M,{s_r1},[]);
pause(0.15);
if ~firstFrame
    try
        s_r1 = combineRegionsAcrossString(handles,M,fn,s_r1,[75 9]);
        plotStringAndRegions(100,thisFrame,[],M,{s_r1},[]);
        pause(0.15);
        [dl,ol,bdl] = findDistsAndOverlaps(M,thisFrame,M.sLeft,s_r1);
        [dr,or,bdr] = findDistsAndOverlaps(M,thisFrame,M.sRight,s_r1);
        if sum(or>0.1) == 1
            indR = find(or>0.1);
            C(1) = s_r1(indR);
        end
        if sum(or>0.1) == 2
            [~,sR,~] = combineRegions(s_r1,find(or>0.1),size(thisFrame));
            C(1) = sR;
        end

        if sum(ol>0.1) == 1
            indL = find(ol>0.1);
            C(2) = s_r1(indL);
        end
        if sum(ol>0.1) == 2
            [~,sL,~] = combineRegions(s_r1,find(ol>0.1),size(masks.Ih));
            C(2) = sL;
        end
        if ~isempty(C(1).Centroid)
            C(1).ear = 'Right Ear';
        end
        if length(C) > 1
            if ~isempty(C(2).Centroid)
                C(2).ear = 'Left Ear';
            end
        end
        saveValsEars(handles,M,fn,C,0);
        return;
    catch
        disp('Error during spatial clustering of ear regions in find_centroids function ... continuing without it');
    end
end

s = s_r1;
for ii = 1:length(s)
    distances(ii) = sqrt((s(ii).Centroid(1)-x)^2+(s(ii).Centroid(2)-y)^2);
    areas(ii) = s(ii).Area*M.scale;
    centroidYs(ii) = s(ii).Centroid(2);
end

if ~exist('centroidYs','var')
    C = [];
    return;
end

% find areas greater than 100 to see blobls that are big and of
% importance
inds = find(areas>(10*M.scale));
if isempty(inds)
    C = [];
    return;
end
% find the closest centroid that is on the left for left ear and on the
% right for right ear
for ii = 1:length(inds)
    txs(ii) = s(inds(ii)).Centroid(1);
    tys(ii) = s(inds(ii)).Centroid(2);
end

xindsR = (txs < x & abs(txs-x)>20);
xindsL = (txs > x & abs(txs-x)>20);

if sum(xindsR) == 1 & sum(xindsL) == 1
    C(1) = s(xindsR);
    C(2) = s(xindsL);
else
    indsR = inds(xindsR);
    indsL = inds(xindsL);
    if length(indsR) > 1
        theAreasR = areas(indsR);
        iiR = find(theAreasR == max(theAreasR));
    else
        iiR = 1;
    end
    if length(indsL) > 1
        theAreasL = areas(indsL);
        iiL = find(theAreasL == max(theAreasL));
    else
        iiL = 1;
    end
    if ~isempty(indsR)
        iiR = indsR(iiR);     C(1) = s(iiR);
    end
    if ~isempty(indsL)
         iiL = indsL(iiL);    C(2) = s(iiL);
    end
end
%     sDists = distances(inds);
%     ii = find(sDists == min(sDists));
if ~exist('C','var')
    C = [];
end
C(1).ear = 'Right Ear';
C(2).ear = 'Left Ear';
%     C = findBoundary(C,size(Ie));
try
plotStringAndRegions(100,thisFrame,[],M,{C},[]);
pause(0.15);
catch
end
saveValsEars(handles,M,fn,C,0);



