# -*- coding: utf-8 -*-
"""
Created on Thu Mar 17 20:04:56 2022

@author: Muhammad
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Aug  4 15:17:54 2021

@author: Waqar
"""




path = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\neu-chrome\chromedriver_win32\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time
options=Options()
options.add_argument("--enable-javascript")
#options.add_argument("--headless")
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver
driver.get("https://e.infogram.com/e44a9c09-edcd-4524-b2e0-8aa4aea90b4a?parent_url=https%3A%2F%2Fwww.covid.is%2Fdata&src=embed#")
#driver.get("https://e.infogram.com/ba2b3984-c76f-474c-bea6-f13349bfbf79?parent_url=https%3A%2F%2Fwww.covid.is%2Ftolulegar-upplysingar&src=embed&fbclid=IwAR0j9DCIKi_C_mHKsQM4pUc1y5zUjB-hdCeza8mFtdYriMZiranAHNpwADA#async_embed%22")
#driver.get("https://public.tableau.com/vizql/w/DPHIdahoCOVID-19Dashboard/v/DeathDemographics/viewData/sessions/7F352E4EC61B4E73B4E392C121208325-0:0/views/10683951929831089226_10461290144834891492?maxrows=200&viz=%7B%22worksheet%22%3A%22Age%20Groups%22%2C%22dashboard%22%3A%22Death%20Demographics%22%7D")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(15)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
print(htmlCode)
#time.sleep(15)


download_button1 = driver.find_elements_by_xpath('//*[@class="igc-data-download-icon"]')[0]
download_button1.click()
time.sleep(5)


driver.quit()






