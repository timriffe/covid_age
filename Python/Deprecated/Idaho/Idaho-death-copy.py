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
dst = r"N:\COVerAGE-DB\Automation\Idaho\\"



#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "Muhammad"))
 


files = [i for i in os.listdir(src) if i.startswith("Age") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Age Groups.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Age Groups"+timestr+".xlsx")
os.rename(old_file, new_file)

###########################
files = [i for i in os.listdir(src) if i.startswith("Sex") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Sex.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Sex"+timestr+".xlsx")
os.rename(old_file, new_file)


#########################


files = [i for i in os.listdir(src) if i.startswith("Total") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Total Deaths (2).xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Idaho", "Total Deaths (2)"+timestr+".xlsx")
os.rename(old_file, new_file)
