# -*- coding: utf-8 -*-
"""
Created on Tue Mar  2 23:11:01 2021

@author: waqar
"""


import time

import os
from os import path
import shutil



timestr = time.strftime("%Y%m%d")

src = r"C:\Users\kniffka\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\USA-Vaccine\\"


files = [i for i in os.listdir(src) if i.startswith("age_groups_of_people_fully_vaccinated") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))

files = [i for i in os.listdir(src) if i.startswith("age_groups_of_people_with_at_least_one_dose_administered") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))

files = [i for i in os.listdir(src) if i.startswith("sex_of_people_fully_vaccinated") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))

files = [i for i in os.listdir(src) if i.startswith("sex_of_people_with_at_least_one_dose_administered") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))


#os.remove(r"C:\Users\kniffka\Downloads\age_groups_of_people_with_1_or_more_doses_administered.csv")
#os.remove(r"C:\Users\kniffka\Downloads\age_groups_of_people_with_2_doses_administered.csv")
#os.remove(r"C:\Users\kniffka\Downloads\sex_of_people_with_1_or_more_doses_administered.csv")
#os.remove(r"C:\Users\kniffka\Downloads\sex_of_people_with_2_doses_administered.csv")



old_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "age_groups_of_people_fully_vaccinated.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "age_groups_of_people_fully_vaccinated"+timestr+".csv")
os.rename(old_file, new_file)

old_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "age_groups_of_people_with_at_least_one_dose_administered.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "age_groups_of_people_with_at_least_one_dose_administered"+timestr+".csv")
os.rename(old_file, new_file)

old_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "sex_of_people_fully_vaccinated.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "sex_of_people_fully_vaccinated"+timestr+".csv")
os.rename(old_file, new_file)

old_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "sex_of_people_with_at_least_one_dose_administered.csv")
new_file = os.path.join(r"N:\COVerAGE-DB\Automation\USA-Vaccine", "sex_of_people_with_at_least_one_dose_administered"+timestr+".csv")
os.rename(old_file, new_file)







