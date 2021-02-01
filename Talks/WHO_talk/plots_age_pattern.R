library(tidyverse)
library(lubridate)
library(zoo)
library(scales)

prof_20_2 <- read_rds("Talks/WHO_talk/age_profiles_country_region.rds")
levs <- c("Children", "Young", "Adults", "Elderly", "Several")
cols <- c("blue", "green", "grey50", "grey30", "black")
cols <- c("Children" = "blue", 
          "Young" = "green", 
          "Adults" = "grey50", 
          "Elderly" = "grey30", 
          "Several" = "black")

cols <- c("Young" = "#e63946", 
          "Other" = "#1d3557")


leaders <- prof_20_2 %>% 
  group_by(Country, Region, Wave) %>% 
  filter(Date <= min(Date)) %>%
  mutate(lds = n()) %>% 
  ungroup() %>% 
  mutate(leader = case_when(Age < 10 & lds == 1 ~ "Children",
                            Age > 10 & Age < 20 & lds == 1 ~ "Young",
                            Age > 20 & Age < 60 & lds == 1 ~ "Adults",
                            Age > 60 ~ "Elderly",
                            lds > 1 ~ "Several"),
         leader = ifelse(Region == "Brussels" & Wave == "first", "Young", leader),
         leader = ifelse(Country == "Japan" & Region == "All" & Wave == "first", "Elderly", leader),
         leader = ifelse(Country == "Slovenia", "Children", leader),
         leader2 = ifelse(leader %in% c("Children", "Young"), "Young", "Other")) %>% 
  select(Country, Region, Wave, leader, leader2) %>% 
  unique()

lvs2 <- c("Spain-first", "Spain-second", "Belgium-first", "Belgium-second", 
          "Czechia-unique", "Estonia-unique", "Slovenia-unique", 
          "Argentina-unique", "Paraguay-unique", "Colombia-unique", 
          "Mexico-unique", "Philippines-unique", "Japan-first", "Japan-second")


prof_20_3 <- prof_20_2 %>% 
  left_join(leaders) %>% 
  mutate(leader = factor(leader, levels = levs),
         Country2 = paste(Country, Wave, sep = "-"),
         Country2 = factor(Country2, levels = lvs2)) 



tx <- 10
ct1 <- c("Spain", "Belgium")
ct2 <- c("Czechia", "Estonia", "Slovenia")
asia <- c("Philippines", "Japan") 
lat <- c("Argentina", "Paraguay", "Colombia", "Mexico")

unique(prof_20_3$Country2)


prof_20_3 %>% 
  filter(Region == "All") %>% 
  ggplot()+
  geom_line(aes(Age, Date, col = leader2), size = 1, alpha = 0.7)+
  geom_point(aes(Age, Date, col = leader2), size = 1)+
  geom_vline(xintercept = 20, linetype = "dashed", size = 0.7)+
  geom_vline(xintercept = 10, linetype = "dashed", col = "grey20")+
  coord_flip()+
  scale_y_date(date_breaks = "4 days", date_labels = "%d%b")+
  scale_x_continuous(breaks = seq(0, 80, 10))+
  scale_color_manual(values = cols)+
  theme_bw()+
  theme(
    legend.position = "none",
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = tx),
    strip.text = element_text(size = tx)
  )+
  facet_wrap(~ Country2, scales = "free_x", dir = "h", ncol = 7)

ggsave("Talks/WHO_talk/fig6_age_profiles_all.png", width = 12, height = 7)


# 
# 
# 
# prof_20_3 %>% 
#   filter(Country %in% hic) %>% 
#   ggplot()+
#   geom_line(aes(Age, Date, col = leader), alpha = 0.4)+
#   geom_point(aes(Age, Date, col = leader), size = 1)+
#   geom_vline(xintercept = 20, linetype = "dashed", size = 0.7)+
#   geom_vline(xintercept = 10, linetype = "dashed", col = "grey20")+
#   coord_flip()+
#   scale_y_date(date_breaks = "4 days", date_labels = "%d%b")+
#   scale_x_continuous(breaks = seq(0, 80, 10))+
#   scale_color_manual(values = cols)+
#   theme_bw()+
#   theme(
#     plot.title = element_text(size = tx + 2),
#     axis.title.x = element_text(size = tx + 1),
#     axis.title.y = element_text(size = tx + 1),
#     axis.text.x = element_blank(),
#     axis.text.y = element_text(size = tx)
#   )+
#   facet_wrap(Place ~ Wave, scales = "free", ncol = 6)
# ggsave("Talks/WHO_talk/fig6_age_profiles_hic.png", width = 10)
# 
# prof_20_3 %>% 
#   filter(Country %in% lat) %>% 
#   ggplot()+
#   geom_line(aes(Age, Date, col = leader), alpha = 0.4)+
#   geom_point(aes(Age, Date, col = leader), size = 1)+
#   geom_vline(xintercept = 20, linetype = "dashed", size = 0.7)+
#   geom_vline(xintercept = 10, linetype = "dashed", col = "grey20")+
#   coord_flip()+
#   scale_y_date(date_breaks = "4 days", date_labels = "%d%b")+
#   scale_x_continuous(breaks = seq(0, 80, 10))+
#   scale_color_manual(values = cols)+
#   theme_bw()+
#   theme(
#     plot.title = element_text(size = tx + 2),
#     axis.title.x = element_text(size = tx + 1),
#     axis.title.y = element_text(size = tx + 1),
#     axis.text.x = element_blank(),
#     axis.text.y = element_text(size = tx)
#   )+
#   facet_wrap(Country ~ Region, scales = "free", ncol = 4)
# ggsave("Talks/WHO_talk/fig6_age_profiles_lat.png", width = 6)
# 
# prof_20_3 %>% 
#   filter(Country %in% asia) %>% 
#   ggplot()+
#   geom_line(aes(Age, Date, col = leader), alpha = 0.4)+
#   geom_point(aes(Age, Date, col = leader), size = 1)+
#   geom_vline(xintercept = 20, linetype = "dashed", size = 0.7)+
#   geom_vline(xintercept = 10, linetype = "dashed", col = "grey20")+
#   coord_flip()+
#   scale_y_date(date_breaks = "4 days", date_labels = "%d%b")+
#   scale_x_continuous(breaks = seq(0, 80, 10))+
#   scale_color_manual(values = cols)+
#   theme_bw()+
#   theme(
#     plot.title = element_text(size = tx + 2),
#     axis.title.x = element_text(size = tx + 1),
#     axis.title.y = element_text(size = tx + 1),
#     axis.text.x = element_blank(),
#     axis.text.y = element_text(size = tx)
#   )+
#   facet_wrap(Place ~ Wave, scales = "free", ncol = 3)
# ggsave("Talks/WHO_talk/fig6_age_profiles_asia.png", width = 4)
