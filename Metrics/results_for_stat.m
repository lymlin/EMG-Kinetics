clc
clear
global rootdir

%rootdir = 'D:\data\fao\202203\'
rootdir = 'E:\Estim\';
%rootdir = 'G:\ZJU\FangAo\';
addpath(genpath(string([rootdir,'Program'])));
cd([rootdir,'SSEP\']);
%%
file = readtable("E:\\Estim\\SSEP\\results_for_stat0.txt");para = file.SNNR;parastat = 'SNNR';
file = readtable("E:\\Estim\\SSEP\\results_for_stat.txt"); para = file.PPVabs;parastat = 'PPVabs';
 group = file.Group;



%%
 groupsummary = join(varfun(@mean,file,'InputVariables',parastat,...
       'GroupingVariables','Group'),...
       varfun(@std,file,'InputVariables',parastat,...
       'GroupingVariables','Group'));
groupsem = table2array(groupsummary(:,4))./sqrt(table2array(groupsummary(:,2)));
GroupStat = join(groupsummary,...
            table(groupsummary.Group,groupsem,'VariableNames',{'Group' 'sem'}));
GroupStat = sortrows(GroupStat,"Group");
GroupStat = [GroupStat(2,:);GroupStat(4,:);;GroupStat(3,:);GroupStat(1,:)]
%%
 [p,t,stats] = anova1(para,group); % perform one-way ANOVA
 p = dunnett(stats)
 stats.gnames'






