
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
#driver = webdriver.Chrome(chrome_options=options) #Path of Chrome Driver


URL = 'https://covid19.gob.sv/'

driver.get(URL)

# S = lambda X: driver.execute_script('return document.body.parentNode.scroll'+X)
# driver.set_window_size(1920,S('Height')) # May need manual adjustment
driver.set_window_size(1920,4500)
sleep(25)

element = driver.find_element_by_css_selector('#ecb6c8f2-75e1-4a0f-aae4-87ebb7d0958b > div.ContentBlock__ContentWrapper-sizwox-2.haiZJd > div > div:nth-child(38) > div > div > div > div > svg')

actions = ActionChains(driver)
actions.move_to_element(element).perform()

sleep(5)
driver.get_screenshot_as_file('N:/COVerAGE-DB/Automation/Hydra/Data_sources/El_Salvador/El_Salvador_demo.png')
#driver.set_window_size(1920,4500)

driver.quit()
