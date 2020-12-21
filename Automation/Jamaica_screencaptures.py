
"""
Created on Thu Dec 17

@author: TR, MG
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
#driver = webdriver.Chrome(chrome_options=options) #Path of Chrome Driver



URL = 'https://jamcovid19.moh.gov.jm/index.html'

driver.get(URL)
sleep(3)
driver.find_element_by_xpath('//button[@class="btn btn-warning d-block mx-auto btn-continue"]').click()
sleep(1)
S = lambda X: driver.execute_script('return document.body.parentNode.scroll'+X)
driver.set_window_size(1920,S('Height')) # May need manual adjustment
driver.find_element_by_tag_name('body').screenshot('N:/COVerAGE-DB/Automation/Hydra/Data_sources/Jamaica/jamaica_demo.png')

driver.quit()
