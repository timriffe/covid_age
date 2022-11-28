# -*- coding: utf-8 -*-
"""
Created on Sat Mar 13 00:21:06 2021

@author: waqar
"""

# -*- coding: utf-8 -*-



from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.remote.webelement import WebElement




from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC



path = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\neu-chrome\chromedriver_win32\chromedriver.exe"
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time
options=Options()
options.add_argument("--enable-javascript")



#options.add_argument("--headless")
driver = webdriver.Chrome(chrome_options=options,executable_path = path) #Path of Chrome Driver

driver.set_window_size(1024, 600)
driver.maximize_window()
driver.get("https://statistikk.fhi.no/sysvak/antall-vaksinerte?etter=diagnose&fordeltPaa=alder&diagnose=COVID_19&dose=01,02,03&kjonn=K,M")
#driver.get("https://statistikk.fhi.no/sysvak/antall-vaksinerte?etter=diagnose&fordeltPaa=alder&diagnose=COVID_19&dose=02,01&kjonn=K,M")
driver.switch_to.window(driver.current_window_handle)


#http://51.222.41.4

time.sleep(15)



htmlCode=BeautifulSoup(driver.page_source,'html.parser')
#print(htmlCode)

"""
driver.execute_script(script, args)
JavascriptExecutor jse = (JavascriptExecutor)driver;

jse.executeScript("arguments[0].scrollIntoView()", Webelement); 

driver.IJavaScriptExecutor ex = (IJavaScriptExecutor)Driver;
ex.ExecuteScript("arguments[0].click();", elementToClick);
#driver.find_element_by_css_selector("highcharts-button-symbol-r").click()
"""

download_button1 = driver.find_elements_by_xpath('//*[@class="fhi-dropdown-last-ned dropdown"]')[0]
download_button1.click()
time.sleep(5)


#download_button2 = driver.find_elements_by_xpath('//*[@class="fhi-dropdown-last-ned__option dropdown-item"]')[1]
download_button2 = driver.find_elements_by_xpath('//*[@class="dropdown-item fhi-dropdown-last-ned__option"]')[1]
download_button2.click()
time.sleep(5)




driver.quit()
    
    
