
# New build log 
 Mon Nov 09 02:00:08 2020 


# prep (resolve_UNKUNK) 
 Mon Nov 09 02:00:25 2020 


# A (convert_fractions_sexes) 
 Mon Nov 09 02:03:01 2020 


# B (redistribute_unknown_age) 
 Mon Nov 09 02:05:10 2020 


# C (rescale_to_total) 
 Mon Nov 09 02:12:01 2020 

filter( Code == 'CO_Other09.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CO_Other09.04.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CO_Other09.04.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CO_Other09.04.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CO_Other09.04.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CO_Other09.04.2020', Sex == 'm', Measure == 'Deaths' )

# D (infer_cases_from_deaths_and_ascfr) 
 Mon Nov 09 02:24:59 2020 


# E (infer_deaths_from_cases_and_ascfr) 
 Mon Nov 09 02:27:34 2020 


# G (redistribute_unknown_sex) 
 Mon Nov 09 02:30:06 2020 


# H (rescale_sexes) 
 Mon Nov 09 02:31:43 2020 


# I (infer_both_sex) 
 Mon Nov 09 02:33:54 2020 


# J (maybe_lower_closeout) 
 Mon Nov 09 02:35:16 2020 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Mon Nov 09 02:45:32 2020 

