# -*- coding: utf-8 -*-
"""
Created on Tue Mar  2 23:07:41 2021

@author: waqar
"""

# -*- coding: utf-8 -*-


from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.remote.webelement import WebElement




path = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newer-version\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time
options=Options()
options.add_argument("--enable-javascript")
#options.add_argument("--headless")
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver
driver.get("https://covid.cdc.gov/covid-data-tracker/#vaccination-demographics-trends")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.4

time.sleep(15)



htmlCode=BeautifulSoup(driver.page_source,'html.parser')





download_button1 = driver.find_elements_by_xpath('//*[@class="ui basic button buttonExportBtn"]')[2]

download_button1.click()
time.sleep(5)


download_button2 = driver.find_elements_by_xpath('//*[@class="theme-cyan ui btn dwm-data-btn"]')[2]

download_button2.click()
time.sleep(5)

download_button3 = driver.find_elements_by_xpath('//*[@class="ui basic button buttonExportBtn"]')[3]

download_button3.click()
time.sleep(5)


download_button4 = driver.find_elements_by_xpath('//*[@class="theme-cyan ui btn dwm-data-btn"]')[3]

download_button4.click()
time.sleep(5)


download_button5 = driver.find_elements_by_xpath('//*[@class="ui basic button buttonExportBtn"]')[4]

download_button5.click()
time.sleep(5)


download_button6 = driver.find_elements_by_xpath('//*[@class="theme-cyan ui btn dwm-data-btn"]')[4]

download_button6.click()
time.sleep(5)

download_button7 = driver.find_elements_by_xpath('//*[@class="ui basic button buttonExportBtn"]')[5]

download_button7.click()
time.sleep(5)


download_button8 = driver.find_elements_by_xpath('//*[@class="theme-cyan ui btn dwm-data-btn"]')[5]

download_button8.click()
time.sleep(5)


driver.quit()
    
    
