# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 11:59:47 2022

@author: Hassan
"""

import urllib
import requests
from bs4 import BeautifulSoup as soup
import time
import pandas as pd
import numpy as np 
import warnings
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
import re
import json

warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")
base_url = 'https://vaccines.ncdc.ge/statistics/'

r = requests.get(base_url)
soup = soup(r.text, "html.parser")

content = soup.find("div", attrs={"class":"row row-cols-2"})

vaccinations_info = content.find_all("div", attrs={"class":"textwidget"})

vaccinations_performed = vaccinations_info[0].text
fully_vaccinated = vaccinations_info[1].text


#PATH = r"N:\COVerAGE-DB\Automation\chromedriver104\chromedriver.exe"
#driver = webdriver.Chrome(PATH) 

chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(base_url)
iframe = driver.find_elements(By.TAG_NAME, 'iframe')[1]
driver.switch_to.frame(iframe)

driver.refresh()
driver.implicitly_wait(10)
script = [t.get_attribute("innerHTML") for t in driver.find_elements(By.TAG_NAME, "script") if "window.infographicData" in t.get_attribute("innerHTML")]
check = script[0].split("=",1)[1].replace(";", "")
data = json.loads(check)

graph_info = data["elements"]["content"]["content"]["entities"]["c7290af4-243c-4de9-969e-5e2e73baa631"]["props"]["chartData"]["data"]
dataset = []
for i in graph_info[0]:
    row = tuple(i)
    dataset.append(row)

x = ["The Vaccinations Performed are " + vaccinations_performed]
y = ["The Fully vaccinated are " + fully_vaccinated]
dataset.append(x)
dataset.append(y)
numpy_data = np.array(dataset)
result = pd.DataFrame.from_records(numpy_data)   
result.to_excel(r"N:\COVerAGE-DB\Automation\Georgia\vaccinations"+timestr+".xlsx",encoding="utf-8-sig", index=False)  

driver.quit()





