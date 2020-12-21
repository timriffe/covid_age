
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


#driver = webdriver.Chrome()
driver.get("https://covid19.go.id/peta-sebaran")
sleep(25)

driver.find_element_by_xpath('/html/body/div[1]/div[1]/div[8]/div[2]/div[11]/div/div[2]/div/div/ul/li[1]/a"]').click()
sleep(5)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Indonesia/Indonesia_demo.png")
#driver.get_screenshot_as_file("US_AZ_demo.png")

driver.quit()






