function ConfidenceInterval95Plot(data,Xrange,YLIMIT)
    if (nargin==2)
        
        YLIMIT = [-0.4,0.4];
    end

    if (nargin==1)
        YLIMIT = [-0.4,0.4];
        Xrange = [-getPreTimeInms,getObserveWin];
    end


TimeInms = Xrange(2);
PreTimeInms = -Xrange(1);

Nt2 = TimeInms/1000*getFs;
Nt1 = PreTimeInms/1000*getFs;
TimeVector = 1/getFs.*[-Nt1:Nt2]*1000; % Unit: ms

CI95 = PlotWaveCI(TimeVector,data);
hold on
plot(zeros(1,10),[1:10])
hold off

xlabel('Time in [ms]')
ylabel('Amplitude in [mV]')

savefig('MEPCI.fig')
print('MEPCI.tif','-dtiffn');
print('MEPCI.svg','-dsvg','-painters');

ylim(YLIMIT)
xlim([-PreTimeInms TimeInms])
savefig('Wave signal 95% CI.fig')
print(strcat('Wave signal 95% CI - ',string(TimeInms),'.tif'),'-dtiffn');
print(strcat('Wave signal 95% CI - ',string(TimeInms),'.svg'),'-dsvg','-painters');

writematrix([TimeVector;CI95]','Wave signal 95% CI.txt');
end

