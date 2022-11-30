# -*- coding: utf-8 -*-
"""
Created on Thu Nov  5 17:27:29 2020

@author: waqar
"""



#file 1

import time
import requests,bs4
import re
#pattern =r"Risk groups most affected(*)"
rejex = re.compile(r'"data":(.*)"')
#pattern = r'"data":(.*)"'

pattern1 = r'"data":(.*)"container"'
#regex = re.compile(pattern)


Link="https://covid19-surveillance-report.ecdc.europa.eu/?fbclid=IwAR1Dx2cGvJ4eYwY8nMtc02ANWEpfGt8IP_25VrSxhgF6D1zJF2gf09HGCEY#data"
res = requests.get(Link)
#print(res)
#time.sleep(20)
soup = bs4.BeautifulSoup(res.text,"html.parser")
week = soup.select('h1.title')[0].text.strip()
soup = str(soup)

data = re.findall(pattern1,soup)
print(data[2])
final_data = data[2]
#file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\age-sex-pyramids-Week-46-new.txt","w")
#timestr = time.strftime("%Y%m%d")
#file1 = open(timestr + "-age-sex-pyramids-new.txt","w")
print(f"week name: {week}")
file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\ " + week + "-age-sex-pyramids.txt","w")

file1.write(str(final_data))
file1.close()


#file 2


import requests,bs4
import re
#pattern =r"Risk groups most affected(*)"
rejex = re.compile(r'"data":(.*)"')
#pattern = r'"data":(.*)"'

pattern1 = r'"data":(.*)"container"'
#regex = re.compile(pattern)


Link="https://covid19-surveillance-report.ecdc.europa.eu/?fbclid=IwAR1Dx2cGvJ4eYwY8nMtc02ANWEpfGt8IP_25VrSxhgF6D1zJF2gf09HGCEY#data"
res = requests.get(Link)
#print(res)
soup = bs4.BeautifulSoup(res.text,"html.parser")
week = soup.select('h1.title')[0].text.strip()
soup = str(soup)
data = re.findall(pattern1,soup)
print(data[3])
final_data = data[3]
#file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\age-specific-rates-Week-46-new.txt","w")


#file1 = open(timestr + "-age-specific-rates-new.txt","w")

file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\ " + week + "-age-specific-rates.txt","w")

#file1 = open(r"F:\rostock-master\ " + company + "ali.txt","w")

file1.write(str(final_data))
file1.close()


#File 3

"""
import requests,bs4
import re
#pattern =r"Risk groups most affected(*)"
rejex = re.compile(r'"data":(.*)"')
#pattern = r'"data":(.*)"'

pattern1 = r'"data":(.*)"container"'
#regex = re.compile(pattern)


Link="https://covid19-surveillance-report.ecdc.europa.eu/?fbclid=IwAR1Dx2cGvJ4eYwY8nMtc02ANWEpfGt8IP_25VrSxhgF6D1zJF2gf09HGCEY#data"
res = requests.get(Link)
#print(res)
soup = bs4.BeautifulSoup(res.text,"html.parser")
soup = str(soup)
data = re.findall(pattern1,soup)
print(data[4])
final_data = data[4]
file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\2.4.9-data-Week-45.txt","w")
file1.write(str(final_data))
file1.close()

#file 4

import requests,bs4
import re
#pattern =r"Risk groups most affected(*)"
rejex = re.compile(r'"data":(.*)"')
#pattern = r'"data":(.*)"'

pattern1 = r'"data":(.*)"container"'
#regex = re.compile(pattern)


Link="https://covid19-surveillance-report.ecdc.europa.eu/?fbclid=IwAR1Dx2cGvJ4eYwY8nMtc02ANWEpfGt8IP_25VrSxhgF6D1zJF2gf09HGCEY#data"
res = requests.get(Link)
#print(res)
soup = bs4.BeautifulSoup(res.text,"html.parser")
soup = str(soup)
data = re.findall(pattern1,soup)
print(data[7])
final_data = data[7]
file1 = open(r"N:\COVerAGE-DB\Automation\ECDC\4.1.4-data-Week-45.txt","w")
file1.write(str(final_data))
file1.close()

"""
