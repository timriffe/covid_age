from selenium import webdriver
from time import sleep

driver = webdriver.Chrome()
driver.get('https://tableau.azdhs.gov/views/COVID19Demographics/EpiData?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Ftableau.azdhs.gov%2F&:embed_code_version=3&:tabs=no&:toolbar=no&:showAppBanner=false&:display_spinner=no&iframeSizedToWindow=true&:loadOrderID=0')
sleep(5)

# driver.get_screenshot_as_file("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_AZ_demo.png")
driver.get_screenshot_as_file("US_AZ_demo.png")

driver.quit()
