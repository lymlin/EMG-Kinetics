%% main_train SVM model
% Obtain data source
% config X by wpdec coef
% config y by manual label
% train optimized SVM model (C, gamma)
% save model

clear;
clc;

%% Obtain data
rootdir = 'G:\ZJU\FangAo\';
addpath(genpath([rootdir,'\Program']));

file = 'T3-B-Ch3-1mA-0.5Hz-0.20ms.btn';
dirfile = '20220304-Intact';
cd([rootdir,'data\',dirfile]);

setFs(30000);
setPreTimeInms(100)
setObserveWin(1000)

run("readfile_btnEsig");

NO = 9;

% find label
NOLabel = 14;
wave = EMGdata{NOLabel};
figure;plot((1:length(wave))./getFs,wave);xlabel('Time [s]')
threshold1 = 3;
freq = 0.5; %Stim freq Hz
delT = 1/freq; 
dur = 0.2;%0.2ms duration
        
run("FindTimeStimPindex") %TStimInms
writematrix(TStimInms,'TStim.txt')

% data filtering and find CI
i = 1;
mkdir(strcat('Ch',string(NO(i))))
cd(strcat('Ch',string(NO(i))))
wave = initFFTfilter(EMGdata{NO});
data = DataMapping(TStimInms,wave);
pause(3)
Annotation_Matrix = SingleSignalVisual(data(1:200/1000*getFs,:),[-0.1,0.1]);

load("annotate.mat");
mark = Annotation_Matrix(:,1);
trials = data(:,find(mark == 1));

writematrix(trials,"Wave_trial_Data.txt")
writematrix(trials,[rootdir,'SVMtraining\Wave_trial_Data.txt'])

close all

clear
clc
%%
%% config Xs,ys
rootdir = 'G:\ZJU\FangAo\';
addpath(genpath([rootdir,'\Program']));
cd([rootdir,'\SVMtraining'])
trials = readmatrix([rootdir,'SVMtraining\Wave_trial_Data.txt'])

tr = 1;
DataXys = [];
for trials = 1:size(trials,2)
    data_matrix = SingleWPdecBySym4L4iavelet(W);
    pause(3)
    prompt4 = 'Is the filtered result promising?(1/0)';
    decisionIO = input(prompt4);
    
    if decisionIO == 1
        DataXys = [DataXys;data_matrix];
    end

end
    
writematrix(DataXys,'SVM_datamatrix.txt')

%% 最优C-gamma
!D:\miniconda3\python.exe ../Program/SVM_analysis.py
% Output: my_model.m