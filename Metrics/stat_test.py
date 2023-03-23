# -*- coding: utf-8 -*-
# coding: utf-8
from scipy import stats
import pandas as pd
import scikit_posthocs as sp
from scipy.stats import f_oneway
from statsmodels.stats.multicomp import pairwise_tukeyhsd

import pingouin as pg



file = pd.read_table("D:\\Estim\\SSEP\\Data\\results_for_stat.txt")

# data.encode('utf-8').strip()
file.head()
Z = 'SSEP'

group1 = file[file["Group"]=="Intact"][Z]
group2 = file[file["Group"] == "SCI"][Z]
group3 = file[file["Group"]=="Microneedle"][Z]
group4 = file[file["Group"]=="Cell"][Z]
group5 = file[file["Group"]=="MN"][Z]
group6 = file[file["Group"]=="MSC-IV"][Z]
group7 = file[file["Group"]=="MSC-PBS"][Z]
group8 = file[file["Group"]=="MSC-Gel"][Z]
group9 = file[file["Group"] == "Exo-Gel"][Z]


stat,pn = stats.shapiro(group1)
print('stat = %.3f, p = %.3f' % (stat,pn))
stat,pn = stats.shapiro(group2)
print('stat = %.3f, p = %.3f' % (stat,pn))
stat,pn = stats.shapiro(group3)
print('stat = %.3f, p = %.3f' % (stat,pn))
stat,pn = stats.shapiro(group4)
print('stat = %.3f, p = %.3f' % (stat,pn))

stat,pn = stats.shapiro(group5)
print('stat = %.3f, p = %.3f' % (stat,pn))

stat,pn = stats.shapiro(group6)
print('stat = %.3f, p = %.3f' % (stat,pn))

stat,pn = stats.shapiro(group7)
print('stat = %.3f, p = %.3f' % (stat,pn))

stat,pn = stats.shapiro(group8)
print('stat = %.3f, p = %.3f' % (stat,pn))
stat,pn = stats.shapiro(group9)
print('stat = %.3f, p = %.3f' % (stat,pn))


args = [group1,group2,group3,group4,group5,group6,group7,group8,group9]
w,p = stats.levene(*args)
print(w,p)
w,p = stats.levene(*args,center="mean")
print(w,p)

stats.bartlett(group1,group2,group3,group4,group5,group6,group7,group8)

f,pf = stats.f_oneway(group1,group2,group3,group4,group5,group6,group7,group8,group9)
print ('F value:', f)
print ('P value:', pf, '\n')


pg.welch_anova(dv=Z, between='Group', data=file)


posthoc1_result = sp.posthoc_ttest([group1,group2,group3,group4,group5,group6,group7,group8,group9], p_adjust = 'sidak')

posthoc1_result2=sp.posthoc_ttest([group1,group2,group3,group4,group5,group6,group7,group8,group9], p_adjust = 'bonferroni')
posthoc1_result3 = sp.posthoc_ttest([group1,group2,group3,group4,group5,group6,group7,group8,group9], p_adjust = None)



from statsmodels.stats.multicomp import pairwise_tukeyhsd
tukey = pairwise_tukeyhsd(endog=file[Z],groups=file['Group'], alpha=0.05)
print(tukey)