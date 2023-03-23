function Out = StatisticOut_SSEP(W)
    
    sig = W(getPreTimeInms/1000*getFs+15/1000*getFs:getPreTimeInms/1000*getFs+50/1000*getFs);
    
    PPV = range(sig);

    [m,p] = min(sig);
    P = p + getPreTimeInms/1000*getFs+15/1000*getFs;
    Pindx1 = find(W(1:P)>=0);
    TPx = p/getFs*1000 + 15;
    latency = Pindx1(end)- getPreTimeInms/1000*getFs;

    latencyInms = latency/getFs*1000;

    [m2,p2] = max(sig);
    P2 = p2 + getPreTimeInms/1000*getFs+15/1000*getFs;
    Pindx2 = find(W(P:end)<=0);
    T2 = Pindx2(1);
    dT = (Pindx2(1) - Pindx1(end) +1)/getFs*1000;


    noi = W((getPreTimeInms+80)/1000*getFs:(getPreTimeInms+100)/1000*getFs);
    PPVnoi = range(noi);
    SNR = PPV/PPVnoi;
    adjPPVbyPPVnoi = PPV - PPVnoi;

    abs_W = abs(W);
    abs_sig = abs_W(getPreTimeInms/1000*getFs+15/1000*getFs:getPreTimeInms/1000*getFs+50/1000*getFs);
    Amplitude = max(abs_sig);
    noi2 = abs_W((getPreTimeInms+80)/1000*getFs:(getPreTimeInms+100)/1000*getFs);
    SDnoi = std(noi2);
    adjPPVbySDnoi = Amplitude - 2*SDnoi;
    
    Out = [PPV;latencyInms;TPx;PPVnoi;SNR;adjPPVbyPPVnoi;adjPPVbySDnoi;Amplitude;SDnoi];

end
