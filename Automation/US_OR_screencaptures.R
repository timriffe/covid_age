

library(webshot)



deaths_url <- "https://public.tableau.com/profile/oregon.health.authority.covid.19#!/vizhome/OregonCOVID-19CaseDemographicsandDiseaseSeverityStatewide-SummaryTable/DemographicDataSummaryTable"

cases_url <- "https://public.tableau.com/profile/oregon.health.authority.covid.19#!/vizhome/OregonCOVID-19CaseDemographicsandDiseaseSeverityStatewide/DemographicData?:display_count=y&:toolbar=n&:origin=viz_share_link&:showShareOptions=false"


deaths_png <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Oregon/US_OR_deaths",today(),".png")
cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Oregon/US_OR_cases",today(),".png")

webshot(url = deaths_url,
        file = deaths_png,
        vwidth = 500,
        vheight = 1500, 
        delay = 10)


webshot(url = cases_url,
        file = cases_png,
        vwidth = 500,
        vheight = 1500, 
        delay = 10)



library(googledrive)
"#ember356"


webshot(url = "https://experience.arcgis.com/experience/85f43bd849e743cb957993a545d17170",
        file = "VTtest.png",
        vwidth = 500,
        vheight=1000,
        delay = 10,
        selector = "#ember356")
webshot("https://experience.arcgis.com/experience/85f43bd849e743cb957993a545d17170", "VTtest.png",
        selector = c("#search"),
        eval = "casper.waitForSelector('#ember356'), function () {
    casper.click(x('#ember356'));
    this.wait(5000);
  });",
        delay=3
)
