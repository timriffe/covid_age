# -*- coding: utf-8 -*-
"""
Created on Thu Feb  3 10:24:06 2022

@author: Hassan
"""

from bs4 import BeautifulSoup as soup
import json
import requests
import numpy as np
import pandas as pd
import time


#Togo source website
# src = "https://e.infogram.com/4ae3da94-ca72-4258-a4d0-cccfe9c570fc?parent_url=https%3A%2F%2Fcovid19.gouv.tg%2Fgraph-evolution%2F&src=embed#async_embed"

timestr = time.strftime("%Y%m%d")

confirmed_cases_graph = "https://atlas.jifo.co/api/connectors/5873dc9c-6ce2-4100-abc7-7e5ece48c53b"
c = requests.get(confirmed_cases_graph)
soup_cases = soup(c.content, 'html.parser')
json_cases = json.loads(soup_cases.text)
dataset = []
json_cases['data'][0][0][0] = "Age group"
headings = json_cases['data'][0][0]
for i in json_cases['data'][0][1:]:
    row = tuple(i)
    dataset.append(row)
numpy_data = np.array(dataset)
result = pd.DataFrame.from_records(numpy_data, columns = headings)    
result.to_excel(r"N:\COVerAGE-DB\Automation\Togo\Distribution of confirmed cases"+timestr+".xlsx",encoding="utf-8-sig", index = False)


death_graph = "https://atlas.jifo.co/api/connectors/4632ab31-c265-4627-bb56-a0a890e1794d"
d = requests.get(death_graph)
soup_deathes = soup(d.content, 'html.parser')
json_deathes = json.loads(soup_deathes.text)
dataset = []
json_deathes['data'][0][0][0] = "Age group"
headings = json_deathes['data'][0][0]

for i in json_deathes['data'][0][1:]:
    row = tuple(i)
    dataset.append(row)
numpy_data = np.array(dataset)
result = pd.DataFrame.from_records(numpy_data, columns = headings)    
result.to_excel(r"N:\COVerAGE-DB\Automation\Togo\Distribution of deathes"+timestr+".xlsx",encoding="utf-8-sig", index = False)
