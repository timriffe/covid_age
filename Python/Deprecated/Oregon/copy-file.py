# -*- coding: utf-8 -*-
"""
Created on Wed Dec 16 03:56:16 2020

@author: HP
"""

import time

import os
from os import path
import shutil



timestr = time.strftime("%Y%m%d")

src = r"C:\Users\kniffka\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Oregon\\"


files = [i for i in os.listdir(src) if i.startswith("Demographic Data") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)

os.remove(r"C:\Users\kniffka\Downloads\Demographic Data - Death Status.xlsx")


old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Oregon", "Demographic Data - Death Status.xlsx")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Oregon", "Demographic Data - Death"+timestr+".xlsx")
os.rename(old_file, new_file)