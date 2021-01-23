library(osfr)
library(tidyverse)
library(lubridate)
library(zoo)

smooth_cases <- function(db, a, l = 0.00001){
  temp1 <- db %>% 
    filter(Age == a) %>% 
    mutate(days = 1:n())
  
  xs <- temp1$days
  ys <- temp1$n_cas
  
  md <- smooth.spline(x = xs, y = ys, lambda = l)
  
  temp2 <- temp1 %>% 
    mutate(n_cas_sm = predict(md, xs)$y)
}

set_ctr <- function(db_ctr, rg = "All", min_date, l = 0.00001){
  ctr_all <- db_ctr %>% 
    filter(Region == rg,
           Date >= min_date) %>% 
    select(Country, Region, Date, Age, Cases) %>% 
    group_by(Country, Region, Age) %>% 
    mutate(n_cas = Cases - lag(Cases)) %>% 
    drop_na() %>% 
    ungroup()
  ages <- unique(ctr_all$Age)
  ctr_smth <- tibble()
  for(a in ages){
    ctr_smth <- ctr_smth %>% 
      bind_rows(smooth_cases(ctr_all, a, l))
  }
  
  ctr_smth2 <- ctr_smth %>% 
    group_by(Country, Region, Age) %>% 
    mutate(dist_cas = n_cas_sm / sum(n_cas_sm, na.rm = T),
           slp_cas = dist_cas - lag(dist_cas)) %>% 
    ungroup() %>% 
    group_by(Country, Region, Date) %>% 
    mutate(max_slp = ifelse(slp_cas == max(slp_cas), 1, 0)) %>% 
    ungroup()
}

format_surface <- list(scale_y_continuous(breaks = seq(0, 80, 5)),
                       geom_hline(yintercept = c(7.5, 17.5), col = "grey", linetype = "dashed"),
                       coord_cartesian(expand = F),
                       theme(legend.position = "none"))


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
  filter(Sex == "b")



# Spain
########
c <- "Spain"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)
r <- "Madrid"

min_date <- "2020-06-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface


set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface



# Belgium
########
c <- "Belgium"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)
r <- "Brussels"

min_date <- "2020-03-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface


# Czechia
########
c <- "Czechia"
r <- "Prague"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-08-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface
  
# Estonia
########
c <- "Estonia"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-09-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

# Slovenia
########
c <- "Slovenia"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-08-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface


# Argentina
########
c <- "Argentina"
r <- "CABA"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-04-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface


# Paraguay
########
c <- "Paraguay"
r <- "All"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)
min_date <- "2020-05-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

set_ctr(ctr, "Asuncion", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  format_surface


# Colombia
##########
c <- "Colombia"
r <- "Bogota"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)
min_date <- "2020-05-15"
max_date <- "2020-12-31"

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface

# slopes
set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, slp_cas, col = Age, group = Age))

# slopes surface
set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = slp_cas))+
  scale_fill_gradient2(low = "blue",
                       high = "red")

# Mexico
########
c <- "Mexico"
r <- "Ciudad de Mexico"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-03-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface
set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface


# Philippines
########
c <- "Philippines"
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-05-01"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface



# Japan
########
c <- "Japan"
r <- "Tokyo"  
ctr <- db5 %>% 
  filter(Country == c) %>% 
  filter(Age <= 80) 

unique(ctr$Region)

min_date <- "2020-06-15"
max_date <- "2020-12-31"

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_line(aes(Date, dist_cas, col = Age, group = Age))

set_ctr(ctr, "All", min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = c)+
  format_surface

set_ctr(ctr, r, min_date, 0.0001) %>% 
  filter(Date <= max_date) %>% 
  ggplot()+
  geom_tile(aes(Date, Age, fill = dist_cas))+
  scale_fill_viridis_b()+
  labs(title = r)+
  format_surface



