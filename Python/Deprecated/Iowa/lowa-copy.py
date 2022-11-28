# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 22:27:58 2020

@author: waqar
"""


import time

import os
from os import path
import shutil



timestr = time.strftime("%Y%m%d")

src = r"C:\Users\kniffka\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Iowa\\"


files = [i for i in os.listdir(src) if i.startswith("Statewide Biological") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    
    
files = [i for i in os.listdir(src) if i.startswith("Statewide Age") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)


files = [i for i in os.listdir(src) if i.startswith("Iowa Testing") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    
    
os.remove(r"C:\Users\kniffka\Downloads\Statewide Biological Sex Demographics.csv")

os.remove(r"C:\Users\kniffka\Downloads\Statewide Age Group Demographics.csv")

os.remove(r"C:\Users\kniffka\Downloads\Iowa Testing Data  Percent Change.csv")


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "Statewide Age Group Demographics.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "US_IA_age-"+timestr+".csv")
os.rename(old_file, new_file)


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "Statewide Biological Sex Demographics.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "US_IA_sex-"+timestr+".csv")
os.rename(old_file, new_file)


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "Iowa Testing Data  Percent Change.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iowa", "US_IA_tests-"+timestr+".csv")
os.rename(old_file, new_file)