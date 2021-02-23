
# New build log 
 Tue Feb 23 01:00:11 2021 


# begin resolution of multiple sources per population 
 Tue Feb 23 01:00:11 2021 


# Resolve USA CDC overlaps 
 Tue Feb 23 01:00:56 2021 

USA CDC resolved
 1185 rows removed

# Resolve Brazil TRC overlaps 
 Tue Feb 23 01:01:01 2021 

Brazil TRC resolved
 2277 rows removed

# Resolve Italy Bollettino and Infografico 
 Tue Feb 23 01:01:05 2021 

Italy resolved
 229 rows removed

# Resolve ECDC overlaps 
 Tue Feb 23 01:01:12 2021 

ECDC resolved
 2862 rows removed

# prep (resolve_UNKUNK) 
 Tue Feb 23 01:02:21 2021 


# A (convert_fractions_sexes) 
 Tue Feb 23 01:06:55 2021 


# B (redistribute_unknown_age) 
 Tue Feb 23 01:09:57 2021 


# C (rescale_to_total) 
 Tue Feb 23 01:24:08 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Tue Feb 23 01:38:55 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Tue Feb 23 01:42:55 2021 


# G (redistribute_unknown_sex) 
 Tue Feb 23 01:46:55 2021 


# H (rescale_sexes) 
 Tue Feb 23 01:53:13 2021 


# I (infer_both_sex) 
 Tue Feb 23 01:54:53 2021 


# J (maybe_lower_closeout) 
 Tue Feb 23 01:59:27 2021 

filter( Code == 'CA_TNT15.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_TNT15.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_TNT15.07.2020', Sex == 'b', Measure == 'Cases' )
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
filter( Code == 'GB_SCO_09.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_09.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_10.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_11.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_12.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_13.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_14.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_15.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_16.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_17.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_18.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_19.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_20.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_21.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Tue Feb 23 02:10:12 2021 


# Compile metadata 
 Tue Feb 23 04:46:44 2021 


# Building dashboards 
 Tue Feb 23 05:01:59 2021 


# remake coverage map 
 Tue Feb 23 05:10:55 2021 


# push outputs to OSF 
 Tue Feb 23 05:15:27 2021 


# remake coverage map 
 Tue Feb 23 07:25:45 2021 


# push outputs to OSF 
 Tue Feb 23 07:30:19 2021 


# Commit dashboards and buildlog 
 Tue Feb 23 07:33:16 2021 

