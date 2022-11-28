# -*- coding: utf-8 -*-
"""
Created on Mon Oct 10 16:33:23 2022

@author: Muhammad
"""
import time
import warnings
import os
from os import path
from pathlib import Path
import shutil

from selenium.webdriver.common.action_chains import ActionChains
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup

warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")
# path = r"N:\COVerAGE-DB\Automation\chromedriver104\chromedriver.exe"
#path = r"F:\job-paper\selenuim\105\chromedriver.exe"
src = r"C:\Users\Krishnan\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Lebanon\\"

chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
options.add_argument("--enable-javascript")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()

driver.get("https://impactpublicdashboard.cib.gov.lb/s/public/app/kibana#/dashboard/5fb54c50-5ff7-11eb-8575-354d83bf82d9?embed=true&_g=h@51b6606&_a=h@673a298")
driver.switch_to.window(driver.current_window_handle)

def copyFileAndRename(old_file_name, new_file_name):
    move_file_path = dst+new_file_name
    org_file_path  = src+old_file_name
    
    my_file = Path(dst+new_file_name)
    if my_file.is_file():
        # file exists
        os.remove(move_file_path)
    shutil.copy(org_file_path,move_file_path)
    os.remove(org_file_path)
    
time.sleep(50)



htmlCode=BeautifulSoup(driver.page_source,'html.parser')
download_button1 = driver.find_elements(By.XPATH, '//*[@class="euiButtonIcon euiButtonIcon--text embPanel__optionsMenuButton"]')[35]
download_button1.click()
time.sleep(10)


download_button1 = driver.find_elements(By.XPATH, '//*[@class="euiContextMenuItem__text"]')[0]
download_button1.click()
time.sleep(10)

download_button1 = driver.find_elements(By.XPATH, '//*[@class="euiButton__text"]')[1]
download_button1.click()
time.sleep(10)

download_button1 = driver.find_elements(By.XPATH, '//*[@class="euiContextMenuItem"]')[0]
download_button1.click()
time.sleep(10)

copyFileAndRename("Vaccine by age (and if belongs to health).csv",f"Vaccination_age_{timestr}.csv")
time.sleep(10)
driver.quit()