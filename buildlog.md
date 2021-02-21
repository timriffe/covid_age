
# New build log 
 Sun Feb 21 01:00:08 2021 


# begin resolution of multiple sources per population 
 Sun Feb 21 01:00:08 2021 


# Resolve USA CDC overlaps 
 Sun Feb 21 01:00:53 2021 

USA CDC resolved
 1185 rows removed

# Resolve Brazil TRC overlaps 
 Sun Feb 21 01:00:58 2021 

Brazil TRC resolved
 2013 rows removed

# Resolve Italy Bollettino and Infografico 
 Sun Feb 21 01:01:01 2021 

Italy resolved
 229 rows removed

# Resolve ECDC overlaps 
 Sun Feb 21 01:01:08 2021 

ECDC resolved
 2862 rows removed

# prep (resolve_UNKUNK) 
 Sun Feb 21 01:02:16 2021 


# A (convert_fractions_sexes) 
 Sun Feb 21 01:06:47 2021 


# B (redistribute_unknown_age) 
 Sun Feb 21 01:09:47 2021 


# C (rescale_to_total) 
 Sun Feb 21 01:23:59 2021 


# D (infer_cases_from_deaths_and_ascfr) 
 Sun Feb 21 01:38:51 2021 


# E (infer_deaths_from_cases_and_ascfr) 
 Sun Feb 21 01:42:49 2021 


# G (redistribute_unknown_sex) 
 Sun Feb 21 01:46:48 2021 


# H (rescale_sexes) 
 Sun Feb 21 01:53:00 2021 


# I (infer_both_sex) 
 Sun Feb 21 01:54:38 2021 


# J (maybe_lower_closeout) 
 Sun Feb 21 01:59:11 2021 

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
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Sun Feb 21 02:09:42 2021 


# Compile metadata 
 Sun Feb 21 06:45:36 2021 


# Building dashboards 
 Sun Feb 21 07:02:05 2021 


# remake coverage map 
 Sun Feb 21 07:10:32 2021 


# push outputs to OSF 
 Sun Feb 21 07:15:03 2021 


# remake coverage map 
 Sun Feb 21 08:49:49 2021 


# push outputs to OSF 
 Sun Feb 21 08:54:21 2021 


# Commit dashboards and buildlog 
 Sun Feb 21 08:57:14 2021 


# update build series log 
 Sun Feb 21 08:57:21 2021 

