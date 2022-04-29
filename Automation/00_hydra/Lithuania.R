library(tidyverse)

# main source: https://open-data-ls-osp-sdg.hub.arcgis.com/search?collection=Dataset&q=covid

test <- read_csv("https://opendata.arcgis.com/api/v3/datasets/ba35de03e111430f88a86f7d1f351de6_0/downloads/data?format=csv&spatialRefId=4326")
