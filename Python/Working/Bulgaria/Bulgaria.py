# -*- coding: utf-8 -*-
"""
Created on Thu Mar 22 13:24:25 2022

@author: Muhammad
"""

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver import Chrome, ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.core.driver_cache import DriverCacheManager
from selenium.webdriver.common.by import By
import os
from os import path
import shutil
from selenium.webdriver.chrome.service import Service as ChromeService

#PATH = r"N:\COVerAGE-DB\Automation\chromedriver\new-version\newest-version\neu-chrome\chromedriver_win32\chromedriver.exe"
#options=Options()
#driver = webdriver.Chrome(chrome_options=options,executable_path = PATH) #Path of Chrome Driver

driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager(cache_manager=DriverCacheManager(valid_range=7)).install()))
#driver = webdriver.Chrome(ChromeDriverManager().install())
#ChromeDriverManager(cache_valid_range=1).install()
#chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
#driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
timestr = time.strftime("%Y%m%d")

data_source = "https://data.egov.bg/data/view/492e8186-0d00-43fb-8f5e-f2b0b183b64f"
src = r"C:\Users\Krishnan\Downloads\\"
dst = "N:\COVerAGE-DB\Automation\Bulgaria\\"

def download():
    time.sleep(20)
    download_button = driver.find_elements(By.XPATH, '//*[@class="btn btn-primary js-ga-event"]')[0]
    download_button.click()
    time.sleep(3)
    
def copyFileAndRename(old_file_name, new_file_name):

    files = os.listdir(src)
    for file in files:
        shutil.copy(path.join(src, file), dst)
        os.remove(os.path.join(src, file))
    
    old_file = os.path.join(dst, old_file_name)    
    new_file = os.path.join(dst, new_file_name)
    os.rename(old_file, new_file)
    
    
driver.get(data_source)
time.sleep(5)
total_statistics = driver.find_element(By.XPATH, "//a[@href='https://data.egov.bg/data/resourceView/e59f95dd-afde-43af-83c8-ea2916badd19']")
ActionChains(driver).move_to_element(total_statistics).click(total_statistics).perform()
download()
copyFileAndRename("Обща статистика за разпространението.csv", "BG_total-"+timestr+".csv")

driver.execute_script("window.history.go(-1)")
time.sleep(5)

by_date_and_age_group = driver.find_element(By.XPATH, "//a[@href='https://data.egov.bg/data/resourceView/8f62cfcf-a979-46d4-8317-4e1ab9cbd6a8']")
ActionChains(driver).move_to_element(by_date_and_age_group).click(by_date_and_age_group).perform()
download()
copyFileAndRename("Разпределение по дата и по възрастови групи.csv", "BG_age-"+timestr+".csv")

driver.quit()

