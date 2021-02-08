
"""
Created on Thu Dec 21

@author: TR
"""


path = "N:\COVerAGE-DB\Automation\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from time import sleep

options=Options()
#options.add_argument("--enable-javascript")
options.add_argument("--headless")
driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome("/usr/bin/chromedriver",chrome_options=options) #Path of Chrome Driver

URL = 'https://e.infogram.com/_/fx5xud0FhM7Z9NS6qpxs?src=embed'

driver.get(URL)

driver.set_window_size(1920,4500)
sleep(25)


sleep(5)
driver.get_screenshot_as_file('N:/COVerAGE-DB/Automation/Hydra/Data_sources/El_Salvador/El_Salvador_demo.png')
#driver.get_screenshot_as_file('test.png')

#driver.set_window_size(1920,4500)

driver.quit()
