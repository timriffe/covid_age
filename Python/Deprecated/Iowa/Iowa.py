# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 00:58:48 2020

@author: HP
"""


path = r"N:\COVerAGE-DB\Automation\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time
options=Options()
options.add_argument("--enable-javascript")
#options.add_argument("--headless")
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver
driver.get("https://iowacovid19tracker.org/downloadable-data/")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(10)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
print(htmlCode)
#time.sleep(15)


#carona = bs4.BeautifulSoup(data.text,"html.parser")
download_button1 = driver.find_elements_by_xpath('//*[@class="dt-button buttons-csv buttons-html5 DTTT_button DTTT_button_csv"]')[25]
download_button1.click()
time.sleep(3)

download_button1 = driver.find_elements_by_xpath('//*[@class="dt-button buttons-csv buttons-html5 DTTT_button DTTT_button_csv"]')[24]
download_button1.click()
time.sleep(3)



download_button1 = driver.find_elements_by_xpath('//*[@class="dt-button buttons-csv buttons-html5 DTTT_button DTTT_button_csv"]')[0]
download_button1.click()
time.sleep(3)

driver.quit()








