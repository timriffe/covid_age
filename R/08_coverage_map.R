# TODO: maybe switch to Natural Earth map source,
# French Guiana presently included w France, but French
# data don't include French Guiana. Need to use
# https://cran.r-project.org/web/packages/rnaturalearth/vignettes/what-is-a-country.html

library(googlesheets4)
library(tidyverse)
library(cartography)
library(rgdal)
library(tmap)
library(sf)
data(World)

# checking coordinate system
st_crs(World)

World$name <- as.character(World$name)

World$name[World$name == "Swaziland"]       <- "Eswatini"
World$name[World$name == "United Kingdom"]  <- "UK"
World$name[World$name == "United States"]   <- "USA" 
World$name[World$name == "Dem. Rep. Korea"] <- "South Korea"
World$name[World$name == "Dominican Rep."]  <- "Dominican Republic"
World$name[World$name == "Czech Rep." ]     <- "Czechia"

# remove Antarctica
World <- World[!World$name == "Antarctica",]

#changing to Robinson system; Tim´s request, hope this is what he expected
world_rob<-st_transform(World, "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
world_rob %>% ggplot() + geom_sf()



db_pops <- read_sheet("https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0",
                      sheet = "input") %>% 
  drop_na(Country)

db_input <- readRDS("Data/inputDB.rds")
# 
# db_10 <- read_csv("https://github.com/timriffe/covid_age/raw/master/Data/Output_10.csv",
#                   skip = 1) 

#setwd("C:/Users/kikep/Dropbox/covid_age/vw/")

db_pops2 <- db_pops %>% 
  select(Country, Region) %>% 
  bind_rows(db_input %>% 
              filter(Country %in% c("Germany", "Colombia", "Japan"),
                     Region != "All") %>% 
              select(Country, Region)) %>% 
  mutate(incl = 1) %>% 
  distinct()

db_pops2 <- db_pops2 %>% 
  filter(!Country %in% c("Northern Ireland", "Scotland","England","Wales"))
##############################
### Map plots ################
##############################

db_pops3 <- db_pops2 %>% 
  mutate(status = "Included")

db_alls <- db_pops3 %>% 
  filter(Region == "All" & status == "Included") %>% 
  select(Country) %>% 
  distinct() %>% 
  mutate(all = 1)

db_regs <- db_pops3 %>% 
  filter(Region != "All") %>% 
  select(Country) %>%  
  distinct() %>% 
  mutate(regional = 1)

db_pops4 <- db_pops3 %>% 
  left_join(db_alls) %>% 
  left_join(db_regs) %>% 
  mutate(coverage = case_when(all == 1 & regional == 1 ~ "National and regional",
                              all == 1 & is.na(regional) ~ "National"))

db_ctrs <- db_pops4 %>% 
  filter(Region == "All") %>% 
  select(Country, status, coverage) %>% 
  mutate(coverage = ifelse(Country == "UK", "National and regional",coverage))

map_joined <- left_join(world_rob, db_ctrs, 
                        by = c('name' = 'Country')) 

map_joined$coverage[is.na(map_joined$coverage)] <- "Not included"

cols_data <- c("National and regional" = "black", "National" = "grey40", "Not included" = "grey90")
tx        <- 7
map_joined %>% 
  ggplot() + 
  geom_sf(aes(fill = coverage), col = "white", size = 0.2) +
  scale_x_continuous(expand=c(0.03,0.03)) +
  scale_y_continuous(expand=c(0.03,0.03)) +
  scale_fill_manual(values = cols_data, 
                    labels = c( "National", "National and regional", "Not included"),
                    name = "Information\nCOVID-19") +
  guides(fill = guide_legend(title.position = "bottom",
                           keywidth = .5,
                           keyheight = .2))+
  theme(legend.text=element_text(size = tx - 1),
        legend.key.size = unit(.5, "cm"),
        legend.title = element_blank(),
        # legend.position = c(0.1,.3),
        # legend.direction = "vertical",
        legend.position = "bottom",
        legend.direction = "horizontal",
        plot.margin=unit(c(0,0,0,0),"cm"),
        legend.spacing = unit(c(0,0,0,0),"cm"),
        legend.margin = margin(0, 0, 0, 0),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        #panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())
# proposal
ggsave("assets/coveragemap.svg")
