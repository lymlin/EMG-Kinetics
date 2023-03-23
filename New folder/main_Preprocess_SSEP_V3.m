%% Outline


%% setting
    clear;
    clc;

    rootdir = 'D:\Estim\';
    addpath(genpath([rootdir,'\Program']));
    cd([rootdir,'SSEP\']);
    setFs(30000)
%% rename
    cd Data
    x  = struct2cell(dir)
    label = x(1,3:12)
    for i = 1:length(label)
        lname = label{i};
        cd(lname)
        file = struct2cell(dir);
        btns = dir('T*.btn')
            for k = 1:length(btns)
                btnfile = btns(k).name;
                newfile = strcat('SSEP_',btnfile(1:2),'_Hindpaw_2Hz_2mA_500us.btn');
                movefile(btnfile,newfile);
            end
        cd ../
    end
    P3list = label';
    P3list = [P3list,num2cell(2*ones(length(label),1))];
    P3list = [P3list,num2cell(3*ones(length(label),1))];
    writecell(P3list,'datainfo_SSEP3.txt')
    cd ../

%% readmatrix, preprocess 
    setPreTimeInms(50)
    setObserveWin(450)
    Nfile = size(P3list,1);
    for n = 1:Nfile
    
        Case = P3list{n,1};
        filedir = ['SSEP\Data\',Case,'\',];
        cd([rootdir,'\',filedir])
        filename = dir('*.btn');
        fi = 1;
        NO = [P3list{n,2}];    

        for fi = 1:size(filename,1)
            file = filename(fi).name;
        
            run("readfile_btnEsig");
            pause(5)
            run("readEvent_Time"); %Tstim
            data = EMGdata{NO(1)}; 
            figure;plot((1:length(data))./getFs,data);xlabel('Time [s]')
            
            writematrix(TStimInms,'TStim.txt')
            writematrix(data,'raw.txt')

            % read data in pieces (rough filter)
            wave = initFFTfilter(data,[1.8,3000]);
            writematrix(wave,'inifilter.txt')
            cd ../
            close all
        end
        cd ../
    end
%% Stim_time ajudtment
    x='time ajustment'
    setPreTimeInms(50)
    setObserveWin(150)
    UpBorders = 1000;

    inifilpara = [1500];
    datainfo = readtable('datainfo_SSEP3.txt');
    P3list = table2cell(datainfo);
    for p = 1:length(inifilpara)
        for n = 1:length(P3list)
          
            Case = P3list{n}
            filedir = ['SSEP\Data\',Case,'\',];
            cd([rootdir,'\',filedir])
            filename = dir('*.btn');
            fi = 1;
            
            for fi = 1:size(filename,1)
                file = filename(fi).name
                cd(file(1:end-4))
    
                wave = readmatrix('inifilter.txt'); 
                wave = initFFTfilter(wave,[1.8,1000]);
                writematrix(wave,'inifilter_waves.txt')

                wave = FFTfreqBandPass(wave,[1.8,UpBorders]);
                TStimInms= readmatrix('TStim.txt');
                
                Ts =-getPreTimeInms:1/getFs*1000:getObserveWin;
    
                dirna =[num2str(inifilpara(p)),'stimfil'];
                mkdir(dirna) 
                cd(dirna)
                    data_mapped = DataMapping(TStimInms,wave);
                    data_c=num2cell(data_mapped,1);

                    
                    filters = repmat([30,UpBorders]',1,size(data_mapped,2));
                    Filters = num2cell(filters,1);
            
                    data1 = cellfun(@butter_narrowfilter,data_c,Filters,'UniformOutput',false);
                    data1 = reshape(cell2mat(data1),size(data_mapped));
                    data1 = data1 - mean(data1);

                    [x,timeDelay] = max(data1); % rough locate
                    timeDelayInms = timeDelay./getFs.*1000 - getPreTimeInms; % with manual adjustment
                    writematrix(timeDelayInms','timedelayinms.txt')
                    SingleSignalVisual(data1,[-20,120],[-2,2]); % adjust at the meantime

                cd ../
                cd ../
                close all
            end
            cd ../
        end
    end

    % post selection - mapping
    x = 'delaymapping'
    delayseq = readmatrix('delaytimeinms-2.txt'); % adjusted stimulation time
    n  = 1;
    for p = 1:length(inifilpara)

        for n = 1:length(P3list)
          
            Case = P3list{n}
            filedir = ['SSEP\Data\',Case,'\',];
            cd([rootdir,'\',filedir])
            filename = dir('*.btn');
            fi = 1;
            
            for fi = 1:size(filename,1)
                file = filename(fi).name
            
                % read file
                cd(file(1:end-4))
                
                wave = readmatrix('inifilter_waves.txt'); 
                wave = FFTfreqBandPass(wave,[1.8,UpBorders]);
                
                TStimInms= readmatrix('TStim.txt');
                if n == 3
                    TStimInms = TStimInms + rmmissing(delayseq(:,(n)*3+fi));
                else 
                    TStimInms = TStimInms + rmmissing(delayseq(:,(n-1)*3+fi));
                end
    
                Ts =-getPreTimeInms:1/getFs*1000:getObserveWin;
    
                dirna =[num2str(inifilpara(p)),'stimfil'];
                mkdir(dirna) 
                cd(dirna)
                    writematrix(TStimInms,'TStimInms_0.txt')
                    data_mapped = DataMapping(TStimInms,wave);        
                    data_c=num2cell(data_mapped,1);
                    
                    filters = repmat([30,UpBorders]',1,size(data_mapped,2));
                    Filters = num2cell(filters,1);
                    data1 = cellfun(@butter_narrowfilter,data_c,Filters,'UniformOutput',false);
            
                    data1 = reshape(cell2mat(data1),size(data_mapped));
                    data1 = data1 - mean(data1);
            
                    writematrix(data1,'mapped_processed.txt') % a file
                    
                cd ../
                cd ../
                close all
            end
            cd ../
        end
    end    

%% select data (no need for dual channel methods)
    setPreTimeInms(50)
    setObserveWin(150)
    inifilpara = [1500];
    datainfo = readtable('datainfo_SSEP4.txt');
    P3list = table2cell(datainfo);
    for p = 1:length(inifilpara)
        for n =1:length(P3list)
            Case = P3list{n}
            filedir = ['SSEP\Data\',Case,'\',];
            cd([rootdir,'\',filedir])
            filename = dir('*.btn');
            fi = 1;
            
            for fi = 1:size(filename,1)
                file = filename(fi).name
            
                % read file
                cd(file(1:end-4))

                Ts =-getPreTimeInms:1/getFs*1000:getObserveWin;
                
                dirna =[num2str(inifilpara(p)),'stimfil'];
                cd(dirna)              
            
                    data1 = readmatrix('mapped_processed.txt'); % the file
                    SingleSignalVisual(data1,[-20,120],[-2,2]);
                    load("annotate.mat");
                    mark = Annotation_Matrix(:,1);
                    data2 = data1(:,find(mark == 1));
                    writematrix(data2,'iniselect_data2.txt')
                    mkdir refil
                    cd refil
                    SingleSignalVisual(data2,[-20,120],[-2,2]);
                    
                    load("annotate1.mat");
                    mark = Annotation_Matrix(:,1);
                    data3 = data2(:,find(mark == 1));
                    writematrix(data3,'refil_data3.txt')
            
                    SingleSignalVisual(data3,[-20,120],[-2,2]);
                    load("annotate2.mat");
                    mark = Annotation_Matrix(:,1);
                    data4 = data3(:,find(mark == 1));
                    size(data4,2)
                    data4 = data4(:,1:150);
                    writematrix(data4,'refil_data4.txt')
                    data2 = data4;
                    data4(Ts<15,:) = smoothdata(data2(Ts<15,:),"gaussian",250);
                    StimArtifactTime = intersect(find(Ts>-15),find(Ts<14));
                    data4(StimArtifactTime,:) = 1e-1.*data2(StimArtifactTime,:);
                    data4(Ts<15,:) = smoothdata(data4(Ts<15,:),"gaussian",200);
                    data5 = smoothdata(data4,"movmean",100);

                    writematrix(data5,'mappedpieces_processed.txt')  % data for statistics
                    data = data5;
        
                    ConfidenceInterval95Plot(data,[-getPreTimeInms,getObserveWin],[-1.25,1.25])
                    ylim([-.5,.5]);xlim([-5,100]);
                    saveas(gcf,'image.jpg')
                    savefig('image.fig')
                    cd ../../../
        
                close all
            end
            cd ../
        end
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% batch reading - result output
    
    setPreTimeInms(50)
    setObserveWin(150)
    r=0;
    inifilpara = ['1500stimfil'];

    dirs = 'D:\Estim\SSEP\Data\E33\SSEP_T1_Hindpaw_2Hz_2mA_500us\1500stimfil\';
    Data_details = [];
    Outmatrix = [];
    Outname = {};
    f = 0;
    cd results
        for m = 1:length(P3list)
        
            Case = P3list{m}
            if m == 2
                N = 6
            else 
                N = 3
            end

            for t = 1:N
                filname = [Case,'_',num2str(t)];
                casedir = dirs;
                casedir(20:22) = Case;
                casedir(30) = string(t);

                mkdir(filname)
                cd(filname)

                    data = readmatrix(strcat(casedir,'mapped_processed.txt'));
                    writematrix(data, 'SourceData.txt')

                    data = readmatrix(strcat(casedir,'refil\mappedpieces_processed.txt'));
                    writematrix(data,'Data_mapping.txt')

                    r=0;run('Metrics_Output_SSEP')
                    f = f+1;
                    Data_details(f).rowNames = rowNames;
                    Data_details(f).MeanOut = meanOut;
                    Data_details(f).case = Case;
                    Data_details(f).Test = t;
                    Data_details(f).data = data;

                    Outmatrix = [Outmatrix;meanOut];
                    Outname = [Outname, Case];

                    
                    ConfidenceInterval95Plot(data,[-getPreTimeInms,getObserveWin],[-1.25,1.25])
                    ylim([-0.5,0.5]);xlim([-5,100]);
                    saveas(gcf,'image.jpg')
                    savefig('image.fig')
                cd ../
            end
        end

        Group1 = {'Cell','Intact','Microneedle','SCI'};
        for l = 1:length(Group1)
            for t = 1:3
                f = 1+f;
                filename = strcat('D:\Estim\results\SSEP\',Group1(l),'\Test',string(t),'\data_mapped.txt');
                data = readmatrix(filename);
                Case = Group1{l};
                filname = strcat(Case,'_',string(t));
                mkdir(filname)
                cd(filname)
                    data_c=num2cell(data,1);
     

                    r=0;run('Metrics_Output_SSEP')

        
                    Data_details(f).rowNames = rowNames;
                    Data_details(f).MeanOut = meanOut; 
                    Data_details(f).case = Case;
                    Data_details(f).Test = t; 
                    Data_details(f).data = data;

                    Outmatrix = [Outmatrix;meanOut];
                    Outname = [Outname, Case];
                    writematrix(data,'Data_mapping.txt')

                    ConfidenceInterval95Plot(data,[-getPreTimeInms,getObserveWin],[-1.25,1.25])
                    ylim([-0.5,0.5]);xlim([-5,100]);
                    saveas(gcf,'image.jpg')
                    savefig('image.fig')

                cd ../
            end
        end
    

    F = f;
    Outmatrix = reshape(Outmatrix,[],[F]);
    writematrix(Outmatrix,'statistics_matrix-2.csv')
    writecell(Data_details(1).rowNames,'statistics_rownames-2.txt')
    writecell(Outname,'whole_statistics_cases-2.txt')
    cd ../
    close all
    
%% CI 
    cd results
    Ts =-getPreTimeInms:1/getFs*1000:getObserveWin;
    meandata = [];
    for f = 1:F
        filename = strcat(Data_details(f).case,'_',num2str(Data_details(f).Test));
        cd(filename)

            CIs = readmatrix('Wave signal 95% CI.txt');
            W = CIs(:,2);
            Indnoise = intersect(find(Ts>80),find(Ts<100));
            adjCIs=  CIs(:,2:4)./range(W(Indnoise));
            Data_details(f).CIs = CIs(:,2:4);
            Data_details(f).aCIs = adjCIs;
            Data_details(f).Ts = Ts;
            meandata = [meandata,adjCIs(:,1)];
        cd ../

    end
    save('whole_Data_details-2.mat','Data_details');
    writematrix(meandata, 'meandata-2.txt');
    cd ../

%% visualization
    % general - ssep
    cd results
        maxfigure
        Ts = Data_details(1).Ts;
        for f = 1:F
            subplot((F-9)/3,3,f)
            CIs = Data_details(f).aCIs;
            plot_ci(Ts,CIs,'PatchColor', 'r','PatchAlpha', 0.2,...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'k', ...
            'LineWidth', 1, 'LineStyle','--', 'LineColor', 'b')

            xlim([-5,100]);ylim([-10,10]); 
        end
        k=F-12;
        for f = F-2:F
            k = k+1
            subplot((F-9)/3,3,k)
            CIs = Data_details(f).aCIs;
            plot_ci(Ts,CIs,'PatchColor', 'r','PatchAlpha', 0.2,...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'k', ...
            'LineWidth', 1, 'LineStyle','--', 'LineColor', 'b')

            xlim([-5,100]);ylim([-10,10]); 
        end

        title(Data_details(f).case)

        sgtitle('relative')    
        print(gcf,'relative_sig_whole_ssep.svg','-dsvg','-vector');

        

        % general - relative
            
        maxfigure
        Ts = Data_details(1).Ts;
        for f = 1:F-9
            subplot((F-9)/3,3,f)
            CIs = Data_details(f).CIs;

            plot_ci(Ts,CIs,'PatchColor', 'r','PatchAlpha', 0.2,...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'k', ...
            'LineWidth', 1, 'LineStyle','--', 'LineColor', 'b')
            
            xlim([-5,100]);ylim([-0.5,0.5]); 
            xlabel('Time in [ms]')
            ylabel('Relative Potential')
        
            set(gca,'linewidth',1.5)
            set(get(gca,'XLabel'),'FontSize',12,'Vertical','top');
            set(get(gca,'YLabel'),'FontSize',12,'Vertical','middle');

            title(Data_details(f).case)
        end
        sgtitle('ori')    
        print(gcf,'ori_sig_whole.svg','-dsvg','-vector');



    % for each file
    
    for r = 1:F
        figure
        CIs = Data_details(f).aCIs;

        plot_ci(Ts,CIs,'PatchColor', 'r','PatchAlpha', 0.2,...
        'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'k', ...
        'LineWidth', 1, 'LineStyle','--', 'LineColor', 'b')
        
            xlim([-5,100]);ylim([-10,10]); 
            xticks([0:20:100])
            yticks([-8,0,8])
            xlabel('Time in [ms]')
            ylabel('Relative Potential')
        
            set(gca,'linewidth',1.5)
            set(get(gca,'XLabel'),'FontSize',12,'Vertical','top');
            set(get(gca,'YLabel'),'FontSize',12,'Vertical','middle');

        filename = strcat(Data_details(f).case,'_',num2str(Data_details(f).Test));
        cd(filename)

            print(gcf,'adjCI95.tif','-dtiffn');

            set(gcf,"Color",'none')
            set(gca,"Color",'none')
            print(gcf,'meanplot.svg','-dsvg','-vector');





            figure
            CIs = Data_details(f).CIs;
            plot_ci(Ts,CIs,'PatchColor', 'r','PatchAlpha', 0.2,...
            'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'k', ...
            'LineWidth', 1, 'LineStyle','--', 'LineColor', 'b')
            
                xlim([-5,100]);ylim([-1.0,1.0]); 
                xticks([0:20:100])
                yticks([-1.0,0,1.0])
                xlabel('Time in [ms]')
                ylabel('Relative Potential')
            
                set(gca,'linewidth',1.5)
                set(get(gca,'XLabel'),'FontSize',12,'Vertical','top');
                set(get(gca,'YLabel'),'FontSize',12,'Vertical','middle');

                print(gcf,'\adjCI95_ori.tif','-dtiffn');

                set(gcf,"Color",'none')
                set(gca,"Color",'none')
                print(gcf,'meanplot_ori.svg','-dsvg','-vector');
        cd ../
    end

    cd ../
    