
# New build log 
 Sun Jan 10 01:00:08 2021 


# prep (resolve_UNKUNK) 
 Sun Jan 10 01:00:36 2021 


# A (convert_fractions_sexes) 
 Sun Jan 10 01:04:47 2021 


# B (redistribute_unknown_age) 
 Sun Jan 10 01:08:06 2021 


# C (rescale_to_total) 
 Sun Jan 10 01:20:47 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sun Jan 10 01:34:26 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sun Jan 10 01:39:21 2021 


# G (redistribute_unknown_sex) 
 Sun Jan 10 01:44:15 2021 


# H (rescale_sexes) 
 Sun Jan 10 01:48:35 2021 


# I (infer_both_sex) 
 Sun Jan 10 01:50:44 2021 


# J (maybe_lower_closeout) 
 Sun Jan 10 01:55:15 2021 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sun Jan 10 02:07:12 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'NL09.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'MX_OAX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'MX04.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TH06.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH01.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH23.12.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'b', Measure == 'Cases' )
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
filter( Code == 'NL09.01.2021', Sex == 'f', Measure == 'Deaths' )
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
filter( Code == 'NL09.01.2021', Sex == 'm', Measure == 'Deaths' )
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
filter( Code == 'SZ.05.12.2020', Sex == 'm', Measure == 'Deaths' )

# Compile metadata 
 Sun Jan 10 05:43:20 2021 


# Building dashboards 
 Sun Jan 10 05:56:10 2021 


# remake coverage map 
 Sun Jan 10 06:02:44 2021 


# push outputs to OSF 
 Sun Jan 10 06:07:15 2021 


# remake coverage map 
 Sun Jan 10 08:34:30 2021 


# push outputs to OSF 
 Sun Jan 10 08:38:57 2021 


# Commit dashboards and buildlog 
 Sun Jan 10 08:41:10 2021 


# update build series log 
 Sun Jan 10 08:41:17 2021 

