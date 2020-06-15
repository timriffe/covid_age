# TODO: maybe switch to Natural Earth map source,
# French Guiana presently included w France, but French
# data don't include French Guiana. Need to use
# https://cran.r-project.org/web/packages/rnaturalearth/vignettes/what-is-a-country.html
source("R/00_Functions.R")
library(googlesheets4)
library(tidyverse)
library(cartography)
library(rgdal)
library(tmap)
library(sf)
data(World)

# DB objects
db_pops  <- get_input_rubric("input")
db_input <- readRDS("Data/inputDB.rds")
db_input <- db_input %>% 
  mutate(Country = ifelse(Country == "US","USA",Country))


# checking coordinate system
st_crs(World)

World$name <- as.character(World$name)

World$name[World$name == "Swaziland"]       <- "Eswatini"
World$name[World$name == "United Kingdom"]  <- "UK"
World$name[World$name == "United States"]   <- "USA" 
World$name[World$name == "Korea"] <- "South Korea"
World$name[World$name == "Dominican Rep."]  <- "Dominican Republic"
World$name[World$name == "Czech Rep." ]     <- "Czechia"

# remove Antarctica
World <- World[!World$name == "Antarctica",]

#changing to Robinson system; Tim´s request, hope this is what he expected
world_rob<-st_transform(World, "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
world_rob %>% ggplot() + geom_sf()

# 
# db_10 <- read_csv("https://github.com/timriffe/covid_age/raw/master/Data/Output_10.csv",
#                   skip = 1) 

#setwd("C:/Users/kikep/Dropbox/covid_age/vw/")

have_in_idb <- 
  db_input %>% 
  select(Country, Region) %>% 
  distinct() %>% 
  group_by(Country) %>% 
  mutate(coverage = ifelse(n()>1,"National and regional","National"),
         indb = TRUE) %>% 
  ungroup() %>% 
  select(Country, coverage) %>% 
  distinct()

ctries <- have_in_idb %>% pull(Country)

forthcoming <-
  db_pops %>% 
  filter(! Country %in% ctries) %>% 
  mutate(coverage = "Forthcoming") %>% 
  select(Country, coverage)

db_coverage <-
  bind_rows(have_in_idb,
            forthcoming) %>% 
  # we do this because UK envelops them in map.
  filter(!Country %in% c("Northern Ireland", "Scotland","England","Wales")) %>% 
  mutate(coverage = ifelse(Country == "UK","National and regional",coverage)) %>% 
  filter(Country != "Russia")

db_coverage$Country[!db_coverage$Country %in% world_rob$name]

map_joined <- left_join(world_rob, db_coverage, 
                        by = c('name' = 'Country')) 


map_joined$coverage[is.na(map_joined$coverage)] <- "Not included yet"


cols_data <- c("National and regional" = "grey10", "National" = "grey30", "Forthcoming" = "#A3d3d3","Not included yet" = "grey90")

map_joined<-
  map_joined %>% 
  mutate(coverage = factor(coverage, levels = names(cols_data)))

#map_joined$coverage
# df <- data.frame(x = c("red", "black"))
# 
# ggplot(df, aes(x, 1, fill = x)) + 
#   geom_col() +
#   scale_fill_manual(breaks = c("red", "black"), values = c("red", "black"))



tx        <- 7
map_joined %>% 
  ggplot() + 
  geom_sf(aes(fill = coverage), col = "white", size = 0.2) +
  scale_x_continuous(expand=c(0.03,0.03)) +
  scale_y_continuous(expand=c(0.03,0.03)) +
  scale_fill_manual(values = cols_data,
                    #breaks = cols_data, 
                    labels = names(cols_data),
                    name = "Information\nCOVID-19") +
  guides(fill = guide_legend(title.position = "bottom",
                           keywidth = .5,
                           keyheight = .4))+
  theme(legend.text=element_text(size = tx + 3),
        legend.key.size = unit(1, "cm"),
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
