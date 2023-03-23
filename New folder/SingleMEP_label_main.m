

%% Environment Setting
clear;
clc;

filename = 'Intact01';

rootdir = 'G:\ZJU\FangAo\';
cd([rootdir,'Data\MEP\',filename]);
addpath(genpath([rootdir,'\Program']));

% Read file
% Band Filter 30-3000
% Resample and visulization (mean ± 95CI)
% statistical for MEP peak-to-peak volts

%% read file

    emgfile = dir('*.btn');
    tic
    f = 3;
    for f = 1:size(emgfile,1)


        file = emgfile(f).name;
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

       pause(60)

    %% realign data  [trial,Train,channel]
       %LabelCh = find(cell2mat(eventdata.nevs)>10);
        LabelCh = 1;
        TStim = eventdata.tsevs{LabelCh}.*1000;% in ms
        clear eventdata
        %prompt = 'What is the Label Channel? ([1:16])';
        %NOLabel = input(prompt);
        %run("MEP_Matching")
        writematrix(TStim,strcat('MEPIndexSeq_Chlabel.txt'));

        %Labelfile = dir('MEPIndexSeq_Ch*');
        %TStimdata = readmatrix(Labelfile.name);
       % TStim = TStimdata + 44.6333/1000*getFs;
        %writematrix(TStim,Labelfile.name);

    %%  filtering and matching
        NO = [7,9,13,15];
        Emgs = EMGdata(NO);
        i = 1;
        for i = 1:length(NO)
            run("MEP_noLabel_ResampleByCh")
        end          
        toc

      cd ../
    end      

    %% single checking
f = 1;


for f = 1:size(emgfile,1)
     file = emgfile(f).name;
    %emgfile = dir('*.btn');
    NameBNT = file(1:length(file)-4);
    cd(NameBNT)
    i=1;

    for i = 1:length(NO)
        
        cd(strcat('Ch',string(NO(i))))
            data = readmatrix('MEPdata.txt');
            %fdata=num2cell(data,1);
            %fftdata = cellfun(@FFTfiltering_Output,fdata,'UniformOutput',false);
            %data = reshape(cell2mat(fftdata),[15151],[length(fftdata)]);
            %writematrix(data,'MEPdata2.txt');
    
            trials = data(3.*(1:floor(size(data,1)./3)),:);% 10kHz 
            Annotation_Matrix = SingleSignelVisual(trials)
        cd ../
    end
    cd 
end

    %% data output 1 single channel average
f = 1;


for f = 1:size(emgfile,1)
     file = emgfile(f).name;
    %emgfile = dir('*.btn');
    NameBNT = file(1:length(file)-4);
    cd(NameBNT)
    
    
    i =1;

        TStimFile = dir('MEPIndexSeq_Ch*.txt');
        TStim = readmatrix(TStimFile.name);
        for i = 1:length(NO)
            
            cd(strcat('Ch',string(NO(i))))
            data0 = readmatrix('MEPdata.txt');

            load("annotate.mat");
            mark = Annotation_Matrix(:,1);

                mkdir output
                cd output
                % Input: data
                    data = data0(:,find(mark == 1));
                    
                    writematrix(data,"MEPdata.txt")
                    run('MEP_PlotWaveCI_ByData2')
                cd ../
            cd ../
        end
    cd ../
end
    %% data output 2 bichannel distinction 

