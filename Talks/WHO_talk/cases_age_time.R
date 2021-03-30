library(osfr)
library(tidyverse)
library(lubridate)
library(zoo)
library(scales)


###########
# functions
###########

# db <- ctr_all
smooth_cases <- function(db, a, l = 0.00001){
  temp1 <- db %>% 
    filter(Age == a) %>% 
    mutate(days = 1:n())
  
  xs <- temp1$days
  ys <- log(temp1$n_cas + 1)
  
  md <- smooth.spline(x = xs, y = ys, lambda = l)
  
  temp2 <- temp1 %>% 
    mutate(n_cas_sm = exp(predict(md, xs)$y) - 1)
}

# smooth_tests <- function(db, a, l = 0.00001){
#   temp1 <- db %>% 
#     filter(Age == a) %>% 
#     mutate(days = 1:n())
#   
#   xs <- temp1$days
#   ys <- temp1$n_tes
#   
#   md <- smooth.spline(x = xs, y = ys, lambda = l)
#   
#   temp2 <- temp1 %>% 
#     mutate(n_tes_sm = predict(md, xs)$y)
# }

set_ctr <- function(ct, rg = "All", min_date, max_date, l = 0.00001){
  ctr_all <- db5 %>% 
    filter(Country == ct,
           Region == rg,
           Age <= 80,
           Date >= min_date,
           Date <= max_date) %>%  
    select(Country, Region, Date, Age, Cases) %>% 
    group_by(Country, Region, Age) %>% 
    mutate(n_cas = Cases - lag(Cases),
           n_cas = ifelse(n_cas < 0, 0, n_cas)) %>% 
    replace_na(list(n_cas = 0)) %>% 
    ungroup()
           
  ages <- unique(ctr_all$Age) %>% sort()
  ctr_smth <- tibble()

  for(a in ages){
    ctr_smth <- ctr_smth %>% 
      bind_rows(smooth_cases(ctr_all, a, l))
  }
  
  ctr_all2 <- ctr_smth %>% 
    group_by(Country, Region, Age) %>% 
    mutate(norm_cas = n_cas_sm / max(n_cas_sm, na.rm = T),
           slope_norm_cas = norm_cas - lag(norm_cas),
           dist_cas = n_cas_sm / sum(n_cas_sm, na.rm = T),
           slope_dist_cas = dist_cas - lag(dist_cas)) %>% 
    ungroup() 
  # %>% 
  #   # filter(!is.na(slope_norm_cas)) %>% 
  #   group_by(Country, Region, Date) %>% 
  #   mutate(max_slope_norm = ifelse(slope_norm_cas == max(slope_norm_cas, na.rm = T), 1, 0),
  #          max_slope_dist = ifelse(slope_dist_cas == max(slope_dist_cas, na.rm = T), 1, 0)) %>% 
  #   ungroup() %>% 
  #   group_by(Country, Region, Age) %>% 
  #   mutate(max_slope_norm_h = ifelse(slope_norm_cas == max(slope_norm_cas, na.rm = T), 1, 0)) %>% 
  #   ungroup()
}

p_surface <- function(ctr, r, min_date, max_date, l = 0.0001){
  set_ctr(ctr, r, min_date, max_date ,l) %>% 
    ggplot()+
    geom_tile(aes(Date, Age, fill = norm_cas))+
    scale_fill_viridis_b(breaks = seq(0, 1, 0.1))+
    labs(title = paste0(ctr, ", ", r, ", ", wave, " wave"))+
    scale_y_continuous(breaks = seq(0, 80, 5))+
    geom_hline(yintercept = c(7.5, 17.5), col = "grey", linetype = "dashed")+
    coord_cartesian(expand = F)
}

age_profile <- function(ctr, r, t = 0.2, min_date, max_date, l = 0.0001){
  set_ctr(ctr, r, min_date, max_date, l) %>% 
    mutate(up = ifelse(norm_cas >= t, 1, 0)) %>% 
    filter(up == 1) %>% 
    group_by(Age) %>% 
    filter(Date == min(Date))
}

