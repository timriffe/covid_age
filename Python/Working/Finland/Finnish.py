# -*- coding: utf-8 -*-
"""
Created on Thu Mar  4 19:05:18 2021

@author: HP
"""

from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.remote.webelement import WebElement




from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.core.driver_cache import DriverCacheManager


#PATH = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\chromedriver.exe"
#path = r"N:\COVerAGE-DB\Automation\chromedriver104\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service as ChromeService
from bs4 import BeautifulSoup
import time


#options=Options()
#options.add_argument("--enable-javascript")
#options.add_argument("--headless")
#driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver

#chrome_driver = ChromeDriverManager().install()
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager(cache_manager=DriverCacheManager(valid_range=7)).install()))
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
#driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get("https://sampo.thl.fi/pivot/prod/fi/vaccreg/cov19cov/summary_cov19covagearea")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.4

time.sleep(15)



htmlCode=BeautifulSoup(driver.page_source,'html.parser')
print(htmlCode)




download_button1 = driver.find_elements(By.XPATH, '//*[@class="col-md-auto"]')[0]

download_button1.click()
time.sleep(10)

driver.find_elements(By.XPATH, '//*[@class="dropdown-item"]')[3].click()
#download_button2 = driver.find_elements(By.XPATH, '//*[@class="dropdown-item"]')[1]


#download_button2.click()
time.sleep(5)
"""
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


#driver.execute_script(script, args)

#driver.execute_script("document.getElementsByClassName('highcharts-button-box')[6].click()")


#button = driver.find_element_by_class_name('highcharts-button-symbol')
#driver.execute_script('arguments[6].click();', button)

#driver.find_element_by_class_name('highcharts-button-symbol').click()

#driver.find_elements_by_css_selector("[aria-label=View chart menu]")

#download_button1 = driver.find_element_by_xpath("//div[@aria-label='View chart menu']/div[@class='highcharts-a11y-proxy-button']");

#time.sleep(5)
#download_button1.click()


"""

driver.quit()
    
    
