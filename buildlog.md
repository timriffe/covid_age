
# New build log 
 Mon Jan 11 01:00:08 2021 


# prep (resolve_UNKUNK) 
 Mon Jan 11 01:00:36 2021 


# A (convert_fractions_sexes) 
 Mon Jan 11 01:04:48 2021 


# B (redistribute_unknown_age) 
 Mon Jan 11 01:08:08 2021 


# C (rescale_to_total) 
 Mon Jan 11 01:20:51 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Mon Jan 11 01:34:34 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Mon Jan 11 01:39:31 2021 


# G (redistribute_unknown_sex) 
 Mon Jan 11 01:44:24 2021 


# H (rescale_sexes) 
 Mon Jan 11 01:48:45 2021 


# I (infer_both_sex) 
 Mon Jan 11 01:50:55 2021 


# J (maybe_lower_closeout) 
 Mon Jan 11 01:55:26 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Mon Jan 11 02:07:25 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'm', Measure == 'Tests' )
