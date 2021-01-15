
# New build log 
 Fri Jan 15 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Fri Jan 15 01:00:40 2021 


# A (convert_fractions_sexes) 
 Fri Jan 15 01:04:40 2021 


# B (redistribute_unknown_age) 
 Fri Jan 15 01:07:31 2021 


# C (rescale_to_total) 
 Fri Jan 15 01:21:03 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Fri Jan 15 01:35:09 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Fri Jan 15 01:38:52 2021 


# G (redistribute_unknown_sex) 
 Fri Jan 15 01:42:33 2021 


# H (rescale_sexes) 
 Fri Jan 15 01:47:10 2021 


# I (infer_both_sex) 
 Fri Jan 15 01:48:38 2021 


# J (maybe_lower_closeout) 
 Fri Jan 15 01:53:01 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Fri Jan 15 02:03:31 2021 

filter( Code == 'BR_SP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL14.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
