# -*- coding: utf-8 -*-
"""
Created on Fri Apr  9 23:10:17 2021

@author: waqar
"""

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




src = r"C:\Users\waqar\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Oregan-Vaccine\\"


files = [i for i in os.listdir(src) if i.startswith("Demographics") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
 

old_file = os.path.join(r"N:\COVerAGE-DB\Automation\Oregan-Vaccine", "Demographics_crosstab.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Oregan-Vaccine", "Demographics_crosstab"+timestr+".csv")
os.rename(old_file, new_file)