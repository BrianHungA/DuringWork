#!/usr/bin/env python
# coding: utf-8

# In[5]:


import pandas as pd
import FeatureGenApi as fga

path = input("Please input the .csv file path : ") # .../DuringWork/FeatureGenApi/Data/FakeDataForDemo.csv

# Run Feature: timeGroup
dataForTimeGroup = pd.read_csv(path,sep = ',')
timeGroupGen = fga.TimeGroupGen(dataForTimeGroup,60,30)
timeGroupResult = timeGroupGen.main()
timeGroupResult.to_csv(path_or_buf = 'timeGroupResult.csv', sep = ',')

# Run Feature: queryNumber
dataForQueryNumber = pd.read_csv(path,sep = ',')
queryNumberGen = fga.QueryNumberGen(dataForQueryNumber)
queryNumberResult = queryNumberGen.main()
queryNumberResult.to_csv(path_or_buf = 'queryNumberResult.csv', sep = ',')

