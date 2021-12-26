# TODO add click on subwindow maximize in upper right corner


path = r"N:\COVerAGE-DB\Automation\chromedriver\version96\chromedriver.exe"
#path = r"G:\\riffe\\covid_age\\Automation\\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from time import sleep

options=Options()
#options.add_argument("--enable-javascript")
options.add_argument("--headless")
driver = webdriver.Chrome(options=options, executable_path = path)
#driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome("/usr/bin/chromedriver",options=options) #Path of Chrome Driver

URL = 'https://gismoldova.maps.arcgis.com/apps/opsdashboard/index.html#/d274da857ed345efa66e1fbc959b021b'

driver.get(URL)
driver.set_window_size(1920,2000)
action = ActionChains(driver)
sleep(15)

driver.get_screenshot_as_file('N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_both_sex.png')

age_sex = driver.find_element_by_css_selector("#ember216")
action.move_to_element(age_sex).perform()
age_sex.click()

sleep(3)
driver.get_screenshot_as_file('N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_by_sex.png')

driver.quit()

