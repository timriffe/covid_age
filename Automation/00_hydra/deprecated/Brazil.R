library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Brazil"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

print(today())

googledrive::drive_auth(email = email)
gs4_auth(email = email)


# looking at the spreadsheets in Brazil Drive folder 
content <- 
  drive_ls("https://drive.google.com/drive/u/0/folders/1Jsb9Ymq7fGrMyJ4ZcsvdgWJqVydGxTGf")

# spreadsheets to exclude
excl <- c("Brazil_all_states input template",
          "Brazil_input_info")

links_br <- 
  content %>% 
  filter(!name %in% excl) %>% 
  dplyr::pull(id)

out <- NULL
for(ss_i in links_br){
  temp <- 
    read_sheet(ss_i, 
               sheet = "database", 
               na = "NA", 
               col_types= "cccccciccd",
               range = "database!A:J")
  out <- 
    out %>% 
    bind_rows(temp)
}
out2 <- out
out2$Code = substr(out2$Code,1,nchar(out2$Code)-10)
out2$Code <- gsub("_", "-", out2$Code)
####################################
#### saving database in N Drive ####
####################################
#Since output data = input data only the output data gets saved

write_rds(out2, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))
