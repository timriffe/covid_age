
# New build log 
 Sat Jan 09 01:00:08 2021 


# prep (resolve_UNKUNK) 
 Sat Jan 09 01:00:36 2021 


# A (convert_fractions_sexes) 
 Sat Jan 09 01:04:48 2021 


# B (redistribute_unknown_age) 
 Sat Jan 09 01:08:08 2021 


# C (rescale_to_total) 
 Sat Jan 09 01:20:54 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sat Jan 09 01:34:40 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sat Jan 09 01:39:36 2021 


# G (redistribute_unknown_sex) 
 Sat Jan 09 01:44:31 2021 


# H (rescale_sexes) 
 Sat Jan 09 01:48:52 2021 


# I (infer_both_sex) 
 Sat Jan 09 01:51:03 2021 


# J (maybe_lower_closeout) 
 Sat Jan 09 01:55:34 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sat Jan 09 02:07:34 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL08.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TH06.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'f', Measure == 'Cases' )
