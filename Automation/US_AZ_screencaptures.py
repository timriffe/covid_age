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
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome(chrome_options=options) #Path of Chrome Driver

cases_url = "https://tableau.azdhs.gov/views/COVID19Demographics/EpiData?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Ftableau.azdhs.gov%2F&:embed_code_version=3&:tabs=no&:toolbar=no&:showAppBanner=false&:display_spinner=no&iframeSizedToWindow=true&:loadOrderID=0"
#driver = webdriver.Chrome()
driver.get(cases_url)
sleep(15)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_cases.png")
#driver.get_screenshot_as_file("US_AZ_demo.png")



deaths_url = "https://tableau.azdhs.gov/views/COVID-19Deaths/Deaths?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Ftableau.azdhs.gov%2F&:embed_code_version=3&:tabs=no&:toolbar=no&:showAppBanner=false&:display_spinner=no&iframeSizedToWindow=true&:loadOrderID=4"
driver.get(deaths_url)
sleep(15)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_deaths.png")

tests_url = "https://tableau.azdhs.gov/views/ELRv2testlevelandpeopletested/PeopleTested?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Ftableau.azdhs.gov%2F&:embed_code_version=3&:tabs=yes&:toolbar=no&:showAppBanner=false&:display_spinner=no&:loadOrderID=5"
driver.get(tests_url)
sleep(15)

driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_tests.png")

driver.quit()