p_age_profile <- function(ctr, r, t, min_date, max_date, l = 0.0001){
  set_ctr(ctr, r, min_date, max_date, l) %>% 
    mutate(up = ifelse(norm_cas >= t, 1, 0)) %>% 
    filter(up == 1) %>% 
    group_by(Age) %>% 
    filter(Date == min(Date)) %>% 
    ggplot()+
    geom_line(aes(Age, Date), col = "black", size = 1, alpha = 0.3)+
    geom_point(aes(Age, Date), col = "black", size = 1.5)+
    scale_y_date(limits = ymd(c(min_date, max_date)))+
    scale_x_continuous(breaks = c(seq(0, 20, 5), seq(20, 80, 10)))+
    geom_vline(xintercept = 20, linetype = "dashed")+
    labs(title = paste0(ctr, ", ", r, ", ", wave, " wave"))+
    theme_bw()+
    coord_flip(expand = F)
}



# loading data ####
###################
osf_retrieve_file("7tnfh") %>%
  osf_download(conflicts = "overwrite",
               path = "Data") 

# This reads it in
db5 <-  read_csv("Data/Output_5.zip",
                skip = 3,
                col_types = cols(.default = "c")) %>% 
  mutate(Date = dmy(Date),
         Cases = as.double(Cases),
         Tests = as.double(Tests),
         Age = as.integer(Age)) %>% 
  filter(Sex == "b",
         !grepl("ECDC", Code))


################
# Spain
################
ctr <- "Spain"
min_date <- "2020-02-15"
max_date <- "2021-01-31"
r <- "All"

tx <- 10

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, n_cas_sm, col = Age, group = Age))+
  theme_bw()+
  labs(y = "Cases")+
  coord_cartesian(expand = F)+
  scale_y_continuous(breaks = seq(0, 1500, 300))+
  scale_color_continuous(trans = 'reverse')+
  guides(colour = guide_colorbar(reverse = T))+
  scale_x_date(date_breaks = "1 month", date_labels = "%b")+
  annotate(geom = "text", label = "Spain\nDaily new cases", 
           x = ymd("2020-04-01"), y = 1450, hjust = 0, col = "black", size = 4.5)+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )

ggsave("Talks/WHO_talk/fig1_new_cases_age_2020.png", width = 5)


set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

# Note: To analyze the trend in each wave, let's segment periods between the 
# beginning of each wave and just after the peak

# First wave
min_date <- "2020-03-01"
max_date <- "2020-04-15"
wave <- "first"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, n_cas_sm, col = Age, group = Age))+
  theme_bw()+
  labs(y = "Cases")+
  coord_cartesian(expand = F)+
  scale_y_continuous(breaks = seq(0, 1500, 200))+
  scale_color_continuous(trans = 'reverse')+
  guides(colour = guide_colorbar(reverse = T))+
  scale_x_date(date_breaks = "1 week", date_labels = "%d/%m")+
  annotate(geom = "text", label = "First wave", 
           x = ymd("2020-03-5"), y = 800, hjust = 0, col = "black", size = 4.5)+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )

ggsave("Talks/WHO_talk/fig1_new_cases_age_first_wave.png", width = 4)

selec_ages <- c(0, 15, 30, 45, 60, 80)

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))
  
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))+
  theme_bw()+
  labs(y = "Cases")+
  coord_cartesian(expand = F)+
  scale_y_continuous(breaks = seq(0, 1, 0.1), labels = scales::percent_format(accuracy = 1))+
  scale_color_continuous(trans = 'reverse')+
  guides(colour = guide_colorbar(reverse = T))+
  scale_x_date(date_breaks = "1 week", date_labels = "%d/%m")+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )

ggsave("Talks/WHO_talk/fig2_new_cases_age_first_wave_norm.png", width = 4)

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

 
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  # replace_na(list(norm_cas = 0)) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = norm_cas))+
  scale_fill_viridis_b(breaks = seq(0, 1, 0.1))+
  labs(title = c)+
  format_surface


