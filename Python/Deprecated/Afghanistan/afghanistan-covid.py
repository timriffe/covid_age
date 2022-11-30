# -*- coding: utf-8 -*-
"""
Created on Tue Dec  1 13:47:04 2020

@author: HP
"""


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
driver.get("http://covidapp.moph-dw.org/")
#driver.get("https://public.tableau.com/vizql/w/DPHIdahoCOVID-19Dashboard/v/DeathDemographics/viewData/sessions/7F352E4EC61B4E73B4E392C121208325-0:0/views/10683951929831089226_10461290144834891492?maxrows=200&viz=%7B%22worksheet%22%3A%22Age%20Groups%22%2C%22dashboard%22%3A%22Death%20Demographics%22%7D")
driver.switch_to.window(driver.current_window_handle)

#http://51.222.41.46/static/js/main.f60b7b53.chunk.js
time.sleep(20)
htmlCode=BeautifulSoup(driver.page_source,'html.parser')
# print(htmlCode)



timestr = time.strftime("%d%m%Y")
#data = htmlCode.findAll("class","col-md-2 col-sm-2 col-lg-2") 
#print(data)
#table = htmlCode.findAll("div", {"class":"col-md-2 col-sm-2 col-lg-2"})
span = htmlCode.findAll('span')[0]
sample = open(r"N:\COVerAGE-DB\Automation\Afghanistan\ "+timestr+"-Sample-test.txt","w")
sample.write("Samples Tested "+span.text)
sample.close()



userid_element = driver.find_elements_by_xpath('//*[@class="table table-hover table-bordered"]')


table = userid_element[0].text
text = table.replace(" ",",").replace("\n",",").replace("٪","%")
myfile = open(r"N:\COVerAGE-DB\Automation\Afghanistan\ "+timestr+"-Death.txt", "w")
myfile.write(text)
myfile.close()


driver.quit()
