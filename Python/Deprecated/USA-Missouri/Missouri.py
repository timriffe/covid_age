# -*- coding: utf-8 -*-
"""
Created on Thu Mar 10 22:04:25 2022

@author: Muhammad
"""


import time
import warnings
import os
from os import path
import shutil
from selenium.webdriver.common.action_chains import ActionChains
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager



warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")

src = r"C:\Users\Muhammad\Downloads\\"
dst = r"N:\COVerAGE-DB\Automation\USA-Missouri\\"

base_url = 'https://results.mo.gov/t/COVID19/views/COVID-19VaccineDataforDownload/InitiatedVaccinationsbyAgeGroup?%3Aembed=y&%3AshowVizHome=no&%3Ahost_url=https%3A%2F%2Fresults.mo.gov%2F&%3Aembed_code_version=3&%3Atabs=yes&%3Atoolbar=yes&%3AshowAppBanner=false&%3Arefresh=yes&%3Adisplay_spinner=no&%3AloadOrderID=0'

chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(base_url)
time.sleep(10)


def download_crossTab ():
    download_content = driver.find_element_by_id('toolbar-container')
    time.sleep(5)
    download_div = download_content.find_element_by_id("download")
    download_div.click()
    time.sleep(5)
    click_cross_tab = download_content.find_element_by_xpath('//*[@id="viz-viewer-toolbar-download-menu"]/div[3]/div/div/label')
    click_cross_tab.click()
    time.sleep(5)
    click_download = driver.find_element_by_xpath('//*[@id="export-crosstab-options-dialog-Dialog-BodyWrapper-Dialog-Body-Id"]/div/div[3]/button')
    click_download.click()
    time.sleep(20)
    
    
def copyFileAndRename(old_file_name, new_file_name):
    
    files = os.listdir(src)
    for file in files:
        shutil.copy(path.join(src, file), dst)
        os.remove(os.path.join(src, file))
    
    old_file = os.path.join(dst, old_file_name)    
    new_file = os.path.join(dst, timestr+ new_file_name)
    if os.path.isfile(new_file): 
        os.remove(new_file)
    os.rename(old_file, new_file)
    
download_crossTab()
copyFileAndRename("Initiated Vaccinations by Age Group.xlsx","_Initiated Vaccinations by Age Group.xlsx")


initiated_vacc_by_sex = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_1']")
ActionChains(driver).move_to_element(initiated_vacc_by_sex).click(initiated_vacc_by_sex).perform()
download_crossTab()
copyFileAndRename("Initiated Vaccinations by Sex.xlsx", "_Initiated Vaccinations by Sex.xlsx")

completed_vacc_by_sex = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_2']")
ActionChains(driver).move_to_element(completed_vacc_by_sex).click(completed_vacc_by_sex).perform()
download_crossTab()
copyFileAndRename("Completed Vaccinations by Sex.xlsx", "_Completed Vaccinations by Sex.xlsx")

completed_vacc_by_age = driver.find_element_by_xpath("//div[@widgetid='tableauTabbedNavigation_tab_8']")
ActionChains(driver).move_to_element(completed_vacc_by_age).click(completed_vacc_by_age).perform()
download_crossTab()
copyFileAndRename("Completed Vaccinations by Age Group.xlsx", "_Completed Vaccinations by Age Group.xlsx")

driver.quit()