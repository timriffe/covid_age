
# New build log 
 Wed Feb 10 01:00:10 2021 


# begin resolution of multiple sources per population 
 Wed Feb 10 01:00:10 2021 


# Resolve USA CDC overlaps 
 Wed Feb 10 01:00:56 2021 

USA CDC resolved
 1274 rows removed

# Resolve Brazil TRC overlaps 
 Wed Feb 10 01:01:01 2021 

Brazil TRC resolved
 858 rows removed

# Resolve Italy Bollettino and Infografico 
 Wed Feb 10 01:01:05 2021 

Italy resolved
 229 rows removed

# Resolve ECDC overlaps 
 Wed Feb 10 01:01:13 2021 

ECDC resolved
 2970 rows removed

# prep (resolve_UNKUNK) 
 Wed Feb 10 01:02:22 2021 


# A (convert_fractions_sexes) 
 Wed Feb 10 01:06:59 2021 


# B (redistribute_unknown_age) 
 Wed Feb 10 01:10:12 2021 


# C (rescale_to_total) 
 Wed Feb 10 01:25:08 2021 

filter( Code == 'US_NYC28.11.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'US_NYC28.11.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'US_NYC28.11.2020', Sex == 'm', Measure == 'Deaths' )

# D (infer_cases_from_deaths_and_ascfr) 
 Wed Feb 10 01:40:38 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Wed Feb 10 01:44:52 2021 


# G (redistribute_unknown_sex) 
 Wed Feb 10 01:49:06 2021 


# H (rescale_sexes) 
 Wed Feb 10 01:55:49 2021 


# I (infer_both_sex) 
 Wed Feb 10 01:57:29 2021 


# J (maybe_lower_closeout) 
 Wed Feb 10 02:02:27 2021 

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
filter( Code == 'GB_SCO_24.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_24.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_25.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_26.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_27.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_28.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_29.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_30.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_31.01.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_01.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_02.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_03.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_04.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_05.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_06.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_07.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_08.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Wed Feb 10 02:14:18 2021 


# Compile metadata 
 Wed Feb 10 12:36:22 2021 


# remake coverage map 
 Wed Feb 10 17:26:07 2021 


# push outputs to OSF 
 Wed Feb 10 17:30:48 2021 


# Commit dashboards and buildlog 
 Wed Feb 10 17:33:41 2021 


# update build series log 
 Wed Feb 10 17:33:54 2021 

