# -*- coding: utf-8 -*-
"""
Created on Mon Feb 14 11:05:26 2022

@author: Hassan
"""

from bs4 import BeautifulSoup as soup
import pandas as pd
import time
import requests
import numpy as np

timestr = time.strftime("%Y%m%d")
src = "https://www.ccss.sa.cr/web/coronavirus/vacunacion"

c = requests.get(src)
content = soup(c.content, 'html.parser')

section = content.find(lambda tag: tag.name == "section" and tag.get('class') == ["py-24"])
table = section.find("table", attrs={"id": "content-table3"})
headings = [th.get_text().strip() for th in table.find("thead").find("tr").find_all("th")]
dataset = []
rows_of_a_table = table.find("tbody").find_all("tr")

for row in rows_of_a_table:
    details = tuple([td.p.get_text().strip() if td.find('p') else td.get_text().encode('ascii', 'ignore').strip() for td in row.find_all("td")])
    dataset.append(details)
    
total = [th.get_text().strip() for th in table.find("tfoot").find("tr").find_all("th")]
dataset.append(total)
numpy_data = np.array(dataset)
result = pd.DataFrame.from_records(numpy_data, columns = headings)     
result.to_excel(r"N:\COVerAGE-DB\Automation\Costa Rica\vaccinations"+timestr+".xlsx",encoding="utf-8-sig", index=False)