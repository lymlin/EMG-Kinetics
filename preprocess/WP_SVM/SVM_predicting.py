#%%
import os
import sys
import joblib
import numpy as np
from sklearn import svm
from sklearn import metrics
#%%
filedir = 'G:\\ZJU\\FangAo\\'

clf = joblib.load(filedir + 'SVMtraining\\' + 'my_model.pkl')
data_matrix = np.loadtxt(filedir + 'SVM_datamatrix.txt',delimiter=',')
X, y = data_matrix[:,:-1],data_matrix[:,-1]
Predictedval = clf.predict(X)
np.savetxt(filedir + 'predictedval.txt',Predictedval,delimiter=',')
