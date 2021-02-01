library(osfr)
library(tidyverse)
library(lubridate)
library(wpp2019)
library(countrycode)
# Attach up-to-date case totals.
# devtools::install_github("RamiKrispin/coronavirus")
# library(coronavirus)

osf_retrieve_file("7tnfh") %>%
  osf_download(conflicts = "overwrite",
               path = "Data") 

# This reads it in
O5 <-  read_csv("Data/Output_5.zip",
                       skip = 3,
                       col_types = "cccciicddd") %>% 
  mutate(Date = dmy(Date))



NationalCases <-
  O5 %>% 
  filter(Region == 'All',
         !is.na(Cases),
         Sex == "b") %>% 
  group_by(Country) %>% 
  mutate(keep = Date == max(Date)) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(Country, Date, Age, Cases)


data(popF)
data(popM)

popF <-
  popF %>% 
  mutate(Sex = "f")
popM <-
  popM %>% 
  mutate(Sex = "m")


# combine to both-sex
pop <- bind_rows(popF, popM) %>% 
  select(Country = name, Age = age, Pop = `2020`) %>% 
  group_by(Country, Age) %>% 
  summarize(Pop = sum(Pop) * 1000, .groups = "drop") %>% 
  mutate(Country = case_when(
    Country == "Bolivia (Plurinational State of)" ~ "Bolivia",
    Country == "Venezuela (Bolivarian Republic of)" ~ "Venezuela",
    Country == "United States of America"~ "USA",
    Country == "Republic of Moldova" ~ "Moldova",
    Country == "Republic of Korea" ~ "South Korea",
    Country == "China, Taiwan Province of China" ~ "Taiwan",
    Country == "Viet Nam" ~ "Vietnam",
    Country == "Timor-Leste" ~ "Timor",
    Country == "Syrian Arab Republic" ~ "Syria",
    Country == "St. Vincent and the Grenadines" ~ "Saint Vincent and the Grenadines",
    Country == "Iran (Islamic Republic of)" ~ "Iran",
    Country == "Brunei Darussalam" ~ "Brunei",
    Country == "Lao People's Dem. Republic" ~ "Laos",
    Country == "Russian Federation" ~ "Russia",
    Country == "Cabo Verde" ~ "Cape Verde",
    Country == "United Republic of Tanzania" ~ "Tanzania",
    Country == "State of Palestine" ~ "Palestine",
    Country == "Dem. Republic of the Congo" ~"Democratic Republic of Congo",
    TRUE ~ Country
  ),
  Age = recode(Age,
               "0-4" = "0",
               "5-9" = "5",
               "10-14" = "10",
               "15-19" = "15",
               "20-24" = "20",
               "25-29" = "25",
               "30-34" = "30",
               "35-39" = "35",
               "40-44" = "40",
               "45-49" = "45",
               "50-54" = "50",
               "55-59" = "55",
               "60-64" = "60",
               "65-69" = "65",
               "70-74" = "70",
               "75-79" = "75",
               "80-84" = "80",
               "85-89" = "85",
               "90-94" = "90",
               "95-99" = "95",
               "100+" = "100"),
  Age = as.integer(Age)) %>% 
  arrange(Country, Age)

wpp_ctries <- pop$Country %>% unique()
cdb_ctries <- NationalCases$Country %>% unique()

cdb_ctries[!cdb_ctries %in% wpp_ctries]

# "Northern Ireland", "Palestine", "Scotland"         
        
OWID <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv",col_types =
"cccDdddddddddddddddddddddddddddddcddddddddddddddddddddd")  %>% 
  select(iso_code, 
         continent, 
         location, 
         date, 
         total_cases)

CaseTotals <- 
  OWID %>% 
  filter(!is.na(total_cases)) %>% 
  group_by(location) %>% 
  mutate(keep = date == max(date)) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(-keep) %>% 
  mutate(location = ifelse(location == "United States","USA",location)) %>% 
  select(continent, Country = location, total_cases)

ctries_pop <- pop$Country %>% unique()
ctries_owid <- CaseTotals$Country %>% unique()

ctries_owid[!ctries_owid %in% ctries_pop]


# join together, rescale age distributions.
Prev <-
  pop %>% 
  left_join(NationalCases, by = c("Country","Age")) %>% 
  full_join(CaseTotals, by = "Country") %>% 
  group_by(Country) %>% 
  mutate(CasesResc = Cases / sum(Cases) * total_cases,
         CasePrev = CasesResc / Pop * 1e6) 

# Continent mean prev
ContinentMeans <- 
  Prev %>% 
  filter(!is.na(continent)) %>% 
  group_by(continent,Age) %>% 
  summarize(CasePrev = mean(CasePrev, na.rm = TRUE),
            .groups = "drop") 

# Hmmmm.
ContinentMeans %>% 
  ggplot(aes(x = Age,
             y = CasePrev, color = continent, group = continent)) + 
  geom_line() + 
  xlim(0,70) + 
  ylim(0,7e4)

# Continent weighted mean prev
ContinentWeightedMeans <- 
  Prev %>% 
  filter(!is.na(continent)) %>% 
  group_by(continent,Age) %>% 
  summarize(CaseTOT = sum(Cases, na.rm = TRUE),
            PopTOT = sum(Pop, na.rm = TRUE),
            CasePrev = CaseTOT / PopTOT * 1e6,
            .groups = "drop") 

# Indeed, changes rankings within age. This one better.
ContinentWeightedMeans %>% 
  ggplot(aes(x = Age,
             y = CasePrev, color = continent, group = continent)) + 
  geom_line() + 
  xlim(0,70) + 
  ylim(0,7e4)

# Again as dist, for 'shape' comparability:
ContinentWeightedMeans %>% 
  group_by(continent) %>% 
  mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100) %>% 
  ungroup() %>% 
  ggplot(aes(x = Age,
             y = CaseDist, color = continent, group = continent)) + 
  geom_line() + 
  xlim(0,70) + 
  ylim(0,10)

# Conclusion overall prevalence is highest in reproductive ages:
# sociality + family nuclei- linked transmission between generations?
# Really any conclusions re transmission pathways from a cross-sectional
# line like this is pure speculation. Before moving on to ridgeplots,
# let's look at the global heterogeneity in this.

