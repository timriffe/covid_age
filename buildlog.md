
# New build log 
 Sat Oct 10 15:59:09 2020 


# prep (resolve_UNKUNK) 
 Sat Oct 10 15:59:19 2020 


# A (convert_fractions_sexes) 
 Sat Oct 10 16:01:29 2020 


# B (redistribute_unknown_age) 
 Sat Oct 10 16:02:51 2020 


# C (rescale_to_total) 
 Sat Oct 10 16:07:58 2020 


# D (infer_cases_from_deaths_and_ascfr) 
 Sat Oct 10 16:14:35 2020 


# E (infer_deaths_from_cases_and_ascfr) 
 Sat Oct 10 16:16:54 2020 


# G (redistribute_unknown_sex) 
 Sat Oct 10 16:19:13 2020 


# H (rescale_sexes) 
 Sat Oct 10 16:20:45 2020 


# I (infer_both_sex) 
 Sat Oct 10 16:22:06 2020 


# J (maybe_lower_closeout) 
 Sat Oct 10 16:23:03 2020 

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
 Sat Oct 10 16:27:46 2020 

filter( Code == 'NZ01.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ02.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ03.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ04.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ05.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ06.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ07.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ08.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ18.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ19.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'NZ30.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'SZ21.09.2020', Sex == 'm', Measure == 'Cases' )
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
filter( Code == 'SZ21.09.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'PS07.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PS08.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'SZ21.09.2020', Sex == 'f', Measure == 'Cases' )
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
filter( Code == 'SZ21.09.2020', Sex == 'f', Measure == 'Deaths' )
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
 Sat Oct 10 18:02:22 2020 


# Building dashboards 
 Sat Oct 10 18:22:29 2020 


# remake coverage map 
 Sat Oct 10 18:24:06 2020 


# push outputs to OSF 
 Sat Oct 10 18:28:31 2020 


# Commit dashboards and buildlog 
 Sat Oct 10 18:29:36 2020 


# update build series log 
 Sat Oct 10 18:29:47 2020 

