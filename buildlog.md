
# New build log 
 Sat Jan 23 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Sat Jan 23 01:00:38 2021 


# A (convert_fractions_sexes) 
 Sat Jan 23 01:04:38 2021 


# B (redistribute_unknown_age) 
 Sat Jan 23 01:07:26 2021 


# C (rescale_to_total) 
 Sat Jan 23 01:20:50 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sat Jan 23 01:34:47 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sat Jan 23 01:38:27 2021 


# G (redistribute_unknown_sex) 
 Sat Jan 23 01:42:07 2021 


# H (rescale_sexes) 
 Sat Jan 23 01:46:36 2021 


# I (infer_both_sex) 
 Sat Jan 23 01:48:04 2021 


# J (maybe_lower_closeout) 
 Sat Jan 23 01:52:24 2021 

filter( Code == 'NZ15.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_21.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sat Jan 23 02:02:53 2021 

