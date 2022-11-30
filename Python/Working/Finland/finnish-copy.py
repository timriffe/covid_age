# -*- coding: utf-8 -*-
"""
Created on Tue Mar 16 21:27:44 2021

@author: HP
"""

import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Krishnan\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Finland\\"


#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "ali"))
   
  
files = [i for i in os.listdir(src) if i.startswith("vaccreg") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Finland", "vaccreg.cov19cov.fact_cov19cov.latest.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Finland", "vaccreg.cov19cov.fact_cov19cov.latest"+timestr+".xlsx")
os.rename(old_file, new_file)

