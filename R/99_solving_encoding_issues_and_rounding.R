library(tidyverse)
library(stringi)

Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL","English")

fix_enc <- 
  function(db){
    db %>% 
      mutate(Region = ifelse(validUTF8(Region), Region, iconv(Region)),
             Region = stri_encode(Region, "", "UTF-8"))
  }

out05 <- read.csv("N:/COVerAGE-DB/Data/Output_5_internal.csv", encoding = "UTF-8")
out10 <- read.csv("N:/COVerAGE-DB/Data/Output_10_internal.csv", encoding = "UTF-8")
input <- read.csv("N:/COVerAGE-DB/Data/inputDB_internal.csv", encoding = "UTF-8")

out05_enc <- fix_enc(out05)
out10_enc <- fix_enc(out10)
input_enc <- fix_enc(input)

out05_enc_rd <- 
  out05_enc %>% 
  mutate(Cases = round(Cases, 1),
         Deaths = round(Deaths, 1),
         Tests = round(Tests, 1))

out10_enc_rd <- 
  out10_enc %>% 
  mutate(Cases = round(Cases, 1),
         Deaths = round(Deaths, 1),
         Tests = round(Tests, 1))

input_enc_rd <- 
  input_enc %>% 
  mutate(Value = round(Value, 1)) %>% 
  select(-templateID)

# write.csv(out05_enc, "N:/COVerAGE-DB/website_data/web_out05.csv", fileEncoding = "UTF-8")
# write.csv(out10_enc, "N:/COVerAGE-DB/website_data/web_out10.csv", fileEncoding = "UTF-8")
# write.csv(input_enc, "N:/COVerAGE-DB/website_data/web_input.csv", fileEncoding = "UTF-8")

write_csv(out05_enc_rd, "N:/COVerAGE-DB/website_data/web_out05.csv", 
          na = "")
write_csv(out10_enc_rd, "N:/COVerAGE-DB/website_data/web_out10.csv", 
          na = "")
write_csv(input_enc_rd, "N:/COVerAGE-DB/website_data/web_input.csv", 
          na = "")


# writing a csv example to verify in Notepad++
test <-
  out05_enc_rd %>%
  filter(Code %in% c("DE-TH", "ES-C"))

write.csv(test, "N:/COVerAGE-DB/website_data/web_test.csv", fileEncoding = "UTF-8")
write_csv(test, "N:/COVerAGE-DB/website_data/web_test2.csv",
          na = "")
# 
# 
# # testing encoding issues (Spain and Germany)
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# original_regs <- 
#   out05 %>% 
#   filter(Code %in% c("DE-TH", "ES-C")) %>% 
#   pull(Region) %>% 
#   unique()
# 
# adjusted_regs <- 
#   out05_enc %>% 
#   filter(Code %in% c("DE-TH", "ES-C")) %>% 
#   pull(Region) %>% 
#   unique()
# 
# # all remaining issues
# enc_issues <- 
#   out05 %>% 
#   filter(!validUTF8(Region))
# 
# enc_issues <- 
#   out05_enc %>% 
#   filter(!validUTF8(Region)) %>% 
#   mutate(enc = stri_enc_mark(Region),
#          Region2 = stri_encode(Region, "", "UTF-8"),
#          enc2 = stri_enc_mark(Region2))
# 
# enc_issues <- 
#   out05 %>% 
#   filter(!validUTF8(Code))
