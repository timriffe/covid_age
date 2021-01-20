
# New build log 
 Wed Jan 20 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Wed Jan 20 01:00:40 2021 


# A (convert_fractions_sexes) 
 Wed Jan 20 01:04:49 2021 


# B (redistribute_unknown_age) 
 Wed Jan 20 01:07:45 2021 


# C (rescale_to_total) 
 Wed Jan 20 01:21:40 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Wed Jan 20 01:36:13 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Wed Jan 20 01:40:05 2021 


# G (redistribute_unknown_sex) 
 Wed Jan 20 01:43:56 2021 


# H (rescale_sexes) 
 Wed Jan 20 01:48:56 2021 


# I (infer_both_sex) 
 Wed Jan 20 01:50:28 2021 


# J (maybe_lower_closeout) 
 Wed Jan 20 01:54:58 2021 

filter( Code == 'NZ15.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Wed Jan 20 02:05:51 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'f', Measure == 'Deaths' )
