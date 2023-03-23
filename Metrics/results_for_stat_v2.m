clc
clear
global rootdir

%rootdir = 'D:\data\fao\202203\'
rootdir = 'D:\Estim\';
%rootdir = 'G:\ZJU\FangAo\';
addpath(genpath(string([rootdir,'Program'])));
cd([rootdir,'SSEP\']);
%%
file = readtable("D:\\Estim\\SSEP\\Data\\results_for_stat.txt"); 
para = file.PPVabs;parastat = 'PPVabs';
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
GroupStat = [GroupStat(8,:);GroupStat(1,:);GroupStat(2,:);GroupStat(3,:);GroupStat(4,:);GroupStat(5,:);GroupStat(6,:);GroupStat(7,:)]
%% dunnett-T3
 [p,t,stats] = anova1(para,group); % perform one-way ANOVA
 p = dunnett(stats,1:7,8)
 stats.gnames'








