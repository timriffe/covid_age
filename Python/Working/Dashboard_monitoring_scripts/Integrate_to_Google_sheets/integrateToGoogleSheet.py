# -*- coding: utf-8 -*-
"""
Created on Mon Jan  9 15:22:08 2023

@author: Krishnan
"""

import os
import pandas as pd
import time
import openpyxl
from openpyxl import load_workbook
import xlwt
import xlrd
from xlutils.copy import copy
import httplib2
from apiclient import discovery
from google.oauth2 import service_account
import xlwings as xw

scopes = [
          #"https://www.googleapis.com/auth/drive", 
          #"https://www.googleapis.com/auth/drive.file", 
          "https://www.googleapis.com/auth/spreadsheets"
 
          ]

secret_file = os.path.join(os.getcwd(), 'C:/Users/Krishnan/Desktop/pythondashboard-374211-e10f877e1d38.json') #Key to service account

credentials = service_account.Credentials.from_service_account_file(secret_file, scopes=scopes)
sheets_service = discovery.build('sheets', 'v4', credentials=credentials)
#drive_service = discovery.build('drive', 'v3', credentials=credentials)

spreadsheet = {
    'properties': {
        'title': "Python_Dashboard"
    }
}

#Open the excel dashboard and create a list from the data that has to be copied
wb = xw.Book('N:/COVerAGE-DB/Automation/Python-Dashboard/PythonDashboard.xlsx')
app = xw.apps.active
sht = xw.Sheet('dash-view')
py_list = sht.range('E3:N7').value
print(py_list)
#wb.close()
app.quit()

#Pasting the copied list in ggogle sheet i.e. updating the sheet
range_name = "Python_automation!E3:N8"

data = { 'values' : py_list }

update_response = sheets_service.spreadsheets().values().update(
    #spreadsheetId='1T6w5pIRk2q-imBfetddFbOUq0DuXEISFX_P10gpDMUg', #file created by service account
    #spreadsheetId='1xHh6sLAuqMHY-GfywPoTJtW8ZvjLSJOkvtw2IcRWiKY', #file created by user account
    spreadsheetId='1ftqFwX_Z29OrXxH9HnQWo31ApoEpxSqYOJspnIUAUbk', #ID of the main Hydra sheet
    body=data, 
    range=range_name, 
    valueInputOption='USER_ENTERED').execute()

range_name = "Python_automation!E3:N7"  

response = sheets_service.spreadsheets().values().get(
  #spreadsheetId='1T6w5pIRk2q-imBfetddFbOUq0DuXEISFX_P10gpDMUg',#file created by service account
  #spreadsheetId='1xHh6sLAuqMHY-GfywPoTJtW8ZvjLSJOkvtw2IcRWiKY',#file created by user account
  spreadsheetId='1ftqFwX_Z29OrXxH9HnQWo31ApoEpxSqYOJspnIUAUbk', #ID of the main Hydra sheet
  range=range_name
).execute()

response['values']

#PERMISSIONS UPDATE

#new_file_permission = {
    #'type': 'group',
    #'role': 'writer',
    #'emailAddress':'aishwarya.muralikrishnan@gmail.com'
#}

#permission_response = drive_service.permissions().create(
  #fileId='1T6w5pIRk2q-imBfetddFbOUq0DuXEISFX_P10gpDMUg', body=new_file_permission).execute()
wb.close