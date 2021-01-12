
# New build log 
 Tue Jan 12 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Tue Jan 12 01:00:38 2021 


# A (convert_fractions_sexes) 
 Tue Jan 12 01:04:32 2021 


# B (redistribute_unknown_age) 
 Tue Jan 12 01:07:15 2021 


# C (rescale_to_total) 
 Tue Jan 12 01:20:12 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Tue Jan 12 01:33:49 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Tue Jan 12 01:37:26 2021 


# G (redistribute_unknown_sex) 
 Tue Jan 12 01:41:01 2021 


# H (rescale_sexes) 
 Tue Jan 12 01:45:29 2021 


# I (infer_both_sex) 
 Tue Jan 12 01:46:55 2021 


# J (maybe_lower_closeout) 
 Tue Jan 12 01:51:11 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Tue Jan 12 02:01:18 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TH06.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH01.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH06.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TR03.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR05.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR07.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR12.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR14.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR19.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR21.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR26.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH20.03.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH27.03.2020', Sex == 'b', Measure == 'Cases' )
