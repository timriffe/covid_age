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
                       col_types = "ccccciiddd") %>% 
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
# No need to resolve redundant sources.

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


# join together, rescale age distributions, recode continents (use name `Region`)
Prev <-
  pop %>% 
  left_join(NationalCases, by = c("Country","Age")) %>% 
  full_join(CaseTotals, by = "Country") %>% 
  group_by(Country) %>% 
  mutate(CasesResc = Cases / sum(Cases) * total_cases,
         CasePrev = CasesResc / Pop * 1e6,
         Region = continent,
         Region = case_when(Region == "North America" & !Country %in% c("USA","Canada") ~ "LAC",
                            Region == "South America" ~ "LAC",
                            TRUE ~ Region))
# 

# # Continent mean prev
# ContinentMeans <- 
#   Prev %>% 
#   filter(!is.na(Region)) %>% 
#   group_by(Region,Age) %>% 
#   summarize(CasePrev = mean(CasePrev, na.rm = TRUE),
#             .groups = "drop") 

# Hmmmm.
# ContinentMeans %>% 
#   ggplot(aes(x = Age,
#              y = CasePrev, color = Region, group = Region)) + 
#   geom_line() + 
#   xlim(0,80)  +
#   ylim(0,7e4)

# Continent weighted mean prev
ContinentWeightedMeans <- 
  Prev %>% 
  filter(!is.na(Region)) %>% 
  group_by(Region,Age) %>% 
  summarize(CaseTOT = sum(Cases, na.rm = TRUE),
            PopTOT = sum(Pop, na.rm = TRUE),
            CasePrev = CaseTOT / PopTOT * 1e6,
            .groups = "drop") 

# Indeed, changes rankings within age. This one better.

###############################################
# First fig!!!!
library(ggrepel)
library(colorspace)
F1data <- 
ContinentWeightedMeans %>% 
  filter(Age <= 75) %>% 
  group_by(Region) %>% 
  mutate(isMax = CasePrev == max(CasePrev))

F1 <-
  F1data %>% 
  ggplot(aes(x = Age,
             y = CasePrev/1000, color = Region, group = Region)) + 
  geom_line(size = 1) + 
  xlim(0,75) +
  ylab("Cases / 1000") + 
  geom_text_repel( data = filter(F1data,isMax),
                   mapping = aes(label = Region),
                   nudge_x = 1,
                   nudge_y = 1,
                   na.rm = TRUE,
                   size=6) + 
  theme_minimal() +
  theme(legend.position = "none",
        axis.text=element_text(size=14),
        axis.title=element_text(size=16)) + 
  scale_colour_discrete_qualitative(palette = "Dark3")
F1

###############################################
# Fig 2 
F2data <- 
  ContinentWeightedMeans %>% 
  group_by(Region) %>% 
  filter(Age <= 75) %>% 
  mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100,
         labHere = FALSE,
         labHere = case_when(Region == "Europe" & Age == 10 ~ TRUE,
                             Region == "Asia" & Age == 35 ~ TRUE,
                             Region == "Oceania" & Age == 40 ~ TRUE,
                             Region == "LAC" & Age == 60 ~ TRUE,
                             Region == "North America" & Age == 10 ~ TRUE,
                             Region == "Africa" & Age == 55 ~ TRUE)) %>% 
  ungroup() 
# Again as dist, for 'shape' comparability:
F2 <- 
  F2data %>% 
  ggplot(aes(x = Age,
             y = CaseDist, color = Region, group = Region)) + 
  geom_line(size=1) +
  ylab("Case prevalence % < 80") +
  geom_text_repel( data = filter(F2data,labHere),
                   mapping = aes(label = Region),
                   nudge_x = 0,
                   nudge_y = 0,
                   na.rm = TRUE,
                   size=6) + 
  theme_minimal() +
  theme(legend.position = "none",
        axis.text=element_text(size=14),
        axis.title=element_text(size=16)) + 
  scale_colour_discrete_qualitative(palette = "Dark3")
F2

# Fig 3:

Sero <- read_csv("Data/SpainWave4Seroprev.csv") %>% 
  filter(Sex == "b",
         Age <= 75) %>% 
  mutate(CaseDist =  prev / sum(prev) * 100)


