# -*- coding: utf-8 -*-
"""
Created on Sun Aug 22 13:47:42 2021

@author: Waqar
"""

import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Krishnan\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\CDC\\"


#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "ali"))
   
  
files = [i for i in os.listdir(src) if i.startswith("cases_by_age") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "cases_by_age_group.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "cases_by_age_group"+timestr+".csv")
os.rename(old_file, new_file)


###########################

  
files = [i for i in os.listdir(src) if i.startswith("cases_by_sex") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "cases_by_sex__all_age_groups.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "cases_by_sex__all_age_groups"+timestr+".csv")
os.rename(old_file, new_file)




###########################
  
files = [i for i in os.listdir(src) if i.startswith("deaths_by_age") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "deaths_by_age_group.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "deaths_by_age_group"+timestr+".csv")
os.rename(old_file, new_file)



###########################
  
files = [i for i in os.listdir(src) if i.startswith("deaths_by_sex") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "deaths_by_sex__all_age_groups.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\CDC", "deaths_by_sex__all_age_groups"+timestr+".csv")
os.rename(old_file, new_file)

###########################