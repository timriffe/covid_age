
# New build log 
 Wed Jan 13 01:00:09 2021 


# prep (resolve_UNKUNK) 
 Wed Jan 13 01:00:37 2021 


# A (convert_fractions_sexes) 
 Wed Jan 13 01:04:37 2021 


# B (redistribute_unknown_age) 
 Wed Jan 13 01:07:22 2021 


# C (rescale_to_total) 
 Wed Jan 13 01:20:27 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Wed Jan 13 01:33:49 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Wed Jan 13 01:37:23 2021 


# G (redistribute_unknown_sex) 
 Wed Jan 13 01:40:57 2021 


# H (rescale_sexes) 
 Wed Jan 13 01:45:26 2021 


# I (infer_both_sex) 
 Wed Jan 13 01:46:51 2021 


# J (maybe_lower_closeout) 
 Wed Jan 13 01:51:02 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Wed Jan 13 02:01:10 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'TH06.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH01.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH06.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TH20.03.2020', Sex == 'b', Measure == 'Cases' )
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
filter( Code == 'TH23.12.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH27.03.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TH01.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH20.03.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH27.03.2020', Sex == 'm', Measure == 'Cases' )
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
filter( Code == 'SZ14.10.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'NL12.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK10.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'SZ14.10.2020', Sex == 'f', Measure == 'Deaths' )
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
 Wed Jan 13 05:41:59 2021 


# Building dashboards 
 Wed Jan 13 05:54:47 2021 


# remake coverage map 
 Wed Jan 13 06:01:39 2021 


# push outputs to OSF 
 Wed Jan 13 06:06:08 2021 


# remake coverage map 
 Wed Jan 13 08:16:24 2021 


# push outputs to OSF 
 Wed Jan 13 08:20:53 2021 


# Commit dashboards and buildlog 
 Wed Jan 13 08:23:00 2021 

