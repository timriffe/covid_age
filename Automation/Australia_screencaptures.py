
"""
Created on Thu Dec 21

@author: TR
"""


path = "N:\COVerAGE-DB\Automation\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from time import sleep

options=Options()
#options.add_argument("--enable-javascript")
#options.add_argument("--headless")
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome("/usr/bin/chromedriver",chrome_options=options) #Path of Chrome Driver

aus_url = 'https://www.health.gov.au/news/health-alerts/novel-coronavirus-2019-ncov-health-alert/coronavirus-covid-19-current-situation-and-case-numbers#cases-and-deaths-by-age-and-sex'

#driver = webdriver.Chrome()
driver.get(aus_url)
driver.set_window_size(1920,4500)
sleep(45)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Australia/Australia_demo.png")
#driver.get_screenshot_as_file("Australia_demo.png")

driver.quit()
