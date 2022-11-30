# -*- coding: utf-8 -*-
"""
Created on Sun Feb 14 22:54:25 2021
Modified TR 26 Dec 2021
Note: we have encoding problems at present that prevent the script from running
@author: waqar
"""





import time


from selenium import webdriver
from selenium.webdriver.chrome.options import Options
#gives us access to for i.e Enter, Escape, 
from selenium.webdriver.common.keys import Keys 
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import time
import requests,bs4
import pandas as pd
import warnings

warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")

#PATH = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\neu-chrome\chromedriver_win32\chromedriver.exe"
#driver = webdriver.Chrome(PATH) 


chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get("http://ncov.moh.gov.vn/")
iframe = driver.find_elements_by_tag_name('iframe')[1]
driver.switch_to.frame(iframe)


city_column = driver.find_element_by_class_name("city")
total_num_of_cases_column = driver.find_element_by_class_name("total")
new_cases_column = driver.find_element_by_class_name("daynow")
total_died_column = driver.find_element_by_class_name("die")


data = []
main= driver.find_element_by_class_name('tbody')
rows = main.find_elements_by_class_name('row')
for row in rows:
    city = row.find_element_by_class_name('city')
    total_num_of_cases = row.find_element_by_class_name('total')
    new_cases = row.find_element_by_class_name('daynow')
    total_died = row.find_element_by_class_name('die')
    details = (city.text, total_num_of_cases.text, new_cases.text, total_died.text)
    data.append(details)
   

result = pd.DataFrame(data, 
                      columns = [city_column.text , total_num_of_cases_column.text,
                                new_cases_column.text, total_died_column.text]) 
result.to_excel(r"N:\COVerAGE-DB\Automation\Vietnam\Vietnam"+timestr+".xlsx",encoding="utf-8-sig", index=False)
driver.quit()


