    %% WPSVM: 
    J = 7; % layer
    WNAME = 'sym4';
    wpt = wpdec(W,J,WNAME); 
    
    nodes=get(wpt,'tn');   %第J层的节点号 
    ord=wpfrqord(nodes);  %小波包系数重排，ord是重排后小波包系数索引构成的矩阵
    nodes_freqord=nodes(ord); %按照频率重排后的小波节点数

    BLcoef = [];
    k = 1;
    for k = 1:length(nodes_freqord)
        BLcoef = [BLcoef,wpcoef(wpt,nodes_freqord(k))];
    end

    X = BLcoef';
    %% SVM预测参数 

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
    
    y = ones(length(nodes_freqord),1);
    y(Sn(2):end) = 0;
    y(find(noisumPP>mean(noisumPP))) = 0;
    y(find(ShanEP == min(ShanEP))) = 0;
    y(find(sigsumPP>mean(sigsumPP))) = 1;
    y(1) = 0;

    %% 重构 WP tree 
    wpt2 = wpt;
    y2 = y; 
    threshfu = BLcoef;
    threshfu(:,find(y2==0)) = 0;

    for i=1:length(nodes)
        wpt2 = write(wpt2,'cfs',nodes_freqord(i),threshfu(:,i));
    end

    for i=1:length(nodes)
        wpt2 = write(wpt2,'cfs',nodes(i),threshfu(:,i));
    end


    FilteredW1 = wprec(wpt2);
    figure;plot(FilteredW1)
    %% prediction
    data_matrix = [X,y]; 
    writematrix(data_matrix,[rootdir,'SVM_datamatrix.txt'])
    !D:\miniconda3\python.exe ../../../../../Program/SVM_predicting.py 
    predictedy = readmatrix([rootdir,'predictedval.txt']);
    wpt3 = wpt;
    
    threshfu2 = BLcoef;
    threshfu2(:,find(predictedy<0)) = 0;

    for i=1:length(nodes)
        wpt3 = write(wpt3,'cfs',nodes_ord(i),threshfu(:,i));
    end

    FilteredW2 = wprec(wpt3);


    WPSVMdata(tr).Ori = W;
    WPSVMdata(tr).Filtering1 = FilteredW1;    
    WPSVMdata(tr).Predicted = FilteredW2;    
    WPSVMdata(tr).FreqTime_FreqOrdered = BLcoef;
    WPSVMdata(tr).Filtering1_Node_y_FreqOrdered = y;
    WPSVMdata(tr).Predicted_Node_y_FreqOrdered = predictedy;
    
    %% FFT 30-3000滤波获取最终降噪数据

    newsig1 = FFTfreqBandPass(W);
    newsig2 = FFTfreqBandPass(FilteredW1);
    newsig3 = FFTfreqBandPass(FilteredW2);

    WPSVMdata(tr).FFTOri = newsig1;
    WPSVMdata(tr).FFTFiltered1 = newsig2;
    WPSVMdata(tr).FFTWPSVM = newsig3;

    WPSVMdata.wptreeinfo = strcat(WNAME,'_of_layer_',string(J));
 
    
    Q = figure;
    figure;
    subplot(3,2,1);plot(W);title('Ori')
    subplot(3,2,2);plot(newsig1);title('FFT-Ori')
    
    subplot(3,2,3);plot(FilteredW1);title('FilteredW')
    subplot(3,2,4);plot(newsig2);title('FFT-FilteredW')

    subplot(3,2,5);plot(FilteredW1);title('Predicted')
    subplot(3,2,6);plot(newsig3);title('FFT-PredictedW')
    
    %% data output
    print(strcat('DataFilteredOutput(',string(tr),').tif'),'-dtiffn')
