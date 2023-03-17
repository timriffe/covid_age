# -*- coding: utf-8 -*-
"""
Created on Fri Mar 17 11:26:27 2023

@author: Krishnan
"""

import time
import glob
import os
from datetime import datetime
import tabula
import pandas as pd
from os import path
import shutil

list_of_file=glob.glob('N:/COVerAGE-DB/Automation/Hydra/Data_sources/India/*.pdf')
latest_file=max(list_of_file,key=os.path.getctime)
pdf_path=latest_file
dfs=tabula.read_pdf(pdf_path,pages="1")
print(len(dfs))
a=pdf_path[84:93]

"""
for i in range(len(dfs)):

    dfs[i]=dfs[i].dropna()

    dfs[i].to_csv(f"India_data{i}.csv")

"""

 

df1=dfs[0]
df1=df1.dropna()
df2=dfs[1]
df2=df2.dropna()
df2.columns = ["Serial","Region","2","3","4","Total_Doses"]
df2[["1st_Dose_18","2nd_Dose_18"]]=df2["2"].apply(lambda x: pd.Series(str(x).split(" ")))
df2[["1st_Dose_15","2nd_Dose_15","1st_Dose_12","2nd_Dose_12"]]=df2["3"].apply(lambda x: pd.Series(str(x).split(" ")))
df2[["Precaution_Dose_18","Precaution_Dose_60"]]=df2["4"].apply(lambda x: pd.Series(str(x).split(" ")))

"""

del df2["2"]

del df2["3"]

del df2["4"]

"""

df3=df2[["Serial","Region","1st_Dose_18","2nd_Dose_18","1st_Dose_15","2nd_Dose_15","1st_Dose_12","2nd_Dose_12","Precaution_Dose_18","Precaution_Dose_60","Total_Doses"]].copy()
df3.to_csv(f"subnational_{a}.csv",index=False)
import pdfplumber

"""

filename="CummulativeCovidVaccinationReport01Jan2023.pdf"

pdf=pdfplumber.open(filename)

tables = pdf.find_tables()

 

table=pdf.pages[0].extract_table()

"""

with pdfplumber.open(pdf_path) as pdf:
    first_page = pdf.pages[0].find_tables()
    t1_content = first_page[0].extract(x_tolerance = 5)
    t2_content = first_page[1].extract(x_tolerance = 5)

header=1
columns=list()
for column in t1_content[header]:
   if column!=None and len(column)>1:
      columns.append(column)
print(columns)

 

df=pd.DataFrame(t1_content[header+1::])

df=df.iloc[1:]

df.columns=["Country","1st_Dose_18","2nd_Dose_18","1st_Dose_15","2nd_Dose_15","1st_Dose_12","2nd_Dose_12","Precaution_Dose_18","Precaution_Dose_60","Total_Doses"]

df.to_csv(f"national_{a}.csv",index=False)

#Copying the file from Github path to Hydra folder
src = r"U:\git\covid_age\Python\Working\India\\"
dst = r"N:\COVerAGE-DB\Automation\Hydra\Data_sources\India\\"


#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "ali"))
   
  
files = [i for i in os.listdir(src) if i.startswith("national") or i.startswith("subnational") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))