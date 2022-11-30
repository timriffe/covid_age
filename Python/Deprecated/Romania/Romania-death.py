# -*- coding: utf-8 -*-
"""
Created on Mon May 24 15:03:15 2021

@author: Waqar
"""

# -*- coding: utf-8 -*-

link ="https://stirioficiale.ro/informatii/buletin-de-presa-20-mai-2021-ora-13-00"
list1 = link.split("-")

#d1 = today.strftime("%d/%m/%Y")
def date_time_fun():
    from datetime import date
    today = date.today()
    if today.month == 1:
        month,date="ianuarie",today.day
        return month,date 
    if today.month == 2:
        month,date="februarie",today.day
        return month,date
    if today.month == 3:
        month,date="Martie",today.day
        return month,date
    if today.month == 4:
        month,date="aprilie",today.day
        return month,date
    if today.month == 5:
        month,date="mai",today.day
        return month,date
    if today.month == 6:
        month,date="iunie",today.day
        return month,date
    if today.month == 7:
        month,date="iulie",today.day
        return month,date
    if today.month == 8:
        month,date="august",today.day
        return month,date
    if today.month == 9:
        month,date="septembrie",today.day
        return month,date
    if today.month == 10:
        month,date="octombrie",today.day
        return month,date
    if today.month == 11:
        month,date="niembrie",today.day
        return month,date
    if today.month == 12:
        month,date="decembrie",today.day
        return month,date
    
    
month,date=date_time_fun()
created_link = list1[0]+"-"+list1[1]+"-"+list1[2]+"-"+str(date)+"-"+month+"-"+list1[5]+"-"+list1[6]+"-"+list1[7]+"-"+list1[8]


from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time
import requests,bs4
#import pandas as pd
import warnings
warnings.filterwarnings("ignore")
res = requests.get(created_link,verify=False)
soup = bs4.BeautifulSoup(res.content,"html.parser")
data = soup.findAll("p")



timestr = time.strftime("%Y%m%d")



#Saving into File
file = open(r"N:\COVerAGE-DB\Automation\Romania\Romania-death"+timestr+".txt", "w",encoding='utf-8')#Path for File
count = 0
for i in data:
    #list1.append(i)
    if "Dintre" in i.text:
        count = count+1
        #print(i.text,count)
        file.write(i.text)
        file.close()
        if count==1:
            break
    