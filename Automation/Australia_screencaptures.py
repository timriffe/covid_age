
"""
Created on Thu Dec 21

@author: TR
"""

path = r"N:\COVerAGE-DB\Automation\chromedriver\chromedriver.exe"
#path = r"N:\COVerAGE-DB\Automation\chromedriver\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from time import sleep

options=Options()
#options.add_argument("--enable-javascript")
options.add_argument("--headless")
driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome("/usr/bin/chromedriver",chrome_options=options) #Path of Chrome Driver

#aus_url = 'https://www.health.gov.au/news/health-alerts/novel-coronavirus-2019-ncov-health-alert/coronavirus-covid-19-current-situation-and-case-numbers#COVID-19-summary-statistics'

aus_url = 'https://www.health.gov.au/news/health-alerts/novel-coronavirus-2019-ncov-health-alert/coronavirus-covid-19-current-situation-and-case-numbers#accordion27348'

#driver = webdriver.Chrome()
driver.get(aus_url)
driver.set_window_size(1920,10000)
sleep(125)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Australia/Australia_demo.png")
#driver.get_screenshot_as_file("Australia_demo.png")

driver.quit()
