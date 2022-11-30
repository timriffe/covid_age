from bs4 import BeautifulSoup as soup
import time
import pandas as pd
import numpy as np
import warnings
import requests
import re
from selenium import webdriver
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager

warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")
src = "https://covid19som-ochasom.hub.arcgis.com/"


chrome_driver = ChromeDriverManager().install()
options = ChromeOptions()
options.add_argument("--disable-notifications")
driver = Chrome(chrome_driver,options=options)
driver.maximize_window()
driver.get(src)

time.sleep(25)
iframe = driver.find_element("xpath", '//*[@id="clka8efgs"]/div/iframe')
driver.execute_script("arguments[0].scrollIntoView();", iframe)
driver.switch_to.frame(iframe)

time.sleep(25)
dock_elements = driver.find_elements(By.CLASS_NAME, "dock-element")

time.sleep(10)
total_cases = dock_elements[0].find_elements(By.CLASS_NAME, "responsive-text-label")[1].text
total_deaths = dock_elements[3].find_elements(By.CLASS_NAME, "responsive-text-label")[1].text

cases_by_age = dock_elements[10]


time.sleep(5)
age_group = cases_by_age.find_elements(By.CLASS_NAME, "amcharts-category-axis")[2]
age = [age.get_attribute("innerHTML") for age in age_group.find_elements(By.TAG_NAME, ("tspan"))]


content = soup(cases_by_age.get_attribute("outerHTML"), 'html.parser')

confirmed_info = content.find_all("g", attrs={"aria-label": re.compile(r"^Confirmed cases\s")})
confirmed = [c["aria-label"] for c in confirmed_info]
confirmed_nums = [round(float(val.split()[-1])*100, 1) for val in confirmed]

death_info = content.find_all("g", attrs={"aria-label": re.compile(r"^Deaths\s")})
death = [c["aria-label"] for c in death_info]
death_nums = [round(float(val.split()[-1])*100, 1) for val in death]

headings = ["Confirmed cases", "Death cases"]
data = list(zip(confirmed_nums, death_nums))

result = pd.DataFrame.from_records(data, columns = headings)  
result.index = age
result.to_excel(r"N:\COVerAGE-DB\Automation\Somalia\cases_by_age_"+timestr+".xlsx",encoding="utf-8-sig")  

cases_by_gender = dock_elements[11]
gender_percentages = cases_by_gender.find_elements(By.CLASS_NAME, "amcharts-pie-item")
gender_info = [gender.get_attribute("aria-label") for gender in gender_percentages ]

other_data = []
x = ["The total cases are "+ str(total_cases)]
y = ["The total deaths are " + str(total_deaths)]
z = ["Cases by gender are"]


other_data.extend([x,y,z])
gender_info = [[gender + " cases"] for gender in gender_info]
other_data.extend(gender_info)
info = pd.DataFrame.from_records(other_data)
info.to_excel(r"N:\COVerAGE-DB\Automation\Somalia\info_and_cases_by_gender_"+timestr+".xlsx",encoding="utf-8-sig", index=False, header= False)  

# sample = open(r"N:\COVerAGE-DB\Automation\Somalia\info_and_cases_by_gender_"+timestr+".txt","w")
# sample.write("The total cases are "+ str(total_cases) +"\nThe total deaths are " + str(total_deaths)
#              +"\nCases by gender are:\n " + ' cases and '.join(gender_info) + " cases")
# sample.close()

driver.quit()