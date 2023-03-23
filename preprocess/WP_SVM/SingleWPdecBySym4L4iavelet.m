%% Single WP decomposition J = 4, wavelet base 'sym4'
% Input: W(t) = S(t) + N(t) 
% data_matrix = [X,y]
function data_matrix = SingleWPdecBySym4L4iavelet(W)
    J = 7; % layer
    WNAME = 'sym2';
    wpt = wpdec(W,J,WNAME); 
    plot(wpt) 
    savefig(strcat('wavelet packet tree By',string(J),'layer of ',WNAME,'.fig'))
    print(strcat('wavelet packet tree By',string(J),'layer of ',WNAME,'.tif'),'-dtiffn');
    
    wpviewcf(wpt,2);print('Time-Freq-2-Frequency Order.svg','-dsvg','-painters');        %时间频率图
    wpviewcf(wpt,6);print('Time-Freq-6-Natural Order.svg','-dsvg','-painters');        %时间频率图
    
    nodes=get(wpt,'tn');   %第J层的节点号 
    ord=wpfrqord(nodes);  %小波包系数重排，ord是重排后小波包系数索引构成的矩阵
    nodes_freqord=nodes(ord); %按照频率重排后的小波节点数

    BLcoef = [];
    k = 1;
    for k = 1:length(nodes_freqord)
        BLcoef = [BLcoef,wpcoef(wpt,nodes_freqord(k))];
    end

    X = BLcoef';
    %% recommen y

    Sn = [ceil(30/(getFs/2/power(2,J))),ceil(8000/(getFs/2/power(2,J)))];
    dF = 1/2*getFs/power(2,J);
    dT = length(W)/getFs*1000/(length(W)/power(2,J));
    sprintf('Frequency resolution: %2f Hz',dF)
    sprintf('Time resolution: %2f ms',dT)

    Energyk = BLcoef.*BLcoef;
    NoteEnergy = sum(Energyk);
    PercentEnergy = Energyk./NoteEnergy;
    ShanE = - sum(PercentEnergy.*log(PercentEnergy));

    sigsumP = sum(PercentEnergy(floor(getPreTimeInms/dT):ceil((getPreTimeInms+50)/dT),:));
    sigsumPP = sigsumP./sum(sigsumP)*100;
    noisumP = sum(PercentEnergy(ceil((getPreTimeInms+100)/dT):end,:));
    noisumPP = noisumP./sum(noisumP)*100;
    ShanEP = ShanE./sum(ShanE)*100;
    figure
    subplot(3,1,1);bar(nodes_freqord,sigsumPP);xlabel('Note No.');title('信号在整个频率结点中的影响比');
    subplot(3,1,2);bar(nodes_freqord,noisumPP);xlabel('Note No.');title('noise');
    subplot(3,1,3);bar(nodes_freqord,ShanEP);xlabel('Note No.');title('Entropy')
    print('signal-noise weights of wp leaves.tiv','-diffn')

    y = ones(length(nodes_freqord),1);
    y(Sn(2):end) = -1;

    y(find(noisumPP>mean(noisumPP))) = -1;
    y(find(ShanEP == min(ShanEP))) = -1;
    y(find(sigsumPP>mean(sigsumPP))) = 1;
    y(1) = -1;

    wpt2 = wpt;
    y2 = y; 
    threshfu = BLcoef;
    threshfu(:,find(y2<0)) = 0;

    for i=1:length(nodes)
        wpt2 = write(wpt2,'cfs',nodes_ord(i),threshfu(:,i));
    end

   FilteredW = wprec(wpt2);
   close all
   figure;
   subplot(2,1,1);plot(getPreTimeInms:(1/getFs*1000):getObserveWin,W);title('Ori sig')
   subplot(2,1,2);plot(getPreTimeInms:(1/getFs*1000):getObserveWin,FilteredW*1000);title('WPfiltered Sig')

   data_matrix = [X,y];
end

   