# surface plot
##############
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  mutate(Age = Age + 2.5) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = norm_cas))+
  scale_fill_viridis_b(breaks = seq(0, 1, 0.1),
                       labels = scales::percent_format(accuracy = 1))+
  labs(title = paste0(ctr, ", ", r, ", ", wave, " wave"))+
  scale_y_continuous(breaks = seq(0, 80, 5))+
  geom_hline(yintercept = c(7.5, 17.5), col = "grey", linetype = "dashed")+
  coord_cartesian(expand = F)+
  scale_x_date(date_breaks = "2 weeks", date_labels = "%d%b")+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )+
  guides(fill = guide_legend(title = "Relative\ngrowth", reverse = T))

ggsave("Talks/WHO_talk/fig3_surface_new_cases_norm.png", width = 6)

# p_age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)
# ggsave("Talks/WHO_talk/fig4_age_profile.png")


spain_prof_20 <- age_profile(ctr, r, 0.2, min_date, max_date, 0.0001) %>% 
  select(Age, Date) %>% 
  mutate(Age = Age + 2.5)

spain_prof_40 <- age_profile(ctr, r, 0.4, min_date, max_date, 0.0001) %>% 
  select(Age, Date) %>% 
  mutate(Age = Age + 2.5)

spain_prof_60 <- age_profile(ctr, r, 0.6, min_date, max_date, 0.0001) %>% 
  select(Age, Date) %>% 
  mutate(Age = Age + 2.5)

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  mutate(Age = Age + 2.5) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = norm_cas))+
  scale_fill_viridis_b(breaks = seq(0, 1, 0.1),
                       labels = scales::percent_format(accuracy = 1))+
  labs(title = paste0(ctr, ", ", r, ", ", wave, " wave"))+
  scale_y_continuous(breaks = seq(0, 80, 5))+
  geom_hline(yintercept = c(7.5, 17.5), col = "grey", linetype = "dashed")+
  coord_cartesian(expand = F)+
  scale_x_date(date_breaks = "2 weeks", date_labels = "%d%b")+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )+
  guides(fill = guide_legend(title = "Relative\ngrowth", reverse = T))+
  geom_point(data = spain_prof_20, aes(Date, Age), color = "white", size = 4)+
  # geom_point(data = spain_prof_60, aes(Date, Age), color = "#A4243B", size = 4)+
  annotate(geom = "text", label = "20%", 
           x = ymd("2020-03-12"), y = 75, hjust = 1, col = "white", size = 5)

ggsave("Talks/WHO_talk/fig4_surface_new_cases_norm_20.png", width = 6)

spain_prof_20 %>% 
  ggplot()+
  geom_line(aes(Age, Date), alpha = 0.4)+
  geom_point(aes(Age, Date), size = 3)+
  coord_flip()+
  scale_y_date(date_breaks = "4 days", date_labels = "%d%b", 
               limits = ymd(c("2020-03-05", "2020-03-16")))+
  scale_x_continuous(breaks = seq(0, 80, 5))+
  theme_bw()+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )
ggsave("Talks/WHO_talk/fig5_age_profile_spain.png", width = 2)


prof_20 <- tibble()
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)
  
#             
#             
#             
#             
#                        
# prof_20 <- bind_rows(age_profile("Spain", "All", 0.2, "2020-03-01", "2020-04-15", 0.0001) %>% 
#                        mutate(wave = "first"),
#                      age_profile("Spain", "Madrid", 0.2, "2020-03-01", "2020-04-15", 0.0001) %>% 
#                        mutate(wave = "first"),
#                      age_profile("Spain", "All", 0.2, "2020-07-01", "2020-11-15", 0.0001) %>% 
#                        mutate(wave = "second"),
#                      age_profile("Spain", "Madrid", 0.2, "2020-07-01", "2020-11-15", 0.0001) %>% 
#                        mutate(wave = "second"),
#                      age_profile("Belgium", "All", 0.2, "2020-02-15", "2020-04-30", 0.0001) %>% 
#                        mutate(wave = "first"),
#                      age_profile("Belgium", "Brussels", 0.2, "2020-02-15", "2020-04-30", 0.0001) %>% 
#                        mutate(wave = "first"),
#                      age_profile("Belgium", "All", 0.2, "2020-07-15", "2020-12-31", 0.0001) %>% 
#                        mutate(wave = "second"),
#                      age_profile("Belgium", "Brussels", 0.2, "2020-07-15", "2020-12-31", 0.0001) %>% 
#                        mutate(wave = "second")) %>% 
#   mutate(Place = paste(Country, Region, sep = "_")) %>% 
#   select(Place, Age, Date, wave)
               
