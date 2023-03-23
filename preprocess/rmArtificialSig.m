%remove stim artificial sigs
function nW = rmArtificialSig(W,range)
    if (nargin<2)
        range = [-4.5,-2.5];
    end
    Ts = [-getPreTimeInms:1/getFs*1000:getObserveWin];
    rmInd1 = find(Ts>range(1));
    rmI1 = rmInd1(1);

    rmInd2 = find(Ts<range(2));
    rmI2 = rmInd2(end);
    W(rmI1:rmI2) = nan;
    W(rmI1-(0.5/1000*getFs):rmI2+(0.5/1000*getFs))=smooth( W(rmI1-(0.5/1000*getFs):rmI2+(0.5/1000*getFs)));
    %figure;plot(W)
    nW = W-mean(W);
end

    