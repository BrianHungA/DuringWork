#!/usr/bin/env python
# coding: utf-8

import FileRenameApi as fra
import pandas as pd

# input the required parameters
renameFilePath = input("Please enter the \"output file\" pos:") # .../DuringWork/TifRenameApi/DemoRenameData
csvPath = input("Please ENTER the \"input index csv file\" pos：") # .../DuringWork/TifRenameApi/DemoRenameData/no_6_780.csv
conversionData = pd.read_csv(csvPath)

# create OO
oneRenameApi = fra.FileRenameApi(renameFilePath,conversionData)
oneRenameApi.main()