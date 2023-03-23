clear;
clc;

filename = '20220303';

rootdir = 'D:\data\Gao-CaoJian\';
cd([rootdir,'data\MEP\',filename]);
addpath(genpath([rootdir,'\Program']));

file = 'T1-Bi-2Hztrains - 0.1msDuration-5000uA.btn';
eventdata = readBTNevent(file);
spikedata = readBTNspike(file);
EMGraw = readBTNdata(file);
setFs(30000);

% Spikes = spikedata.gains
EMGdata = EMGraw.data([1:16]);
EMGspike = spikedata.data([1:16]);
clear  EMGraw  

%clearvars EMGraw eventdata GS TA Spikes Emg

NameBNT = file(1:length(file)-4);
mkdir(NameBNT)
cd(NameBNT)

n = 1;
maxfigure;
for n = 1:size(EMGdata,2)
    subplot(4,4,n)
    plot(EMGdata{n})
    title(string(n))
end

NO = [7,9,13,15];
Emgs = EMGdata(NO);

wave = Emgs{3};
range = [1,1000];
%mkdir(strcat('Ch',string(NO(i))))
%cd(strcat('Ch',string(NO(i))))
Eseq = FFTfiltering_MEP2(wave,range);

%% find label
[m,p] = max(Eseq);
x = floor(p/(2*getFs));
TStim = [p-x*2*getFs:2*getFs:p-2*getFs,p:2*getFs:length(Eseq)]./getFs*1000;

%LabelCh = 1;
%TStim = eventdata.tsevs{LabelCh}.*1000;% in ms
%TStim = TStim-8.8333;
writematrix(TStim,'TStim.txt')
TimeInms = 500;

run('MEP_PlotWaveCI2')
writematrix(data,'trialsdata0.txt')

trials = data(3.*(1:floor(size(data,1)./3)),:);% 10kHz 
Annotation_Matrix = SingleSignelVisual(trials);

load("annotate.mat");
mark = Annotation_Matrix(:,1);
data1 = data(:,find(mark == 1));

mkdir output
cd output
writematrix(data1,"MEPdata2.txt")
data = data1;
run('MEP_PlotWaveCI_ByData3')
CI = readmatrix('MEPCI95.xls');
PPrange = CI(intersect(find(CI(:,1)>10),find(CI(:,1)<40)),2);
max(PPrange)-min(PPrange)
close all
cd ../

cd ../


