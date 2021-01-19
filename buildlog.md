
# New build log 
 Tue Jan 19 01:00:08 2021 


# prep (resolve_UNKUNK) 
 Tue Jan 19 01:00:38 2021 


# A (convert_fractions_sexes) 
 Tue Jan 19 01:04:35 2021 


# B (redistribute_unknown_age) 
 Tue Jan 19 01:07:21 2021 


# C (rescale_to_total) 
 Tue Jan 19 01:20:34 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Tue Jan 19 01:34:36 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Tue Jan 19 01:38:16 2021 


# G (redistribute_unknown_sex) 
 Tue Jan 19 01:41:54 2021 


# H (rescale_sexes) 
 Tue Jan 19 01:46:40 2021 


# I (infer_both_sex) 
 Tue Jan 19 01:48:07 2021 


# J (maybe_lower_closeout) 
 Tue Jan 19 01:52:23 2021 

filter( Code == 'NZ15.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Tue Jan 19 02:02:47 2021 

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
filter( Code == 'TH11.12.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH12.06.2022', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH09.10.2021', Sex == 'b', Measure == 'Cases' )
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
filter( Code == 'BR_SP25.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'b', Measure == 'Deaths' )
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
 Tue Jan 19 05:44:51 2021 


# Building dashboards 
 Tue Jan 19 05:57:34 2021 


# remake coverage map 
 Tue Jan 19 06:04:23 2021 


# push outputs to OSF 
 Tue Jan 19 06:08:52 2021 


# remake coverage map 
 Tue Jan 19 07:56:26 2021 


# push outputs to OSF 
 Tue Jan 19 08:03:46 2021 


# Commit dashboards and buildlog 
 Tue Jan 19 08:05:55 2021 


# update build series log 
 Tue Jan 19 08:06:02 2021 

