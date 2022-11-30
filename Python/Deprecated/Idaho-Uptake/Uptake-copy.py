# -*- coding: utf-8 -*-
"""
Created on Mon Aug  9 15:47:35 2021

@author: Waqar
"""

# -*- coding: utf-8 -*-
"""
Created on Mon Jul 19 15:35:56 2021

@author: Waqar
"""

import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Muhammad\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Idaho-Uptake\\"


#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "ali"))
   
  
files = [i for i in os.listdir(src) if i.startswith("County") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "County Bar.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "County Bar_"+timestr+".xlsx")
os.rename(old_file, new_file)

###########################
files = [i for i in os.listdir(src) if i.startswith("Grand Total persons At least") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "Grand Total persons At least.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "Grand Total persons At least_"+timestr+".xlsx")
os.rename(old_file, new_file)


#########################
files = [i for i in os.listdir(src) if i.startswith("Grand Total persons Booster") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "Grand Total persons Booster.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho-Uptake", "Grand Total persons Booster_"+timestr+".xlsx")
os.rename(old_file, new_file)
