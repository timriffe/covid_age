
# New build log 
 Fri Oct 16 02:00:08 2020 


# prep (resolve_UNKUNK) 
 Fri Oct 16 02:00:26 2020 


# A (convert_fractions_sexes) 
 Fri Oct 16 02:02:56 2020 


# B (redistribute_unknown_age) 
 Fri Oct 16 02:05:01 2020 


# C (rescale_to_total) 
 Fri Oct 16 02:11:46 2020 

filter( Code == 'PS03.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PS03.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'PS03.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PS03.10.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PS05.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PS05.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'PS05.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PS05.10.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PS09.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PS09.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'PS09.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PS09.10.2020', Sex == 'b', Measure == 'Deaths' )

# D (infer_cases_from_deaths_and_ascfr) 
 Fri Oct 16 02:23:51 2020 


# E (infer_deaths_from_cases_and_ascfr) 
 Fri Oct 16 02:26:20 2020 


# G (redistribute_unknown_sex) 
 Fri Oct 16 02:28:46 2020 


# H (rescale_sexes) 
 Fri Oct 16 02:30:24 2020 


# I (infer_both_sex) 
 Fri Oct 16 02:32:25 2020 


# J (maybe_lower_closeout) 
 Fri Oct 16 02:33:50 2020 

filter( Code == 'CA_QC9.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC10.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC10.04.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC11.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC12.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC12.04.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC13.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC13.04.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC14.04.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC14.04.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Fri Oct 16 02:43:42 2020 

filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'NZ01.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ02.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ03.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ04.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ05.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ06.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ07.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ08.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ09.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ11.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ18.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ19.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ30.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR03.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR07.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR14.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR21.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC24.06.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PK10.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'TR03.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR07.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR14.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR21.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ01.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ02.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ03.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ04.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ05.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ06.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ07.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ08.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ09.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ11.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ18.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ19.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ28.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ30.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'LB25.09.2023', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2024', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2025', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2026', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2027', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2028', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2029', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2030', Sex == 'b', Measure == 'Cases' )
filter( Code == 'DO17.06.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'DO18.06.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK10.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'DO16.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO17.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO18.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO19.06.2020', Sex == 'm', Measure == 'Deaths' )

# Compile metadata 
 Fri Oct 16 04:19:59 2020 


# Building dashboards 
 Fri Oct 16 04:43:10 2020 


# remake coverage map 
 Fri Oct 16 04:44:52 2020 


# push outputs to OSF 
 Fri Oct 16 04:49:19 2020 

