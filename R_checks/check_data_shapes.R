library(osfr)
library(tidyverse)
require(lubridate)
require(covidAgeData)
require(here)

# data_source <- "input-data/COVerAGE-DB/Output_5.zip"
# link_old <- "https://osf.io/7tnfh/download?version=135&displayName=Output_5-2021-01-13T07%3A22%3A39.845954%2B00%3A00.zip"
# osf_retrieve_file("7tnfh") %>%
#   osf_download(path = "input-data/COVerAGE-DB/", conflicts = "overwrite")

dat <-  read_csv("Data/Output_5.zip",
                    skip = 3)

# dat <-
#   read_subset_covid(
#   filename,
#   data = "Output_5",
#   return = "tibble",
#   Region = "All",
#   Sex = "b")

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases)) %>% 
  ungroup() %>% 
  drop_na(Deaths) %>% 
  arrange(Country, Date) %>% 
  group_by(Country) %>% 
  mutate(newD = Deaths - lag(Deaths)) %>% 
  ungroup()

dat2 %>% 
  filter(!Country %in% c("Brazil", "USA")) %>% 
  ggplot()+
  geom_line(aes(Date, Deaths, col = Country))

dat2 %>% 
  filter(Country %in% c("Netherlands")) %>% 
  ggplot()+
  geom_line(aes(Date, Deaths, col = Country))


dat2 %>% 
  filter(Country == "USA") %>% 
  ggplot()+
  geom_line(aes(Date, Deaths, col = Country))

cts <- dat2 %>%
  drop_na(Deaths) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)

for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Deaths), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("quality_checks/deaths_210410_gr", i, ".png")) 
}


dat2 %>% 
  filter(!Country %in% c("Brazil", "USA")) %>% 
  ggplot()+
  geom_line(aes(Date, Deaths, col = Country))

dat3 <- 
  dat2 %>% 
  drop_na(Deaths)

