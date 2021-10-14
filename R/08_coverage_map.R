# TODO: maybe switch to Natural Earth map source,
# https://cran.r-project.org/web/packages/rnaturalearth/vignettes/what-is-a-country.html
library(here)
source(here::here("R","00_Functions.R"))

logfile <- here("buildlog.md")

log_section("remake coverage map", append = TRUE, logfile = logfile)

library(googlesheets4)
library(tidyverse)
library(cartography)
library(rgdal)
library(tmap)
library(sf)
data(World)


Sys.sleep(120)
# DB objects
gs4_auth(email = Sys.getenv("email"))
Sys.sleep(120)

# several tries, just because.
db_pops  <- try(get_input_rubric("input"))
if (class(db_pops)[1] == "try-error"){
  Sys.sleep(120)
  db_pops  <- try(get_input_rubric("input"))
}
if (class(db_pops)[1] == "try-error"){
  Sys.sleep(120)
  db_pops  <- try(get_input_rubric("input"))
}
if (class(db_pops)[1] == "try-error"){
  Sys.sleep(120)
  db_pops  <- get_input_rubric("input")
}



db_input <- readRDS(here("Data","inputDB.rds"))
db_input <- db_input %>% 
  mutate(Country = ifelse(Country == "US","USA",Country))


# checking coordinate system
st_crs(World)

World$name <- as.character(World$name)

World$name[World$name == "Swaziland"]       <- "Eswatini"
# World$name[World$name == "United Kingdom"]  <- "UK"
World$name[World$name == "United States"]   <- "USA" 
World$name[World$name == "Korea"] <- "South Korea"
World$name[World$name == "Dominican Rep."]  <- "Dominican Republic"
World$name[World$name == "Czech Rep." ]     <- "Czechia"
World$name[World$name == "Central African Rep." ]     <- "Central African Republic"
World$name[World$name == "Eq. Guinea" ]     <- "Equatorial Guinea"
World$name[World$name == "S. Sudan" ]     <- "South Sudan"

# remove Antarctica
World <- World[!World$name == "Antarctica",]

# add Robinson projection
world_rob<-st_transform(World, "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
world_rob %>% ggplot() + geom_sf()


# all(db_pops$Country %in% World$name)
# dbc <- db_pops$Country %>% unique()
# dbc[!dbc%in%World$name]

have_in_idb <- 
  db_input %>% 
  select(Country, Region) %>% 
  distinct() %>% 
  group_by(Country) %>% 
  mutate(coverage = ifelse(n()>1,"National and subnational","National"),
         indb = TRUE) %>% 
  ungroup() %>% 
  select(Country, coverage) %>% 
  distinct()

ctries <- have_in_idb %>% dplyr::pull(Country)

forthcoming <-
  db_pops %>% 
  filter(! Country %in% ctries) %>% 
  mutate(coverage = "Forthcoming") %>% 
  select(Country, coverage)

db_coverage <-
  bind_rows(have_in_idb,
            forthcoming) %>% 
  # we do this because UK envelops them in map.
  filter(!Country %in% c("Northern Ireland", "Scotland","England","Wales","England and Wales")) %>% 
  mutate(coverage = ifelse(Country == "United Kingdom","National and subnational",coverage)) %>% 
  filter(Country != "Russia")

db_coverage$Country[!db_coverage$Country %in% world_rob$name]

map_joined <- left_join(world_rob, db_coverage, 
                        by = c('name' = 'Country')) 


map_joined$coverage[is.na(map_joined$coverage)] <- "Not included yet"


cols_data <- c("National and subnational" = "grey10", "National" = "#9477bf", "Forthcoming" = "#e9afdd","Not included yet" = "grey90")

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

map_out <-
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
  theme(legend.text=element_text(size = tx + 5),
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
ggsave(here("assets","coveragemap.svg"), map_out, width = 30, height = 20, units = "cm")
ggsave(here("assets","coveragemap.png"), map_out, width = 30, height = 20, units = "cm", dpi=300)

rm(list=setdiff(ls(), c("logfile","creds")))
