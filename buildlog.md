
# New build log 
 Sun Jan 24 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Sun Jan 24 01:00:42 2021 


# A (convert_fractions_sexes) 
 Sun Jan 24 01:05:12 2021 


# B (redistribute_unknown_age) 
 Sun Jan 24 01:08:27 2021 


# C (rescale_to_total) 
 Sun Jan 24 01:23:38 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sun Jan 24 01:39:16 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sun Jan 24 01:43:27 2021 


# G (redistribute_unknown_sex) 
 Sun Jan 24 01:47:37 2021 


# H (rescale_sexes) 
 Sun Jan 24 01:52:52 2021 


# I (infer_both_sex) 
 Sun Jan 24 01:54:32 2021 


# J (maybe_lower_closeout) 
 Sun Jan 24 01:59:27 2021 

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
filter( Code == 'GB_SCO_22.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_22.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sun Jan 24 02:11:03 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
