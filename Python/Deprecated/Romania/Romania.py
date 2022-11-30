# -*- coding: utf-8 -*-
"""
Created on Fri Apr 30 18:07:23 2021

@author: Waqar
"""


link="https://datelazi.ro/?fbclid=IwAR16qCUg2-_aEWNKj8jwkgTFIVgunF2T3W8Whb3sQqn1KB3xG7Rems0JHcI"
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
import os
from os import path
import shutil

chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(link)
#driver.switch_to.window(driver.current_window_handle)

timestr = time.strftime("%Y%m%d")
time.sleep(10)

download_button1 = driver.find_elements_by_xpath('//*[@class="button is-primary is-light"]')[0]
download_button1.click()
time.sleep(5)


#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
#time.sleep(5)
#download_button1 = driver.find_elements_by_xpath('//*[@class="highcharts-a11y-proxy-button"]')[0]
#print(len(download_button1))
#time.sleep(5)
#download_button1.click()
#time.sleep(5)
#driver.quit()


time.sleep(10)
data = driver.find_elements_by_xpath('//*[@class="pie-chart"]')
ss=data[0].text.split("\n")
age = ss[0:ss.index("în procesare")+1]
numbers = ss[ss.index("în procesare")+1:]
final_numbers = []
for i in numbers:
    if "(" in i:
        final_numbers.append(i)
final_numbers.reverse()
age.reverse()
data = {'Age':age,
        'Numbers': final_numbers
       }
data = pd.DataFrame(data)


data.to_excel(f"N:\COVerAGE-DB\Automation\Romania\AgeData_{timestr}.xlsx", index=False)

src = r"C:\Users\Muhammad\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Romania\\"


new_name = "Romania - Death"+timestr+".json"
files = [i for i in os.listdir(src) if i.startswith("date") and path.isfile(path.join(src, i))]
for f in files:
    shutil.copy(path.join(src, f), dst)
    os.remove(os.path.join(src, f))
    
driver.quit()
