# -*- coding: utf-8 -*-
"""
Created on Sun Aug 22 14:36:45 2021

@author: Waqar
"""

# -*- coding: utf-8 -*-
"""
Created on Sun Aug 22 14:35:29 2021

@author: Waqar
"""

# -*- coding: utf-8 -*-
"""
Created on Sun Aug 22 14:34:08 2021

@author: Waqar
"""

from webdriver_manager.core.driver_cache import DriverCacheManager


#path = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\neu-chrome\chromedriver_win32\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
import time
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.core.driver_cache import DriverCacheManager

driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager(cache_manager=DriverCacheManager(valid_range=7)).install()))
#chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
#driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get("https://covid.cdc.gov/covid-data-tracker/#demographics")
#driver.get("https://public.tableau.com/vizql/w/DPHIdahoCOVID-19Dashboard/v/DeathDemographics/viewData/sessions/7F352E4EC61B4E73B4E392C121208325-0:0/views/10683951929831089226_10461290144834891492?maxrows=200&viz=%7B%22worksheet%22%3A%22Age%20Groups%22%2C%22dashboard%22%3A%22Death%20Demographics%22%7D")
driver.switch_to.window(driver.current_window_handle)

driver.refresh();
#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(10)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
#print(htmlCode)
#time.sleep(15)

#download_button1 = driver.find_element_by_id("demo-export040")
#download_button1.click()
#time.sleep(5)


#download_button1=driver.find_elements_by_xpath('//span[@class="Download"]')[4]
#download_button1.click()
#time.sleep(5)



element = driver.find_element(By.ID, 'demo-export009')
driver.execute_script("arguments[0].click();", element)
time.sleep(5)


element = driver.find_element(By.ID, 'dwn-data-009')
driver.execute_script("arguments[0].click();", element)
time.sleep(5)





driver.quit()






