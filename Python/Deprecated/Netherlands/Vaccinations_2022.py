# -*- coding: utf-8 -*-
"""
Created on Mon Jan 17 11:46:39 2022

@author: Hassan
"""

import urllib
from bs4 import BeautifulSoup as soup
import time
import pandas as pd
import numpy as np
import warnings

warnings.filterwarnings("ignore")
timestr = time.strftime("%Y%m%d")
with urllib.request.urlopen('https://www.rivm.nl/en/covid-19-vaccination/figures-vaccination-programme') as response:
    soup = soup(response, 'html.parser')

table = soup.find("table", attrs={"class":"table table-striped-brand-lightest"})
sibiling = table.previous_sibling.previous_sibling.get_text()
dataset = []
headings = [th.get_text() for th in table.find("thead").find("tr").find_all("th")]
rows_of_a_table = table.find("tbody").find_all("tr")
for row in rows_of_a_table:
    details = tuple([td.get_text() for td in row.find_all("td")])
    dataset.append(details)
numpy_data = np.array(dataset)
result = pd.DataFrame.from_records(numpy_data, columns = headings) 
result.to_excel(r"N:\COVerAGE-DB\Automation\Netherlands\vaccinations"+timestr+".xlsx",encoding="utf-8-sig", index=False)
   