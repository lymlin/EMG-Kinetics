function FilteredW1=WPdenoiseSSEP(W)
    %% WPSVM: 
    J = 7; % layer
    WNAME = 'db2';
    wpt = wpdec(W,J,WNAME); 
    
    nodes=get(wpt,'tn');   %第J层的节点号 
    ord=wpfrqord(nodes);  %小波包系数重排，ord是重排后小波包系数索引构成的矩阵
    nodes_freqord=nodes(ord); %按照频率重排后的小波节点数

    BLcoef = [];
    k = 1;
    for k = 1:length(nodes_freqord)
        BLcoef = [BLcoef,wpcoef(wpt,nodes_freqord(k))];
    end

   % dF = 1/2*getFs/power(2,J);
    %dT = length(W)/getFs*1000/(length(W)/power(2,J));
    %sprintf('Frequency resolution: %2f Hz',dF)
   %sprintf('Time resolution: %2f ms',dT)
    y(1) = 0;

    %% 重构 WP tree 
    wpt2 = wpt;
    y2 = y; 
    threshfu = BLcoef;
    threshfu(:,find(y2==0)) = 0;

    for i=1:length(nodes)
        wpt2 = write(wpt2,'cfs',nodes_freqord(i),threshfu(:,i));
    end

    FilteredW1 = wprec(wpt2);
    
end
 
