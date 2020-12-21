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
driver.get("https://tableau.azdhs.gov/views/COVID19Demographics/EpiData?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Ftableau.azdhs.gov%2F&:embed_code_version=3&:tabs=no&:toolbar=no&:showAppBanner=false&:display_spinner=no&iframeSizedToWindow=true&:loadOrderID=0")
sleep(15)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_demo.png")
#driver.get_screenshot_as_file("US_AZ_demo.png")

driver.quit()
