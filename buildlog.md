
# New build log 
 Fri Oct 30 09:12:26 2020 


# prep (resolve_UNKUNK) 
 Fri Oct 30 09:12:43 2020 


# A (convert_fractions_sexes) 
 Fri Oct 30 09:14:52 2020 


# B (redistribute_unknown_age) 
 Fri Oct 30 09:16:19 2020 


# C (rescale_to_total) 
 Fri Oct 30 09:21:53 2020 

filter( Code == 'PS19.10.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'PS19.10.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'PS19.10.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'PS19.10.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 01.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 01.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 01.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 02.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 02.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 02.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 03.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 03.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 03.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 04.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 04.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 04.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 05.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 05.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 05.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 06.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 06.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 06.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 07.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 07.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 07.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 08.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 08.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 08.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 09.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 09.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 09.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 10.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 10.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 10.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'CA_QC 11.10.20', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 11.10.20', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'CA_QC 11.10.20', Sex == 'b', Measure == 'Tests' )
filter( Code == 'PS12.10.2020', Sex == 'b', Measure == 'Cases' )

# D (infer_cases_from_deaths_and_ascfr) 
 Fri Oct 30 09:28:28 2020 


# E (infer_deaths_from_cases_and_ascfr) 
 Fri Oct 30 09:30:54 2020 


# G (redistribute_unknown_sex) 
 Fri Oct 30 09:33:21 2020 


# H (rescale_sexes) 
 Fri Oct 30 09:35:08 2020 


# I (infer_both_sex) 
 Fri Oct 30 09:36:21 2020 


# J (maybe_lower_closeout) 
 Fri Oct 30 09:37:33 2020 

filter( Code == 'US_TX10.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX11.09.2020', Sex == 'b', Measure == 'Cases' )
filter( Code == 'US_TX13.09.2020', Sex == 'b', Measure == 'Cases' )

# Age harmonization 
 Fri Oct 30 09:42:23 2020 

filter( Code == 'PK10.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK11.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK12.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK13.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK14.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK15.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK16.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PK17.03.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'PS12.10.2020', Sex == 'b', Measure == 'Deaths' )
filter( Code == 'DO16.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO17.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO18.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'DO19.06.2020', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 01.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 02.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 03.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 04.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 05.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 06.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 07.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 08.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 09.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 10.10.20', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 11.10.20', Sex == 'f', Measure == 'Cases' )
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
filter( Code == 'TR28.06.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 01.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 02.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 03.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 04.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 05.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 06.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 07.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 08.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 09.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 10.10.20', Sex == 'm', Measure == 'Deaths' )
filter( Code == 'CA_QC 11.10.20', Sex == 'm', Measure == 'Deaths' )
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
filter( Code == 'TR28.06.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR28.09.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'TR31.08.2020', Sex == 'f', Measure == 'Cases' )
filter( Code == 'CA_QC 01.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 02.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 03.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 04.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 05.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 06.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 07.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 08.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 09.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 10.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'CA_QC 11.10.20', Sex == 'm', Measure == 'Cases' )
filter( Code == 'LB25.09.2023', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2024', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2025', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2026', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2027', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2028', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2029', Sex == 'b', Measure == 'Cases' )
filter( Code == 'LB25.09.2030', Sex == 'b', Measure == 'Cases' )
filter( Code == 'CA_QC 01.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 02.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 03.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 04.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 05.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 06.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 07.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 08.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 09.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 10.10.20', Sex == 'f', Measure == 'Deaths' )
filter( Code == 'CA_QC 11.10.20', Sex == 'f', Measure == 'Deaths' )
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

# Compile metadata 
 Fri Oct 30 15:59:32 2020 


# Building dashboards 
 Fri Oct 30 16:00:18 2020 


# remake coverage map 
 Fri Oct 30 16:00:37 2020 


# push outputs to OSF 
 Fri Oct 30 16:00:38 2020 


# Commit dashboards and buildlog 
 Fri Oct 30 16:00:57 2020 


# update build series log 
 Fri Oct 30 16:01:01 2020 


# Compile metadata 
 Fri Oct 30 16:01:25 2020 


# Building dashboards 
 Fri Oct 30 16:23:16 2020 


# remake coverage map 
 Fri Oct 30 16:28:28 2020 


# push outputs to OSF 
 Fri Oct 30 16:36:16 2020 


# Commit dashboards and buildlog 
 Fri Oct 30 16:39:03 2020 

