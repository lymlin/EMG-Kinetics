
stimartifact = intersect(find(Ts>-2),find(Ts<2));
data0(stimartifact,:) = 0.01*data0(stimartifact,:);
stimartifact1 = intersect(find(Ts>=3),find(Ts<10));
data0(stimartifact1,:) = [0.01:0.09/(length(stimartifact1)-1):0.1]'.*data0(stimartifact1,:);
stimartifact12 = intersect(find(Ts>=10),find(Ts<14));
data0(stimartifact12,:) = [0.1:0.3/(length(stimartifact12)-1):0.4]'.*data0(stimartifact12,:);
stimartifact2 = intersect(find(Ts>-5),find(Ts<16));
data0(setdiff(stimartifact2,union(stimartifact,union(stimartifact1,stimartifact12))),:) = nan;
%data0(stimartifact2,:) = fillmissing(data0(stimartifact2,:),'movmedian',20);
data0(stimartifact2,:) = fillmissing(data0(stimartifact2,:),'linear');
stimartifact3 = intersect(find(Ts>5),find(Ts<19));
data0(stimartifact3,:) = smoothdata(data0(stimartifact3,:),'movmean',200);
data0 = smoothdata(data0,'gaussian',200);
% SingleSignalVisual(data0,[-50,150],[-1.5,1.5])
