#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import numpy as np
import time

class TimeGroupGen:
    """
    預設物件建立時，就把要用的資料載入
    raw_data:pandas dataframe
    """
    raw_data = pd.DataFrame()
    time_intv = 0
    max_group = ""
    result = pd.DataFrame()
    
    def __init__(self,dt,t,mg):
        """
        dt:pandas's dataframe
        t: int 
        """
        self.raw_data = dt
        self.time_intv = t
        self.max_group = mg
        
    def main(self):
        inter_data = self._add_features(self.raw_data)
        result = inter_data.groupby('AUTH_CODE_CDE').apply(lambda x:self._cal_time_div(x,self.time_intv))
        return result
    
    def _add_features(self,dt):
        dt['ACT_DT_TIMESTAMP'] = ''
        dt['ACT_DT_TIMESTAMP'] = dt['ACT_DT'].apply(lambda x : time.mktime(time.strptime(x, "%Y-%m-%d %H:%M:%S")))
        dt['ACT_DT_DIV'] = 0
        dt['GROUP'] = ''
        dt['GROUP_SIMILAR_IP'] = ''
        dt['GROUP_SIMILAR_GROUP'] = ''
        dt = dt.replace(to_replace=';',value=np.nan)
        return dt
    
    def _cal_time_div(self,dt,t):
        """
        這FUNC.的dt是同一組AUTH_CODE_CDE下的所有查詢紀錄
        """

        # 從最後的ACT_DT開始往回做,算時間前後兩筆資料之間的time interval
        for i in range(len(dt)-1,0,-1):
            # 讓第一筆資料的時間為0
            if i > 0:
                dt.at[dt.index[i],'ACT_DT_DIV'] = dt['ACT_DT_TIMESTAMP'].iloc[i] - dt['ACT_DT_TIMESTAMP'].iloc[i-1]
        
        # 若時間小於default time_interval則當作與前筆資料同group
        count = 0
        for i in range(len(dt)):
            if dt['ACT_DT_DIV'].iloc[i] <= t:
                dt['GROUP'].iloc[i] = 'G' + str(count)
            else:
                if count <= self.max_group:
                    count += 1
                dt['GROUP'].iloc[i] = 'G' + str(count)

        # 若有和之前GROUP相同的IP，更新單筆資料的GROUP為之前的GROUP值，並作為新參數'GROUP_SIMILAR_IP
        for i in range(len(dt)):
            # 找same IP的最小CID的GROUP值
            dt_same_ip_before = dt.loc[(dt['IP_ADDR'] == dt['IP_ADDR'].iloc[i]) & (dt['CID'] < dt['CID'].iloc[i])]
            if len(dt_same_ip_before) > 1:
                dt['GROUP_SIMILAR_IP'].iloc[i] = dt_same_ip_before['GROUP'].iloc[0]
            else:
                dt['GROUP_SIMILAR_IP'].iloc[i] = dt['GROUP'].iloc[i]
        
        # 若有和之前GROUP相同的IP，則除了更新單筆資料的GROUP為之前的GROUP值，
        # 此筆資料往後計算，符合default time interval內的資料，都更新為之前的GROUP值，
        # 並作為新參數'GROUP_SIMILAR_GROUP'
        count = 0
        prev_group = "G0" 
        for i in range(len(dt)):
            # 保持紀錄目前的GROUP位置，產生此查詢的前一個值(不能跨GROUP)
            if dt['ACT_DT_DIV'].iloc[i] <= t and i > 0:
                prev_group = dt['GROUP_SIMILAR_GROUP'].iloc[i-1]
            elif dt['ACT_DT_DIV'].iloc[i] > t:
                if count < self.max_group:
                    count += 1
                prev_group = 'G' + str(count)

            dt_same_ip_before = dt.loc[(dt['IP_ADDR'] == dt['IP_ADDR'].iloc[i]) & (dt['CID'] < dt['CID'].iloc[i])]
            if len(dt_same_ip_before) > 1:
                temp_same_ip_group = dt_same_ip_before['GROUP'].iloc[0]
            else:
                temp_same_ip_group = dt['GROUP'].iloc[i]
#             print("CONSUMER_INQ = ",dt['CID'].iloc[i],";temp_same_ip_group = ",temp_same_ip_group,";prev_group = ",prev_group)
            if temp_same_ip_group > prev_group:
                dt['GROUP_SIMILAR_GROUP'].iloc[i] = prev_group
            else:
                dt['GROUP_SIMILAR_GROUP'].iloc[i] = temp_same_ip_group
        return dt

class QueryNumberGen:
    """
    預設物件建立時，就把要用的資料載入
    raw_data:pandas dataframe
    """
    raw_data = pd.DataFrame()
    result = pd.DataFrame()
    
    def __init__(self,dt):
        """
        dt:pandas's dataframe
        """
        self.raw_data = dt
        
    def main(self):
        inter_data = self._add_features(self.raw_data)
        result = inter_data.groupby('AUTH_CODE_CDE').apply(lambda x:self._cal_query_number(x))
        return result
    
    def _add_features(self,dt):
        dt['QUERY_NUMBER'] = ''
        dt = dt.replace(to_replace=';',value=np.nan)
        return dt
    
    def _cal_query_number(self,dt):
        for i in range(len(dt)):
            dt['QUERY_NUMBER'].iloc[i] = i+1
        return dt

