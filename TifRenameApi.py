#!/usr/bin/env python
# coding: utf-8

import os as os
import pandas as pd
import numpy as np

class TifRenameApi:
    
    path = ""
    conversion_data = ""
    _ori_file_list = ""
    
    def __init__(self,p,c):
        self.path = p
        self.conversion_data = c
    
    def main(self):
            self._rename_file(self.path,self.conversion_data)
    
    def _rename_file(self,path,df):
        # 移動工作目錄
        os.chdir(os.path.dirname(path))
        # 建立欲rename的file list
        file_list = os.listdir(path)
        self._ori_file_list = file_list
        # 移除隱藏檔
        for i in file_list.copy():
            if i.split(".")[0] == "":
                file_list.remove(i)
        
        # 取得input file name 的 Prefix word e.g. 780_20200305_1.tif -> 780_20200305_
        prefix_word = self._get_prefix_word(file_list)
        
        # 合併欄位，做出需要output的檔名
        feature_data = df.copy()
        feature_data = self._feature_generator(prefix_word,feature_data)
        data = feature_data[['serial_no','file_name']]
        data = data.set_index('serial_no')
        data_dict = data.to_dict('index')
        
        # 開始轉換
        for file_name in file_list:
            fn_key = file_name.split('.')[0] # TS-1
            if data_dict.get(fn_key) == None:
                continue
            fn_val = data_dict.get(fn_key).get('file_name') # 900dpi-code-6-02-A-KK-none-TS-1
            file_path = os.path.abspath(path + '/' + file_name) # C:\Users\hjn1\Label_Tif_Recog\TS-1.tif
            os.chdir(os.path.dirname(path))
            os.rename(file_path,path + '/' + str(fn_val) + '.tif')
        print("rename_file finished.")
    
    def _feature_generator(self,prefix_word,df):
        df['dpi'] = [i.split('-')[0] for i in df['pic']]
        df['size'] = [i.split('-')[2] for i in df['pic']]
        df['serial_no'] = [prefix_word + str(i+1) for i in range(len(df))]

        df['color'] = ""
        df.loc[df['File'] == 'BLACK','color'] = 'KK'
        df.loc[df['File'] == 'BLACKxRED','color'] = 'KM'
        df.loc[df['File'] == 'BLUE','color'] = 'CC'
        df.loc[df['File'] == 'RED','color'] = 'MM'
        df.loc[df['File'] == 'YELLOW','color'] = 'YY'

        df['pattern_chi'] = [i.split('-')[3] for i in df['pic']]
        df['pattern_chi_1'] = [i.split('-')[2] for i in df['pic_1']]
        df.loc[df['pattern_chi_1'] == '無壓','pattern_eng'] = 'none'
        df.loc[df['pattern_chi'] == '微小字','pattern_eng'] = 'tiny'
        df.loc[df['pattern_chi'] == '壓中央','pattern_eng'] = 'center'
        df.loc[df['pattern_chi'] == '壓邊','pattern_eng'] = 'edge'

        df['no'] = df['no'].apply(str)
        df['file_name'] = df['dpi'] + "-code-"
        df['file_name'] = df['file_name'] + df['size'] + '-' + df['type'] + "-" + df['color'] + "-" + df['pattern_eng'] + '-TS-' + df['no'] 

        print("feature generating finished.")
        return df

    def _get_prefix_word(self,l:list):
        prefix_word_x = l[0].split('_')
        prefix_word = "_".join(prefix_word_x[:-1]) + "_"
        return prefix_word

