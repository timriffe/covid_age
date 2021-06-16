
"""
Created on Thu Dec 17

@author: TR, MG
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
#driver = webdriver.Chrome(chrome_options=options) #Path of Chrome Driver



URL = 'https://jamcovid19.moh.gov.jm/index.html'

driver.get(URL)
sleep(25)
driver.find_element_by_xpath('//button[@class="btn btn-warning d-block mx-auto btn-continue"]').click()
sleep(3)
# S = lambda X: driver.execute_script('return document.body.parentNode.scroll'+X)
# driver.set_window_size(1920,S('Height')) # May need manual adjustment
driver.set_window_size(1920,4500)
sleep(3)
driver.find_element_by_tag_name('body').screenshot('N:/COVerAGE-DB/Automation/Hydra/Data_sources/Jamaica/jamaica_demo.png')
#driver.set_window_size(1920,4500)
#driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Jamaica/jamaica_demo2.png")
driver.quit()
