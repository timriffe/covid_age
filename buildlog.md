
# New build log 
 Mon Jan 25 01:00:10 2021 


# prep (resolve_UNKUNK) 
 Mon Jan 25 01:00:43 2021 


# A (convert_fractions_sexes) 
 Mon Jan 25 01:05:16 2021 


# B (redistribute_unknown_age) 
 Mon Jan 25 01:09:15 2021 


# C (rescale_to_total) 
 Mon Jan 25 01:32:27 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Mon Jan 25 02:01:22 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Mon Jan 25 02:09:28 2021 


# G (redistribute_unknown_sex) 
 Mon Jan 25 02:17:38 2021 


# H (rescale_sexes) 
 Mon Jan 25 02:28:12 2021 


# I (infer_both_sex) 
 Mon Jan 25 02:31:27 2021 


# J (maybe_lower_closeout) 
 Mon Jan 25 02:40:47 2021 

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
filter( Code == 'GB_SCO_23.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_23.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Mon Jan 25 03:06:16 2021 

filter( Code == 'BR_AP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_AP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_PI29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP25.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'TH03.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH01.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH01.12.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH03.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH15.12.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH20.03.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH24.11.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH22.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH24.11.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TH30.12.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TH27.03.2020', Sex == 'b', Measure == 'Cases' )
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
filter( Code == 'TH30.12.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_VT21.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'BR_SP25.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TH01.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'TH01.12.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH04.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH15.12.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH20.03.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TH22.09.2020', Sex == 'm', Measure == 'Cases' )
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
filter( Code == 'BR_SP25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_SP29.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO25.12.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'BR_TO29.12.2020', Sex == 'm', Measure == 'Deaths' )
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
 Mon Jan 25 12:14:15 2021 


# Building dashboards 
 Mon Jan 25 12:28:23 2021 


# remake coverage map 
 Mon Jan 25 12:58:15 2021 


# push outputs to OSF 
 Mon Jan 25 13:03:23 2021 

