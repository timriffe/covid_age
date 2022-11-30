# -*- coding: utf-8 -*-
"""
Created on Mon Dec 14 01:40:45 2020

@author: HP
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
driver.get("https://public.tableau.com/views/OregonCOVID-19CaseDemographicsandDiseaseSeverityStatewide-SummaryTable/DemographicDataSummaryTable?%3Aembed=y&%3AshowVizHome=n&%3Adisplay_count=y&%3Adisplay_static_image=y&%3Alanguage=en&%3AapiID=host0&fbclid=IwAR3x5pbI4OeD4RicbJvj1JrDjhD_34SahjlcQA8EJAqp7UEmHp9MhMG9_TM#navType=0&navSrc=Parse")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(15)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
print(htmlCode)
download_button1 = driver.find_elements_by_xpath('//*[@class="tabToolbarButton tab-widget download"]')[0]
download_button1.click()
time.sleep(10)
download_button2 = driver.find_elements_by_xpath('//*[@class="f1odzkbq low-density"]')[2]
download_button2.click()
time.sleep(10)
#download_button3 = driver.find_elements_by_xpath('//*[@class="thumbnail-wrapper_f1gupj42"]//[@title"Demographic Data - Cases Per 100,000"]')

download_button3=driver.find_elements_by_xpath('//span[@class="thumbnail-title_fmb090t"]')[2]
download_button3.click()   
time.sleep(5)
download_button4 = driver.find_elements_by_xpath('//*[@class="fycmrtt low-density"]')[0]
download_button4.click()
time.sleep(5)
#driver.close()
#contains(text(),'qwerty')
title="Demographic Data - Death Status"
#contains(title(),'Demographic Data - Death Status')

time.sleep(10)
driver.quit()


