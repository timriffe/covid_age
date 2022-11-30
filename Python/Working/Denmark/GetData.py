# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 01:55:23 2022

@author: Hassan
"""

from bs4 import BeautifulSoup as bs4
import re
import pandas as pd
import time
import os 


timestr = time.strftime("%Y%m%d")


src = r"N:\COVerAGE-DB\Automation\Denmark"

for files in os.listdir(src):
    
    if files.endswith(".html"):
        x = os.path.join(src,files)
        
        date_ext = files.split("_")[1]
        date_output = date_ext.split(".")[0]
        # print("This file will be converted " + date_output )
        with open(x, encoding="utf8") as fp:
            soup = bs4(fp, "html.parser")
        try:    
            divs = soup.find_all("div", {"class": "amcharts-chart-div"})
        except:
            # print("An error occured "+date_output)
            continue
        head_of_graph = divs[3].svg.find('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
        the_gs = head_of_graph.find_all('g', class_= re.compile("amcharts-graph-column amcharts-graph-graphAuto0"))
        
        info = {"age_group": [] , "deaths": []}
        for g in the_gs:
            split_element = g['aria-label'].split()
            info['age_group'].append(split_element[0])
            info['deaths'].append(split_element[1])
        
        
        info_df = pd.DataFrame.from_dict(info) 
        info_df.to_excel("Denmark_deaths"+date_output+".xlsx",encoding="utf-8-sig", index=False)
        os.remove(x)
        
