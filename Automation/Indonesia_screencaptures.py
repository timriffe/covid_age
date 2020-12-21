
"""
Created on Mon Dec 21, 2020
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
options.add_argument('--headless')
options.add_argument('--start-maximized')
#driver = webdriver.Chrome('/usr/bin/chromedriver',options=options)
driver = webdriver.Chrome(options=options,executable_path = path) #Path of Chrome Driver
#driver = webdriver.Chrome(chrome_options=options) #Path of Chrome Driver


#driver = webdriver.Chrome()
driver.get("https://covid19.go.id/peta-sebaran")
sleep(10)

   
#the element with longest height on page
ele=driver.find_element("xpath", '//*[@id="onlymaxheight"]/section[3]')
total_height = ele.size["height"]+1000

driver.set_window_size(1920, total_height)      #the trick
sleep(2)
#driver.save_screenshot("test.png")
#driver.quit()


# driver.find_element_by_xpath('/html/body/div[1]/div[1]/div[8]/div[2]/div[11]/div/div[1]').click()
#driver.find_element_by_css_selector('body > div.container-fluid > div.row > div:nth-child(8) > div.row > div:nth-child(11) > div > div.panel-heading').click()
#bd = driver.find_elements_by_tag_name('body')


#sleep(5)
#bd.screenshot("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Indonesia/Indonesia_demo.png")
driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Indonesia/Indonesia_demo.png")
#driver.get_screenshot_as_file("test.png")

driver.quit()