prof_20 %>% 
  ggplot()+
  geom_line(aes(Age, Date), alpha = 0.4)+
  geom_point(aes(Age, Date), size = 1)+
  geom_vline(xintercept = 20, linetype = "dashed", size = 0.7)+
  geom_vline(xintercept = 10, linetype = "dashed", col = "grey20")+
  coord_flip()+
  scale_y_date(date_breaks = "4 days", date_labels = "%d%b")+
  scale_x_continuous(breaks = seq(0, 80, 10))+
  theme_bw()+
  theme(
    plot.title = element_text(size = tx + 2),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1),
    axis.text.x = element_text(size = tx),
    axis.text.y = element_text(size = tx)
  )+
  facet_wrap(Place ~ wave, scales = "free")

ggsave("Talks/WHO_talk/fig6_age_profiles.png", width = 8)

# slopes over time by age
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, slope_dist_cas, col = Age, group = Age))+
  geom_hline(yintercept = 0)

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, slope_norm_cas, col = Age, group = Age))+
  geom_hline(yintercept = 0)

# slopes surfaces
### distributions
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = slope_dist_cas))+
  scale_fill_gradient2(low = "blue",
                       high = "red")

### normalized
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = slope_norm_cas))+
  scale_fill_gradient2(low = "blue",
                       high = "red")

### Slope leader: Age with maximum slope in each period (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm) %>% 
  filter(max_slope_norm == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()

### Worst moment of increase: date in which each age reached the maximum slope (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm_h) %>% 
  filter(max_slope_norm_h == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()

### date in which each age reached 20% of the peak (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  mutate(up = ifelse(norm_cas >= 0.8, 1, 0)) %>% 
  filter(up == 1) %>% 
  group_by(Age) %>% 
  filter(Date == min(Date)) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  scale_x_date(limits = ymd(c(min_date, max_date)))+
  theme_bw()

p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)


# Madrid
r <- "Madrid"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface

p_surface(ctr, r, min_date, max_date, 0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)

prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

# Second wave
min_date <- "2020-07-01"
max_date <- "2020-11-15"
r <- "All"
wave <- "second"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, n_cas_sm, col = Age, group = Age))

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

