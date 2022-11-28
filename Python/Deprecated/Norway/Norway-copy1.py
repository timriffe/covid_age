# -*- coding: utf-8 -*-
"""
Created on Fri Mar 12 01:08:20 2021

@author: waqar
"""


import time

import os
from os import path
import shutil


timestr = time.strftime("%Y%m%d")


src = r"C:\Users\Muhammad\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Norway\\"



files = [i for i in os.listdir(src) if i.startswith("2022") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
    
    

