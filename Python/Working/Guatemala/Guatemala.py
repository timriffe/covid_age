# -*- coding: utf-8 -*-
"""
Created on Tue Aug  9 09:18:04 2022

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
from selenium.webdriver.chrome.service import Service as ChromeService


warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Krishnan\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\Guatemala\\"

base_url = 'https://tableros.mspas.gob.gt/covid/'

chrome_driver = ChromeDriverManager(cache_valid_range=7).install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(base_url)
time.sleep(10)



    
def download_case_screening():
     main_menu = driver.find_element(By.XPATH, '//*[@id="sidebarItemExpanded"]/ul[2]/li[2]/a')
     time.sleep(2)
     main_menu.click()
     time.sleep(10)
     tab_2 = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[2]/div[3]/div[2]/div[2]/div/ul/li[3]/a')
     tab_2.click()
     time.sleep(5)
     download_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[2]/div[3]/div[2]/div[2]/div/div/div[3]/div/div/div[1]/button[2]')
     download_button.click()
     time.sleep(5)

def download_deceased_cases():
    main_menu = driver.find_element(By.XPATH, '//*[@id="sidebarItemExpanded"]/ul[2]/li[3]/a')
    time.sleep(2)
    main_menu.click()
    time.sleep(10)
    tab_2 = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[3]/div[2]/div[3]/div[2]/div/ul/li[3]/a')
    tab_2.click()
    time.sleep(5)
    download_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[3]/div[2]/div[3]/div[2]/div/div/div[3]/div/div/div[1]/button[2]')
    download_button.click()
    time.sleep(5)
   
def download_vaccination_gender():
    main_menu = driver.find_element(By.XPATH, '//*[@id="sidebarItemExpanded"]/ul[2]/li[4]/a')
    time.sleep(2)
    main_menu.click()
    time.sleep(10)
    tab_2 = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[4]/div[3]/div[2]/div[1]/div/ul/li[5]/a')
    tab_2.click()
    time.sleep(5)
    download_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[4]/div[3]/div[2]/div[1]/div/div/div[5]/div/div/div[1]/button[2]')
    download_button.click()
    time.sleep(5)

def download_vaccination_age():
    tab_2 = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[4]/div[3]/div[2]/div[2]/div/ul/li[5]/a')
    tab_2.click()
    time.sleep(5)
    download_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[2]/div/section/div/div[4]/div[3]/div[2]/div[2]/div/div/div[5]/div/div/div[1]/button[2]')
    download_button.click()
    time.sleep(5)
    
def copyFileAndRename(old_file_name, new_file_name):
    move_file_path = dst+new_file_name
    org_file_path  = src+old_file_name
    
    my_file = Path(dst+new_file_name)
    if my_file.is_file():
        # file exists
        os.remove(move_file_path)
    shutil.copy(org_file_path,move_file_path)
    os.remove(org_file_path)
   
    
    # files = os.listdir(src)
    # for file in files:
    #     shutil.copy(path.join(src, file), dst)
    #     os.remove(os.path.join(src, file))
    
    # old_file = os.path.join(dst, old_file_name)    
    # new_file = os.path.join(dst, timestr+ new_file_name)
    # if os.path.isfile(new_file): 
    #     os.remove(new_file)
    # os.rename(old_file, new_file)
    
time.sleep(10)

first_tab = driver.find_element(By.XPATH, '//*[@id="shiny-tab-casos_confirmados"]/div[4]/div[3]/div/div[2]/div/ul/li[3]')
ActionChains(driver).move_to_element(first_tab).click(first_tab).perform()
time.sleep(30)
driver.find_element(By.CLASS_NAME, 'buttons-csv').click()
time.sleep(10)
copyFileAndRename("confirmados_edad.csv",f"confirmedcases_{timestr}.csv")
download_case_screening()
copyFileAndRename("sospechosos_edad.csv", f"screenedcases_{timestr}.csv")
download_deceased_cases()
copyFileAndRename("fallecidos_edad.csv", f"deceasedcases_{timestr}.csv")
download_vaccination_gender()
copyFileAndRename("vacunados_sexo.csv", f"vaccination_gender_{timestr}.csv")
download_vaccination_age()
copyFileAndRename("vacunados_edad.csv", f"vaccination_age_{timestr}.csv")
# initiated_vacc_by_sex = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_1']")
# ActionChains(driver).move_to_element(initiated_vacc_by_sex).click(initiated_vacc_by_sex).perform()
# download_crossTab()
# copyFileAndRename("Initiated Vaccinations by Sex.xlsx", "_Initiated Vaccinations by Sex.xlsx")

# completed_vacc_by_sex = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_2']")
# ActionChains(driver).move_to_element(completed_vacc_by_sex).click(completed_vacc_by_sex).perform()
# download_crossTab()
# copyFileAndRename("Completed Vaccinations by Sex.xlsx", "_Completed Vaccinations by Sex.xlsx")

# completed_vacc_by_age = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_8']")
# ActionChains(driver).move_to_element(completed_vacc_by_age).click(completed_vacc_by_age).perform()
# download_crossTab()
# copyFileAndRename("Completed Vaccinations by Age Group.xlsx", "_Completed Vaccinations by Age Group.xlsx")

driver.quit()