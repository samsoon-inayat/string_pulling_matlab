function s = spatialClusteringNose(s,frameSize,numClusters,M,varargin)

combs = nchoosek(1:length(s),2);

% s = findBoundary(s,frameSize);
% for ii = 1:size(combs,1)
%     s1 = s(combs(ii,1)); s2 = s(combs(ii,2));
%     s2points = [s2.xb s2.yb];
%     for jj = 1:length(s1.xb)
%         p1 = [s1.xb(jj) s1.yb(jj)];
%         dists(jj) = min(sqrt(sum((s2points - p1).^2,2)));
%     end
%     cdists(ii) = min(dists);
% end
% ind = find(cdists == min(cdists));
% 

for ii = 1:length(s)
    centroids(ii,:) = s(ii).Centroid;
end

options = statset('UseParallel',0);
[cluster_idx, cluster_center] = kmeans(centroids,numClusters,'Options',options,'distance','sqEuclidean','Replicates',6);

uci = unique(cluster_idx);


for ii = 1:length(uci)
    lencis(ii) = sum(cluster_idx == uci(ii));
end

uind = find(lencis == max(lencis));
ucioi = uci(uind);

inds = find(cluster_idx == ucioi);
indc = ismember(combs,inds','rows');
% dist_inds = cdists(indc)*M.scale;
[s1,sC] = combineRegions(s,sort(inds'),frameSize);

if nargin == 5
    s = s1;
    return;
end
if (sC.MajorAxisLength * M.scale) < 8
    plotStringAndRegions(100,[],[],M,{s1,s},[]);
    s = s1;
end
