
# New build log 
 Fri Feb 26 01:00:08 2021 


# begin resolution of multiple sources per population 
 Fri Feb 26 01:00:08 2021 


# Resolve USA CDC overlaps 
 Fri Feb 26 01:00:54 2021 

USA CDC resolved
 1185 rows removed

# Resolve Brazil TRC overlaps 
 Fri Feb 26 01:00:59 2021 

Brazil TRC resolved
 2706 rows removed

# Resolve Italy Bollettino and Infografico 
 Fri Feb 26 01:01:02 2021 

Italy resolved
 229 rows removed

# Resolve ECDC overlaps 
 Fri Feb 26 01:01:09 2021 

ECDC resolved
 2988 rows removed

# prep (resolve_UNKUNK) 
 Fri Feb 26 01:02:18 2021 


# A (convert_fractions_sexes) 
 Fri Feb 26 01:06:57 2021 


# B (redistribute_unknown_age) 
 Fri Feb 26 01:10:00 2021 


# C (rescale_to_total) 
 Fri Feb 26 01:24:30 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Fri Feb 26 01:39:34 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Fri Feb 26 01:43:41 2021 


# G (redistribute_unknown_sex) 
 Fri Feb 26 01:47:45 2021 


# H (rescale_sexes) 
 Fri Feb 26 01:54:10 2021 


# I (infer_both_sex) 
 Fri Feb 26 01:55:51 2021 


# J (maybe_lower_closeout) 
 Fri Feb 26 02:00:29 2021 

filter( Code == 'CA_TNT15.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_TNT15.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_TNT15.07.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'NZ15.01.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'NZ22.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'NZ23.02.2021', Sex == 'b', Measure == 'Tests' )
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
filter( Code == 'GB_SCO_22.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_22.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_23.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'f', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'm', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'b', Measure == 'Cases' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'f', Measure == 'Tests' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'm', Measure == 'Tests' )
filter( Code == 'GB_SCO_24.02.2021', Sex == 'b', Measure == 'Tests' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Fri Feb 26 02:11:14 2021 


# Compile metadata 
 Fri Feb 26 04:42:52 2021 


# Building dashboards 
 Fri Feb 26 05:00:15 2021 


# remake coverage map 
 Fri Feb 26 05:08:54 2021 


# push outputs to OSF 
 Fri Feb 26 05:13:35 2021 


# remake coverage map 
 Fri Feb 26 07:28:00 2021 


# push outputs to OSF 
 Fri Feb 26 07:32:33 2021 


# Commit dashboards and buildlog 
 Fri Feb 26 07:35:15 2021 

