# -*- coding: utf-8 -*-
"""
Created on Wed Aug  4 15:23:27 2021

@author: Waqar
"""


import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")

src = r"C:\Users\kniffka\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Idaho-vaccine\\"


#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "ali"))
   
  
files = [i for i in os.listdir(src) if i.startswith("Doses") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "Doses Table Completed.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "Doses Table Completed"+timestr+".xlsx")
os.rename(old_file, new_file)

###########################
files = [i for i in os.listdir(src) if i.startswith("Last ") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "Last Updated_Footnote.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "Last Updated_Footnote"+timestr+".xlsx")
os.rename(old_file, new_file)


#########################

files = [i for i in os.listdir(src) if i.startswith("US") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "US Percent Vaccinated.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-vaccine", "US Percent Vaccinated"+timestr+".xlsx")
os.rename(old_file, new_file)



 