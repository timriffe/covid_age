
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

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL22.01.2021', Sex == 'b', Measure == 'Deaths' )
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
filter( Code == 'US_VT21.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'BR_SP25.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TR03.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR05.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR07.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR12.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR14.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR19.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR21.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR26.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'NL22.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL22.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK10.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK10.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'SZ14.10.2020', Sex == 'm', Measure == 'Deaths' )

# Compile metadata 
 Sat Jan 23 08:26:13 2021 


# Building dashboards 
 Sat Jan 23 08:39:29 2021 


# remake coverage map 
 Sat Jan 23 08:47:12 2021 


# remake coverage map 
 Sat Jan 23 08:50:53 2021 


# push outputs to OSF 
 Sat Jan 23 08:51:41 2021 


# push outputs to OSF 
 Sat Jan 23 08:55:23 2021 


# Commit dashboards and buildlog 
 Sat Jan 23 08:57:38 2021 


# update build series log 
 Sat Jan 23 08:57:46 2021 

