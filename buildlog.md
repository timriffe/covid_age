
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
filter( Code == 'BR_SP25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TH01.03.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH01.03.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH03.03.2022', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH03.08.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH04.01.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH09.10.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH11.12.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH12.06.2022', Sex == 'f', Measure == 'Cases' )
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
filter( Code == 'TH11.12.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH12.01.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH12.03.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH12.06.2022', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH03.03.2022', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH03.08.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH04.01.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TH09.10.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'BR_SP25.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TH12.01.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH12.03.2021', Sex == 'm', Measure == 'Cases' )
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
 Wed Jan 20 05:54:07 2021 


# Building dashboards 
 Wed Jan 20 06:08:30 2021 


# remake coverage map 
 Wed Jan 20 06:15:35 2021 


# push outputs to OSF 
 Wed Jan 20 06:20:04 2021 


# remake coverage map 
 Wed Jan 20 09:17:15 2021 


# push outputs to OSF 
 Wed Jan 20 09:21:45 2021 


# Commit dashboards and buildlog 
 Wed Jan 20 09:23:58 2021 

