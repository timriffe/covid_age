# -*- coding: utf-8 -*-
"""
Created on Wed Feb  9 13:53:48 2022

@author: Hassan
"""

from bs4 import BeautifulSoup as soup
import re
import pandas as pd
import time
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service as ChromeService

timestr = time.strftime("%Y%m%d")
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager(cache_valid_range=7).install()))
#chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--enable-javascript")
options.add_argument("--disable-notifications")
#driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
#src = "https://experience.arcgis.com/experience/aa41b29149f24e20a4007a0c4e13db1d"
src = "https://experience.arcgis.com/experience/aa41b29149f24e20a4007a0c4e13db1d/page/Smitte-og-vaccine/"


driver.get(src)
driver.switch_to.window(driver.current_window_handle)
time.sleep(35)
iframe = driver.find_element(By.ID, 'ifrSafe')
driver.switch_to.frame(iframe)

time.sleep(35)
soup = soup(driver.page_source, 'html.parser')
divs = soup.find_all("div", {"class": "amcharts-chart-div"})
#print(divs[2])

time.sleep(15)
head_of_graph = divs[0].svg.find('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
the_gs = head_of_graph.find_all('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
# print(the_gs)

info = {"age_group": [] , "deaths": []}
for g in the_gs:
    split_element = g['aria-label'].split()
    # print(split_element)
    info['age_group'].append(split_element[0])
    info['deaths'].append(round(float(split_element[1])))

info_df = pd.DataFrame.from_dict(info) 
info_df.to_excel(r"N:\COVerAGE-DB\Automation\Denmark\Denmark_deaths"+timestr+".xlsx",encoding="utf-8-sig", index=False)

driver.quit()

# code for number of cases graph

# soup = soup(driver.page_source, 'html.parser')
# divs = soup.find("div", {"class": "amcharts-chart-div"})
# head_of_graph = divs.svg.find('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
# the_gs = head_of_graph.find_all('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))

# info = {"age_group": [] , "cases": []}
# for g in the_gs:
#     split_element = g['aria-label'].split()
#     info['age_group'].append(split_element[0])
#     info['cases'].append(split_element[1])

# info_df = pd.DataFrame.from_dict(info)   
# # print(info_df)
# info_df.to_excel("Denmark_deaths"+timestr+".xlsx",encoding="utf-8-sig", index=False)
# # info_df.to_csv("Denmark_cases"+timestr+".csv", index=False)