ES <- Prev %>% 
  filter(Country == "Spain",
         Age <= 75) %>% 
  mutate(CaseDist = CasePrev / sum(CasePrev) * 100)

F3 <-
  F2data %>% 
  ggplot(mapping = aes(x = Age,
             y = CaseDist)) + 
  geom_line(mapping = aes(x = Age,
                          y = CaseDist, group = Region),
            alpha = .5) +
  geom_line(mapping = aes(x = Age,
                y = CaseDist), 
            data = ES, 
            color = "red", 
            linetype = "dashed",
            size = 2) + 
  geom_line(mapping = aes(x = Age,
                y = CaseDist), 
            data = Sero, 
            color = "blue", 
            size = 2) + 
  ylab("Case prevalence % < 80") +
  annotate("text",x = 30,y=4.5,label="Spain, serosurvey\n(~2x prevalence)",col="blue",size=6) + 
  annotate("text",x = 13,y=9.5,label="Spain, detected cases",col="red",size=6) +
  theme_minimal() +
  theme(legend.position = "none",
        axis.text=element_text(size=14),
        axis.title=element_text(size=16)) +
  annotate("")


F1; ggsave(F1,filename = "Talks/GlobalDiscussionF1.png", width = 16, height = 9, units = "cm")
F2; ggsave(F2,filename = "Talks/GlobalDiscussionF2.png", width = 16, height = 9, units = "cm")
F3; ggsave(F3,filename = "Talks/GlobalDiscussionF3.png", width = 16, height = 9, units = "cm")
#################################
# 
# # Again as dist, for 'shape' comparability:
# ContinentWeightedMeans %>% 
#   group_by(continent) %>% 
#   filter(Age < 20) %>% 
#   mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100) %>% 
#   ungroup() %>% 
#   ggplot(aes(x = Age,
#              y = CaseDist, 
#              color = continent, 
#              group = continent)) + 
#   geom_line() + 
#   xlim(0,20) + 
#   ylim(0,60)
# 
# Continentu20 <-
# ContinentWeightedMeans %>% 
#   group_by(continent) %>% 
#   filter(Age < 20) %>% 
#   mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100)
# 
# Prev %>% 
#   filter(Age < 20) %>% 
#   group_by(Country) %>% 
#   mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100) %>% 
#   ungroup() %>% 
#   filter(!is.na(CaseDist)) %>% 
#   ggplot(aes(x = Age,
#              y = CaseDist)) + 
#   geom_line(aes(group = Country),color = "black",alpha = .1) + 
#   xlim(0,20) + 
#   geom_smooth() + 
#   geom_smooth(mapping = aes(x = Age,
#                                 y = CaseDist,
#                                 group = continent,
#                                 color = continent),
#                             data = Continentu20)
#   
# 
# Prev %>% 
#   filter(Age < 20) %>% 
#   group_by(Country) %>% 
#   mutate(CaseDist = CasePrev / sum(CasePrev, na.rm = TRUE) * 100) %>% 
#   ungroup() %>% 
#   filter(Age == 0, !is.na(CaseDist)) %>% 
#   filter(CaseDist == max(CaseDist))
# 
# 
# 
# # Conclusion overall prevalence is highest in reproductive ages:
# # sociality + family nuclei- linked transmission between generations?
# # Really any conclusions re transmission pathways from a cross-sectional
# # line like this is pure speculation. Before moving on to ridgeplots,
# # let's look at the global heterogeneity in this.
# 
# Sero <- read_csv("Data/SpainWave4Seroprev.csv") %>% 
#   filter(Sex == "b",
#          Age <= 75) %>% 
#   mutate(CaseDist =  prev / sum(prev) * 100)
# 
# 
# ES <- Prev %>% 
#   filter(Country == "Spain",
#          Age <= 75) %>% 
#   mutate(CaseDist = CasePrev / sum(CasePrev) * 100)
# 
# 
# 
# ggplot( aes(x = Age, y = prev)) + 
#   geom_ribbon(aes( ymin = low, ymax = high),alpha = .2) + 
#   geom_line(data = ES, mapping = aes(x = Age, y = CasePrev/10000),color = "red")
# 

