# -*- coding: utf-8 -*-
"""
Created on Tue Apr 12 23:39:17 2022

@author: Muhammad
"""
from bs4 import BeautifulSoup as soup
import pandas as pd
import time
import numpy as np
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager


timestr = time.strftime("%Y%m%d")

chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
src = "https://www.health.gov.au/health-alerts/covid-19/case-numbers-and-statistics"
driver.get(src)    
time.sleep(25)
 

h3_cases = driver.find_element_by_id("DataTables_Table_2_wrapper")
driver.execute_script("arguments[0].scrollIntoView();", h3_cases)
time.sleep(25)
cases_tag = h3_cases.find_element_by_xpath('..')
cases_table = cases_tag.find_element_by_tag_name('table').get_attribute("innerHTML")
cases_soup = soup(cases_table, 'html.parser')
cases_headers = [th.get_text().strip() for th in cases_soup.find("thead").find("tr").find_all("th")]
cases_dataset = []
rows_of_cases = cases_soup.find("tbody").find_all("tr")
for row in rows_of_cases:
    details = tuple([td.get_text().strip() for td in row.find_all("td")])
    cases_dataset.append(details)
numpy_cases = np.array(cases_dataset)


cases = pd.DataFrame.from_records(numpy_cases, columns = cases_headers) 
cases.to_excel(r"N:\COVerAGE-DB\Automation\Australia\Cases by age group and sex"+timestr+".xlsx",encoding="utf-8-sig", index=False)


h3_deathes = driver.find_element_by_id("DataTables_Table_3_wrapper")
driver.execute_script("arguments[0].scrollIntoView();", h3_deathes)
time.sleep(25)
deathes_tag = h3_deathes.find_element_by_xpath('..')
deathes_table = deathes_tag.find_element_by_tag_name('table').get_attribute("innerHTML")
deathes_soup = soup(deathes_table, 'html.parser')
deathes_headers = [th.get_text().strip() for th in deathes_soup.find("thead").find("tr").find_all("th")]
deathes_dataset = []
rows_of_deathes = deathes_soup.find("tbody").find_all("tr")
for row in rows_of_deathes:
    details = tuple([td.get_text().strip() for td in row.find_all("td")])
    deathes_dataset.append(details)
numpy_deathes = np.array(deathes_dataset)

deathes = pd.DataFrame.from_records(numpy_deathes, columns = deathes_headers) 
deathes.to_excel(r"N:\COVerAGE-DB\Automation\Australia\Deathes by age group and sex"+timestr+".xlsx",encoding="utf-8-sig", index=False)
   
driver.quit()