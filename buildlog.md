
# New build log 
 Sun Oct 11 09:24:24 2020 


# prep (resolve_UNKUNK) 
 Sun Oct 11 09:24:36 2020 


# A (convert_fractions_sexes) 
 Sun Oct 11 09:26:40 2020 


# B (redistribute_unknown_age) 
 Sun Oct 11 09:28:05 2020 


# C (rescale_to_total) 
 Sun Oct 11 09:33:11 2020 

filter( Code == 'PS10.10.2020', Sex == 'b', Measure == 'Cases' )

# D (infer_cases_from_deaths_and_ascfr) 
 Sun Oct 11 09:39:42 2020 


# E (infer_deaths_from_cases_and_ascfr) 
 Sun Oct 11 09:42:02 2020 


# G (redistribute_unknown_sex) 
 Sun Oct 11 09:44:19 2020 


# H (rescale_sexes) 
 Sun Oct 11 09:45:50 2020 


# I (infer_both_sex) 
 Sun Oct 11 09:47:14 2020 


# J (maybe_lower_closeout) 
 Sun Oct 11 09:48:10 2020 

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
 Sun Oct 11 09:52:47 2020 

filter( Code == 'NZ01.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ02.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ03.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ04.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ05.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ06.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ07.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ08.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ09.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ18.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ19.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ30.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR03.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC24.06.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PK10.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PS08.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'TR03.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR05.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR10.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR12.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR17.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR19.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR24.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR26.07.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.06.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ01.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ02.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ03.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ04.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ05.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ06.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ07.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ08.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'NZ09.10.2020', Sex == 'm', Measure == 'Cases' )
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
filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )

# Compile metadata 
 Sun Oct 11 11:27:56 2020 


# Building dashboards 
 Sun Oct 11 11:45:41 2020 


# remake coverage map 
 Sun Oct 11 11:47:28 2020 


# push outputs to OSF 
 Sun Oct 11 11:51:57 2020 


# Commit dashboards and buildlog 
 Sun Oct 11 11:53:02 2020 


# update build series log 
 Sun Oct 11 11:53:11 2020 

