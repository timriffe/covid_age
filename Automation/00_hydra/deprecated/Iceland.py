"""
Created on Sun Dec 20

@author: TR
"""

path = "N:\COVerAGE-DB\Automation\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
#from bs4 import BeautifulSoup
import time
options=Options()
# options.add_argument("--enable-javascript")
#options.add_argument("--headless")
driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome('/usr/bin/chromedriver',options=options)
driver.get("https://e.infogram.com/deaf4fd6-0ce9-4b82-97ae-11e34a045060?parent_url=https%3A%2F%2Fwww.covid.is%2Fdata&src=embed#")

sleep(5)
el = driver.find_element_by_css_selector('#d1647fa3-f644-4145-b4a6-34fc1565c8d3 > div.ContentBlock__ContentWrapper-sizwox-2.haiZJd > div > div:nth-child(48) > div > a')
el.click()

time.sleep(10)



driver.quit()