### Age with maximum slope in each period (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm) %>% 
  filter(max_slope_norm == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()

### date in wich each age reached the maximum slope (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm_h) %>% 
  filter(max_slope_norm_h == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()


# Madrid
r <- "Madrid"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

### Age with maximum slope in each period (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm) %>% 
  filter(max_slope_norm == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()

### date in wich each age reached the maximum slope (normalized)
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  select(Age, Date, max_slope_norm_h) %>% 
  filter(max_slope_norm_h == 1) %>% 
  ggplot()+
  geom_point(aes(Date, Age), col = "red")+
  theme_bw()

p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)

################
# Belgium
#################
ctr <- "Belgium"

unique(ctr$Region)
r <- "All"
min_date <- "2020-02-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

## First wave
min_date <- "2020-02-15"
max_date <- "2020-04-30"
wave <- "first"
set_ctr(ctr, "All", min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Brussels"
p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

## Second wave
min_date <- "2020-07-15"
max_date <- "2020-12-31"
wave <- "second"

r <- "All"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Brussels"
p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Czechia
################
ctr <- "Czechia"
r <- "All"
unique(ctr$Region)

min_date <- "2020-08-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

min_date <- "2020-08-15"
max_date <- "2020-12-01"
wave <- "unique"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Prague"

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Estonia
################
ctr <- "Estonia"

min_date <- "2020-10-01"
max_date <- "2020-12-31"

r <- "All"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

wave <- "unique"

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Slovenia
################
ctr <- "Slovenia"

unique(ctr$Region)

r <- "All"

min_date <- "2020-03-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

min_date <- "2020-09-01"
max_date <- "2020-11-15"
wave <- "unique"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Argentina
################
ctr <- "Argentina"

unique(ctr$Region)

min_date <- "2020-04-15"
max_date <- "2020-12-31"

r <- "All"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

wave <- "unique"

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "CABA"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Paraguay
################
ctr <- "Paraguay"
r <- "All"

unique(ctr$Region)
min_date <- "2020-05-15"
max_date <- "2020-12-31"

r <- "All"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

wave <- "unique"

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Asuncion"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Colombia
##################
ctr <- "Colombia"
r <- "All"
min_date <- "2020-05-15"
max_date <- "2021-01-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))


wave <- "first"
min_date <- "2020-05-15"
max_date <- "2020-09-15"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Bogota"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Mexico
################
ctr <- "Mexico"

unique(ctr$Region)

r <- "All"
min_date <- "2020-03-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

min_date <- "2020-02-15"
max_date <- "2020-08-01"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date, 0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Ciudad de Mexico"
min_date <- "2020-02-15"
max_date <- "2020-06-30"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)

prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

################
# Philippines
################
ctr <- "Philippines"
r <- "All"
min_date <- "2020-02-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

min_date <- "2020-05-01"
max_date <- "2020-10-01"
wave <- "unique"
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

unique(ctr$Region)

min_date <- "2020-05-01"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, max_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
# prof_20 <- prof_20 %>% 
#   bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
#   select(Country, Region, Age, Date) %>% 
#   mutate(Wave = wave)


################
# Japan
################
ctr <- "Japan"

unique(ctr$Region)

min_date <- "2020-02-01"
max_date <- "2020-12-31"
r <- "All"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

wave <- "first"
min_date <- "2020-01-01"
max_date <- "2020-05-01"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Tokyo"  
set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

wave <- "second"
min_date <- "2020-06-15"
max_date <- "2020-12-31"
r <- "All"

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)

r <- "Tokyo"  

set_ctr(ctr, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface(ctr, r, min_date, max_date ,0.0001)
p_age_profile(ctr, r, 0.2, min_date, max_date ,0.0001)
prof_20 <- prof_20 %>% 
  bind_rows(age_profile(ctr, r, 0.2, min_date, max_date, 0.0001)) %>%
  select(Country, Region, Age, Date) %>% 
  mutate(Wave = wave)


####################
# positivity surface
####################


ct <- "Mexico"
rg <- "All"

min_date <- "2020-03-15"
max_date <- "2020-12-31"

l <- 0.00001

set_ctr2 <- function(ct = "Mexico", rg = "All", min_date, max_date, l = 0.00001){
  ctr_all <- db5 %>% 
    filter(Country == ct,
           Region == rg,
           Age <= 80,
           Date >= min_date,
           Date <= max_date) %>% 
    select(Country, Region, Date, Age, Cases, Tests) %>% 
    group_by(Country, Region, Age) %>% 
    mutate(n_cas = Cases - lag(Cases),
           n_tes = Tests - lag(Tests)) %>% 
    drop_na() %>% 
    ungroup()
  ages <- unique(ctr_all$Age)
  ctr_smth <- tibble()
  for(a in ages){
    ctr_smth <- ctr_smth %>% 
      bind_rows(smooth_cases(ctr_all, a, l))
  }
    ctr_smth_t <- tibble()
  for(a in ages){
    ctr_smth_t <- ctr_smth_t %>% 
      bind_rows(smooth_tests(ctr_all, a, l))
  }
  
  ctr_smth2 <- ctr_smth %>% 
    left_join(ctr_smth_t %>% select(Country, Region, Date, Age, n_tes_sm)) %>% 
    mutate(pos = n_cas_sm / n_tes_sm) %>% 
    group_by(Country, Region, Age) %>% 
    mutate(norm_cas = n_cas_sm / max(n_cas_sm, na.rm = T),
           slp_norm_cas = norm_cas - lag(norm_cas),
           dist_cas = n_cas_sm / sum(n_cas_sm, na.rm = T),
           slp_dist_cas = dist_cas - lag(dist_cas)) %>% 
    ungroup() %>% 
    group_by(Country, Region, Date) %>% 
    mutate(max_slp_norm = ifelse(slp_norm_cas == max(slp_norm_cas), 1, 0),
           max_slp_dist = ifelse(slp_dist_cas == max(slp_dist_cas), 1, 0)) %>% 
    ungroup() %>% 
    group_by(Country, Region, Age) %>% 
    mutate(max_slp_norm_h = ifelse(slp_norm_cas == max(slp_norm_cas, na.rm = T), 1, 0)) %>% 
    ungroup()
}


p_surface_test <- function(c, r, min_date, max_date, l = 0.0001){
  set_ctr2(c, r, min_date, max_date ,l) %>% 
    ggplot()+
    geom_tile(aes(Date, Age, fill = pos))+
    scale_fill_viridis_b(breaks = seq(0, 1, 0.1))+
    labs(title = paste0(c, ", ", r, ", ", wave, " wave"))+
    format_surface
}



c <- "Mexico"
r <- "All"

min_date <- "2020-03-15"
max_date <- "2020-12-31"

set_ctr2(c, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

set_ctr2(c, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, pos, col = Age, group = Age))

min_date <- "2020-08-01"
max_date <- "2020-12-31"

set_ctr2(c, r, min_date, max_date, 0.0001) %>% 
  ggplot()+
  geom_line(aes(Date, norm_cas, col = Age, group = Age))

p_surface_test(c, r, min_date, max_date ,0.0001)

p_surface_test("Estonia", r, min_date, max_date ,0.0001)

min_date <- "2020-08-01"
max_date <- "2020-12-31"

c <- "Estonia"
test <- set_ctr2(c, r, min_date, max_date, 0.0001)



##################################################
# age pattern for all countries in one db
##################################################

cts <- c("Spain", "Belgium")
t <- 0.2

age_profiles <- tibble()
for(ctr in cts){
  temp <- age_profile(ctr, reg, t, min_date, max_date, l = 0.0001)
  age_profiles <- age_profiles %>% 
    bind_rows(temp)
}

age_profiles %>% 
  ggplot()+
  geom_line(aes(Age, Date, col = Region), size = 1, alpha = 0.3)+
  scale_y_date(limits = ymd(c(min_date, max_date)))+
  scale_x_continuous(breaks = c(seq(0, 20, 5), seq(20, 80, 10)))+
  geom_vline(xintercept = 20, linetype = "dashed")+
  theme_bw()+
  coord_flip(expand = F)




##################################################
# age pattern for all regions in one db
##################################################

t <- 0.2
test <-   set_ctr(ctr, r, min_date, max_date, l) %>% 
  mutate(up = ifelse(norm_cas >= t, 1, 0)) %>% 
  filter(up == 1) %>% 
  group_by(Age) %>% 
  filter(Date == min(Date))

regs <- db5 %>% 
  filter(Country == ctr) %>% 
  pull(Region) %>% 
  unique()
# skip_to_next <- FALSE
age_profiles <- tibble()
for(reg in regs){
  skip_to_next <- FALSE
  tryCatch(temp <- age_profile(ctr, reg, t, min_date, max_date, l = 0.0001), 
           error = function(e) { skip_to_next <<- TRUE})
  if(skip_to_next) { next }     
  age_profiles <- age_profiles %>% 
    bind_rows(temp)
}

age_profiles %>% 
  ggplot()+
  geom_line(aes(Age, Date, col = Region), size = 1, alpha = 0.3)+
  scale_y_date(limits = ymd(c(min_date, max_date)))+
  scale_x_continuous(breaks = c(seq(0, 20, 5), seq(20, 80, 10)))+
  geom_vline(xintercept = 20, linetype = "dashed")+
  theme_bw()+
  coord_flip(expand = F)

