#%reset -f 表示清除所有的变量

from scipy.io import loadmat
import numpy as np
import pandas as pd
#import mne
import matplotlib.pyplot as plt
#plt.close("all")
import os
import sys
import math
from sklearn.model_selection import train_test_split
#%%
# Load data
filedir = 'G:\\ZJU\\FangAo\\SVMtraining\\'
data_matrix = np.loadtxt(filedir + 'SVM_datamatrix.txt',delimiter=',')
X, y = data_matrix[:,:-1],data_matrix[:,-1]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=42)
train= np.column_stack((X_train,y_train))
np.savetxt(filedir+'train_usual.csv',train, delimiter = ',')
test = np.column_stack((X_test, y_test))
np.savetxt(filedir+'test_usual.csv', test, delimiter = ',')
#%%
from sklearn.model_selection import cross_val_score, KFold
from scipy.stats import sem # sem 标准误差平均
from sklearn import svm
from sklearn import metrics
#import pickle

def train_and_evaluate(clf, X_train, X_test, y_train, y_test):
    clf.fit(X_train, y_train)             # 训练

    print ("训练集精度:")   # 训练集精度
    print (clf.score(X_train, y_train))

    print ("\n测试集精度:")    # 测试集精度
    print (clf.score(X_test, y_test))

    y_pred = clf.predict(X_test)

    print ("\n分类识别报告:")      # 分类识别报告
    print (metrics.classification_report(y_test, y_pred))

    print ("\n混淆矩阵:")           # 混淆矩阵
    print (metrics.confusion_matrix(y_test, y_pred))

def evaluate_cross_validation(clf, X, y, K):
    # 创建 K-折交叉验证迭代器对象
    cv = KFold(K, shuffle=True, random_state=0)
    #cv = KFold(len(y), K, shuffle=True, random_state=0)
    # 计算返回分数
    scores = cross_val_score(clf, X, y, cv=cv)
    print (scores)
    print (("\n平均值: {0:.3f} (均标准差:+/-{1:.3f})").
           format(
               np.mean(scores), # 均值
               sem(scores) )    # 均标准差
           )

#-----------------------------#
# 用SVM来搭建预测模型
#-----------------------------#
#e.g.
# clf = svm.SVC(kernel= 'rbf',class_weight='balanced',C = 2.5,gamma=0.07,max_iter=6000,tol=0.001,probability=True)

#%%
# 网格搜索
from sklearn.model_selection  import GridSearchCV

C_list = np.linspace(pow(2,-5), pow(2,5), pow(2,5))   #np.arange(1,5,1.5)
gamma_list = np.linspace(pow(2,-15), pow(2,3), 32) #np.arange(0.05,0.15,0.02)
parameters = {
   'gamma': gamma_list,
   'C': C_list
}
print("svc__gamma参数取值："+str(gamma_list))
print("svc__C参数取值："+str(C_list))

clf = svm.SVC(kernel= 'rbf',class_weight='balanced',C = 5,gamma=0.3,max_iter=3000,tol=0.001,probability=True)
gs = GridSearchCV(clf, parameters, verbose=2, refit=False, cv=3)
timeind= gs.fit(X, y)
print("Best C for svm: ",gs.best_params_['C'])
print("Best gamma for svm: ",gs.best_params_['gamma'])
print("Best score: ",gs.best_score_)

#%%
# best

clf = svm.SVC(kernel= 'rbf',class_weight='balanced',C = gs.best_params_['C'],gamma=gs.best_params_['gamma'],max_iter=3000,tol=0.01,probability=True)
train_and_evaluate(clf, X_train, X_test, y_train, y_test)

#Predictedval = clf.predict(X)
#np.savetxt(filedir + 'predictedval.txt',Predictedval,delimiter=',')

import joblib
joblib.dump(clf, filedir + 'my_model.pkl')

print("5折交叉验证结果：")
evaluate_cross_validation(clf, X, y, 5)

print("general model: ")
clf = svm.SVC(kernel= 'rbf',class_weight='balanced',C = 5,gamma=0.3,max_iter=2000,tol=0.01,probability=True)
train_and_evaluate(clf, X_train, X_test, y_train, y_test)
