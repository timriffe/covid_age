# -*- coding: utf-8 -*-
"""
Created on Thu Mar 17 20:54:46 2022

@author: Muhammad
"""


import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Muhammad\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Iceland\\"



#for fileName in os.listdir("."):
 #   os.rename(fileName, fileName.replace("2021", "Muhammad"))
 


files = [i for i in os.listdir(src) if i.startswith("Sheet 1") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iceland", "Sheet 1.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Iceland", "Age Groups"+timestr+".csv")
os.rename(old_file, new_file)

