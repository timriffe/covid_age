
# New build log 
 Sat Jan 16 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Sat Jan 16 01:00:40 2021 


# A (convert_fractions_sexes) 
 Sat Jan 16 01:04:55 2021 


# B (redistribute_unknown_age) 
 Sat Jan 16 01:07:52 2021 


# C (rescale_to_total) 
 Sat Jan 16 01:22:09 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sat Jan 16 01:36:57 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sat Jan 16 01:40:52 2021 


# G (redistribute_unknown_sex) 
 Sat Jan 16 01:44:46 2021 


# H (rescale_sexes) 
 Sat Jan 16 01:49:54 2021 


# I (infer_both_sex) 
 Sat Jan 16 01:51:29 2021 


# J (maybe_lower_closeout) 
 Sat Jan 16 01:56:05 2021 

filter( Code == 'NZ15.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sat Jan 16 02:07:07 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL15.01.2021', Sex == 'b', Measure == 'Deaths' )
