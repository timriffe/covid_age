# -*- coding: utf-8 -*-
"""
Created on Mon Jul 19 15:31:20 2021

@author: Waqar
"""

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
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
import time


chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get("https://public.tableau.com/views/DPHIdahoCOVID-19Dashboard/DeathDemographics?%3Adisplay_static_image=y&%3Aembed=true&%3Aembed=y&%3Alanguage=en-GB&%3AshowVizHome=n&%3AapiID=host0#navType=0&navSrc=Parse")
#driver.get("https://public.tableau.com/vizql/w/DPHIdahoCOVID-19Dashboard/v/DeathDemographics/viewData/sessions/7F352E4EC61B4E73B4E392C121208325-0:0/views/10683951929831089226_10461290144834891492?maxrows=200&viz=%7B%22worksheet%22%3A%22Age%20Groups%22%2C%22dashboard%22%3A%22Death%20Demographics%22%7D")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(15)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
#time.sleep(15)

download_button1 = driver.find_elements_by_xpath('//*[@class="tabToolbarButton tab-widget download"]')[0]
download_button1.click()
time.sleep(5)

print("First Worked")
download_button2 = driver.find_elements_by_xpath('//*[@class="fdofgby low-density"]')[2]
download_button2.click()
time.sleep(10)
print("Second")

#download_button3 = driver.find_elements_by_xpath('//*[@class="thumbnail-wrapper_f1gupj42')[12]
download_button3=driver.find_elements_by_xpath('//span[@class="thumbnail-title_fmb090t"]')[0]
download_button3.click()
print("Third")
time.sleep(5)

download_button3=driver.find_elements_by_xpath('//span[@class="thumbnail-title_fmb090t"]')[0]
download_button3.click()
print("Fourth")
time.sleep(5)


download_button4 = driver.find_elements_by_xpath('//*[@class="fycmrtt low-density"]')[0]
download_button4.click()
time.sleep(10)


#############################
download_button1 = driver.find_elements_by_xpath('//*[@class="tabToolbarButton tab-widget download"]')[0]
download_button1.click()
time.sleep(5)


download_button2 = driver.find_elements_by_xpath('//*[@class="f1odzkbq low-density"]')[2]
download_button2.click()
time.sleep(10)


#download_button3 = driver.find_elements_by_xpath('//*[@class="thumbnail-wrapper_f1gupj42')[12]
download_button3=driver.find_elements_by_xpath('//span[@class="thumbnail-title_fmb090t"]')[6]
download_button3.click()
time.sleep(5)


download_button4 = driver.find_elements_by_xpath('//*[@class="fycmrtt low-density"]')[0]
download_button4.click()
time.sleep(10)

#################################
download_button1 = driver.find_elements_by_xpath('//*[@class="tabToolbarButton tab-widget download"]')[0]
download_button1.click()
time.sleep(5)


download_button2 = driver.find_elements_by_xpath('//*[@class="f1odzkbq low-density"]')[2]
download_button2.click()
time.sleep(10)


#download_button3 = driver.find_elements_by_xpath('//*[@class="thumbnail-wrapper_f1gupj42')[12]
download_button3=driver.find_elements_by_xpath('//span[@class="thumbnail-title_fmb090t"]')[7]
download_button3.click()
time.sleep(5)


download_button4 = driver.find_elements_by_xpath('//*[@class="fycmrtt low-density"]')[0]
download_button4.click()
time.sleep(5)


driver.quit()






