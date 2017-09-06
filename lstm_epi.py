# -*- coding: utf-8 -*-
from __future__ import print_function
import numpy as np
import math
from keras.regularizers import l2
from keras.models import Sequential
from keras.layers import SimpleRNN, Dense, LSTM, Activation
from keras.utils import np_utils
from keras.optimizers import RMSprop, Adagrad, Adam
from sklearn.preprocessing import scale
from keras.callbacks import EarlyStopping, History, ModelCheckpoint
from random import sample, seed
from copy import deepcopy
from sklearn import preprocessing
from sklearn.utils import shuffle
import pandas as pd
import os.path
import sys


def create_seq(X,y,seq_length,overlap,predstep):
  nb_samples = X.shape[0]
  new_size = (nb_samples - nb_samples%overlap)/overlap-seq_length-predstep
  X_ = np.zeros((new_size, seq_length, X.shape[1]))
  y_ = np.zeros((new_size,y.shape[1]))
  for i in range(0,new_size):
    j = i*overlap
    X_[i,:,:] = X[j:j+seq_length,:]
    y_[i,:] = y[j+seq_length-1,:]
  return X_,y_


def build_net(structure,X_train,y_train,X_test,y_test,lr,d):
  print('Build model...')
  model = Sequential()
  filter_length = 3
  n = len(structure)
  for i in range(len(structure)):
    type = structure[i][0]
        
    if type == 'lstm':
      n_neuron = structure[i][1]
      if i==0 and n == 1:
          model.add(LSTM(n_neuron, input_shape=(seq_length, X_train.shape[2]),
                       return_sequences=False, dropout=d, recurrent_dropout=d,
                       kernel_regularizer=l2(w),recurrent_regularizer=l2(w)))
      elif i==0 and n != 1:
          model.add(LSTM(n_neuron, input_shape=(seq_length, X_train.shape[2]),
                         return_sequences=True, dropout=d, recurrent_dropout=d,
                       kernel_regularizer=l2(w),recurrent_regularizer=l2(w)))
      elif i>0 and i == n-1:  
          model.add(LSTM(n_neuron, return_sequences=False, dropout=d, recurrent_dropout=d,
                       kernel_regularizer=l2(w),recurrent_regularizer=l2(w)))
      else:
          model.add(LSTM(n_neuron, return_sequences=True, dropout=d, recurrent_dropout=d,
                       kernel_regularizer=l2(w),recurrent_regularizer=l2(w)))

  model.add(Dense(y_train.shape[1], activity_regularizer = l2(0.0)))
  model.add(Activation('softmax'))

  if optimizer_str == 'adam':
    optimizer = Adam(lr=lr)
  elif optimizer_str == 'RMSprop':
    optimizer = RMSprop(lr=lr)

  model.compile(loss='categorical_crossentropy', optimizer=optimizer, metrics=['accuracy'])
  checkpointer = ModelCheckpoint(filepath="+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/weights1.hdf5", verbose=1, save_best_only=True)
  earlystopping = EarlyStopping(monitor='val_loss', min_delta=0, patience=7, verbose=0, mode='auto')
  callbacks = [History(),checkpointer,earlystopping]
  
  if y_train.shape[1] == 2:
    class_weights = {0:1, 1:1.*n_int/n_preict}
  else:
    class_weights = {0:1, 1:1.*n_int/n_preict, 2:1.*n_int/n_ict,3:1.*n_int/n_postict }
  hist = model.fit(X_train, y_train, batch_size=batch_size, epochs=nb_epoch,
                  validation_data=(X_test,y_test),class_weight = class_weights,callbacks=callbacks)
 
  model.load_weights('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/weights1.hdf5')

  return model


def train_models():
    model = build_net(structure,X_train,y_train,X_valid,y_valid,lr,d)
    return model

batch_size = 128 #batch size
 
overlap = 1
predstep = 0
lr = float(sys.argv[1])
d = float(sys.argv[2])
w = float(sys.argv[3])
sop = float(sys.argv[4])
seq_length = int(sys.argv[5])
nb_epoch = int(sys.argv[6])
optimizer_str = sys.argv[7]

structure = [['lstm',int(sys.argv[i])] for i in range(8,len(sys.argv))]
print(structure)


X_train = pd.read_csv('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/P.csv',header=None)
y_train = pd.read_csv('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/T.csv',header=None)

X_valid = pd.read_csv('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/Ptest.csv',header=None)
y_valid = pd.read_csv('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/Ttest.csv',header=None)

X_train = X_train.as_matrix()
X_valid = X_valid.as_matrix()

  
y_train = np_utils.to_categorical(y_train)
y_train = y_train[:,1:]

y_valid = np_utils.to_categorical(y_valid)
y_valid = y_valid[:,1:]


# X = scale(X) #normalize the data


X_valid,y_valid = create_seq(X_valid,y_valid,seq_length,overlap,predstep)
X_train,y_train = create_seq(X_train,y_train,seq_length,overlap,predstep)


n_preict = len(y_train[y_train[:,1]==1])
n_int = len(y_train[y_train[:,0]==1])  
n_preict_valid = len(y_valid[y_valid[:,1]==1])
n_int_valid = len(y_valid[y_valid[:,0]==1])  

if y_train.shape[1]>2:
  n_ict = len(y_train[y_train[:,2]==1])
  n_posict = len(y_train[y_train[:,3]==1])  
  n_ict_valid = len(y_valid[y_valid[:,2]==1])
  n_posict_valid = len(y_valid[y_valid[:,3]==1])  

model = train_models()

A = model.predict(X_valid)

print(A)
f = open('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/A.csv','w')
for i in range(len(A)):
    if np.argmax(A[i])==0:
        f.write('1 \n')
    elif np.argmax(A[i])==1:
        f.write('2 \n')
    elif np.argmax(A[i])==2:
        f.write('3 \n')
    else:
        f.write('4 \n')
f.close()


