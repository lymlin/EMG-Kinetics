
function data = DataMapping(TStimInms,wave)
% Input: stimulation time point in ms
%        wave: EMG data for analysis
%        
% Output: reshaped data by stimulation trains
%         'MEPCI95.xls' and figures
        ObserveWindowInms = getObserveWin;
        PreTimeInms = getPreTimeInms;

        TStimInms = reshape(TStimInms,[],1);
        Nt2 = ObserveWindowInms/1000*getFs;
        Nt1 = PreTimeInms/1000*getFs;
       
        A1 = 1 + (TStimInms(1)-PreTimeInms<0);
        A2 = 2 + ((TStimInms(end)+ObserveWindowInms)/1000*getFs>length(wave));

        switch(A1*A2)
            case 2
                IndexStim = TStimInms(1:end)/1000*getFs;
            case 3
                IndexStim = TStimInms(1:end-1)/1000*getFs;
            case 4
                IndexStim = TStimInms(2:end)/1000*getFs;
            case 6
                IndexStim = TStimInms(2:end-1)/1000*getFs;
        end

        IndicesStim = [-Nt1:Nt2]+round(IndexStim);
        data = ReshapeDataByIndex(wave,IndicesStim);

end