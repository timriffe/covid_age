# -*- coding: utf-8 -*-
"""
Created on Sat Feb  6 01:29:27 2021

@author: waqar
"""

#!/usr/bin/env python
# coding: utf-8

# In[1]:

path = r"N:\COVerAGE-DB\Automation\chromedriver104\chromedriver.exe"
import pandas as pd
import requests
import time
from urllib.parse import urlparse
from bs4 import BeautifulSoup as bs
import re
import urllib
#from fake_useragent import UserAgent
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service as ChromeService
url="https://covid19.health.gov.mv/dashboard/list/?c=0"
#ua = UserAgent(use_cache_server=False)
#headers = { 'User-Agent': ua.chrome}
listOfPost=[]


# In[2]:
chrome_driver = ChromeDriverManager(cache_valid_range=7).install()
#chrome_driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager(cache_valid_range=7).install()))
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
browser = Chrome(chrome_driver,options=options)
browser.maximize_window()

browser.get(url)
time.sleep(50)
htmlCode=bs(browser.page_source,'html.parser')

timestr = time.strftime("%Y%m%d")

# In[3]:


forumData=htmlCode.find_all('div',{"class":"covid_table collapsed"})


# In[4]:



# In[7]:



# In[11]:


caseID=htmlCode.find_all('div',{"class":"case_id"})


# In[9]:


ageID=htmlCode.find_all('div',{"class":"case_age"})
gender=htmlCode.find_all('div',{"class":"case_gender"})
nationality=htmlCode.find_all('div',{"class":"case_nationality"})
patientCondition=htmlCode.find_all('div',{"class":"case_condition"})
transmission=htmlCode.find_all('div',{"class":"case_infection"})
patientCluster=htmlCode.find_all('div',{"class":"cluster"})
confirmationDate=htmlCode.find_all('div',{"class":"case_confirmed"})
recoveryDate=htmlCode.find_all('div',{"class":"case_recovered"})
dateDeceased=htmlCode.find_all('div',{"class":"case_deceased"})


# In[17]:


caseList=[]
for a in caseID:
    caseList.append(a.get_text())
    


# In[19]:


ageList=[]
for a in ageID:
    ageList.append(a.get_text())


# In[21]:


genderList=[]
for a in gender:
    genderList.append(a.get_text())


# In[23]:


nationalityList=[]
for a in nationality:
    nationalityList.append(a.get_text())


# In[24]:


patientconditionList=[]
for a in patientCondition:
    patientconditionList.append(a.get_text())


# In[25]:


transmissionList=[]
for a in transmission:
    transmissionList.append(a.get_text())


# In[26]:


clusterList=[]
for a in patientCluster:
    clusterList.append(a.get_text())


# In[28]:


confirmationList=[]
for a in confirmationDate:
    confirmationList.append(a.get_text())


# In[31]:


recoveryList=[]
dischargeList=[]
k=0
for a in recoveryDate:
    if(k==0):
        recoveryList.append(a.get_text())
        k=1
    else:
        dischargeList.append(a.get_text())
        k=0
        


# In[34]:


deceasedList=[]
for a in dateDeceased:
    deceasedList.append(a.get_text())


# In[38]:


columns=["CASE","AGE","GENDER","NATIONALITY","CONDITION","TRANSMISSION","CLUSTER","CONFIRMED ON","RECOVERED ON","DISCHARGED ON","DECEASED ON"]
data = pd.DataFrame(columns=columns)


# In[39]:





# In[40]:


data["CASE"]=caseList
data["AGE"]=ageList
data["GENDER"]=genderList
data["NATIONALITY"]=nationalityList
data["CONDITION"]=patientconditionList
data["TRANSMISSION"]=transmissionList
data["CLUSTER"]=clusterList
data["CONFIRMED ON"]=confirmationList
data["RECOVERED ON"]=recoveryList
data["DISCHARGED ON"]=dischargeList
data["DECEASED ON"]=deceasedList


# In[41]:





# In[42]:


#data.to_excel("F:\rostock-master\job-project\projects\Data\output1.xlsx")

data.to_excel(r"N:\COVerAGE-DB\Automation\Maldives\Maldives"+timestr+".xlsx", index=False)

#new_file = os.path.join(r"N:\COVerAGE-DB\Automation\Oregon", "Demographic Data - Death"+timestr+".xlsx")


#data.to_csv("F:\rostock-master\job-project\projects\Data\output1.csv")

#data.to_csv(r"N:\COVerAGE-DB\Automation\Maldives\output1.csv",index=False)

browser.quit()


# In[ ]:




