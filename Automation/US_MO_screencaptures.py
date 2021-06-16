
"""
Created on Thu Dec 21

@author: TR
"""


path = r"N:\COVerAGE-DB\Automation\chromedriver\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from time import sleep

options=Options()
#options.add_argument("--enable-javascript")
options.add_argument("--headless")
driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome("/usr/bin/chromedriver",chrome_options=options) #Path of Chrome Driver



URL = 'https://showmestrong.mo.gov/public-healthcare-demographics/'

driver.get(URL)
sleep(25)

# S = lambda X: driver.execute_script('return document.body.parentNode.scroll'+X)
# driver.set_window_size(1920,S('Height')) # May need manual adjustment
driver.set_window_size(1920,3000)
sleep(3)
driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_demo.png")
#driver.get_screenshot_as_file("test.png")

driver.quit()

URL2 = 'https://showmestrong.mo.gov/data/public-health/'
driver = webdriver.Chrome(options=options,executable_path = path)
driver.get(URL2)
sleep(25)
driver.set_window_size(1920,2000)
sleep(3)
driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_totals.png")
driver.quit()
