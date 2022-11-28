# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 01:28:04 2022

@author: Hassan
"""


import time
from selenium import webdriver
import codecs
import os
from bs4 import BeautifulSoup as soup
import re
import pandas as pd
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By

timestr = time.strftime("%Y%m%d")
src = "https://experience.arcgis.com/experience/aa41b29149f24e20a4007a0c4e13db1d"


chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(src)
x = os.path.join("N:\COVerAGE-DB\Automation\Denmark","page_"+timestr+".html")
driver.switch_to.window(driver.current_window_handle)
time.sleep(35)
iframe = driver.find_element(By.ID, 'ifrSafe')
driver.switch_to.frame(iframe)


f = codecs.open(x, "w", "utf−8")
page = driver.page_source
f.write(page)

f.close()

driver.quit()

# f = codecs.open(x, "w", "utf−8")
# soup = soup(f, 'html.parser')

# divs = soup.find_all("div", {"class": "amcharts-chart-div"})
# head_of_graph = divs[3].svg.find('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
# the_gs = head_of_graph.find_all('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
# f.close()
# info = {"age_group": [] , "deaths": []}
# for g in the_gs:
#     split_element = g['aria-label'].split()
#     info['age_group'].append(split_element[0])
#     info['deaths'].append(split_element[1])

# info_df = pd.DataFrame.from_dict(info) 
# info_df.to_excel("Denmark_deaths"+timestr+".xlsx",encoding="utf-8-sig", index=False)