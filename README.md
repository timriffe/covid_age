# COVID-19 Dashboard Source Data

This documentation is also available at `https://www.covid19.admin.ch/api/data/documentation` including detailed html versions of the model documentation.

## Data
Check the `data` folder for the data source files.

### Files
| File                                                                        | Model                                                                          | Description                                                                                                                                                                                                        |
|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| COVID19Cases_geoRegion.(json/csv)                                           | DailyIncomingData                                                              | Daily record timelines by geoRegion for cases.                                                                                                                                                                     |
| *DEPRECATED* COVID19Cases_vaccpersons.(json/csv)                            | DailyCasesVaccPersonsIncomingData                                              | Daily record timelines for cases of fully vaccinated persons by vaccine. Data only available for geoRegion CHFL. This file has been deprecated and will no longer be updated after 11.11.2021.                     |
| COVID19Hosp_geoRegion.(json/csv)                                            | DailyIncomingData                                                              | Daily record timelines by geoRegion for hospitalisations.                                                                                                                                                          |
| COVID19Hosp_vaccpersons.(json/csv)                                          | DailyHospVaccPersonsIncomingData                                               | Daily record timelines for hospitalisations of fully vaccinated persons by vaccine. Data only available for geoRegion CHFL.                                                                                        |
| COVID19Death_geoRegion.(json/csv)                                           | DailyIncomingData                                                              | Daily record timelines by geoRegion for deaths.                                                                                                                                                                    |
| COVID19Death_vaccpersons.(json/csv)                                         | DailyDeathVaccPersonsIncomingData                                              | Daily record timelines for deaths of fully vaccinated persons by vaccine. Data only available for geoRegion CHFL.                                                                                                  |
| COVID19Test_geoRegion_all.(json/csv)                                        | DailyIncomingData                                                              | Daily record timelines by geoRegion for tests (all test types).                                                                                                                                                    |
| COVID19Test_geoRegion_PCR_Antigen.(json/csv)                                | DailyIncomingData                                                              | Daily record timelines by geoRegion and test type (pcr/antigen) for tests.                                                                                                                                         |
| COVID19Cases_geoRegion_w.(json/csv)                                         | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion for cases.                                                                                                                                                                  |
| COVID19Hosp_geoRegion_w.(json/csv)                                          | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion for hospitalisations.                                                                                                                                                       |
| COVID19Death_geoRegion_w.(json/csv)                                         | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion for deaths.                                                                                                                                                                 |
| COVID19Test_geoRegion_w.(json/csv)                                          | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion for tests.                                                                                                                                                                  |
| COVID19Test_geoRegion_PCR_Antigen_w.(json/csv)                              | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and test type (pcr/antigen) for tests.                                                                                                                                      |
| COVID19Cases_geoRegion_AKL10_w.(json/csv)                                   | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and age brackets for cases.                                                                                                                                                 |
| *DEPRECATED* COVID19Cases_vaccpersons_AKL10_w.(json/csv)                    | WeeklyCasesVaccPersonsAgeRangeIncomingData                                     | Iso-Week record timelines for cases of fully vaccinated persons by vaccine and age brackets. Data only available for geoRegion CHFL. This file has been deprecated and will no longer be updated after 11.11.2021. |
| COVID19Hosp_geoRegion_AKL10_w.(json/csv)                                    | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and age brackets for hospitalisations.                                                                                                                                      |
| COVID19Hosp_vaccpersons_AKL10_w.(json/csv)                                  | WeeklyHospVaccPersonsAgeRangeIncomingData                                      | Iso-Week record timelines for hospitalisations of fully vaccinated persons by vaccine and age brackets. Data only available for geoRegion CHFL.                                                                    |
| COVID19Death_geoRegion_AKL10_w.(json/csv)                                   | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and age brackets for deaths.                                                                                                                                                |
| COVID19Death_vaccpersons_AKL10_w.(json/csv)                                 | WeeklyDeathVaccPersonsAgeRangeIncomingData                                     | Iso-Week record timelines for deaths of fully vaccinated persons by vaccine and age brackets. Data only available for geoRegion CHFL.                                                                              |
| COVID19Test_geoRegion_AKL10_w.(json/csv)                                    | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and age brackets for tests (all test types).                                                                                                                                |
| COVID19Cases_geoRegion_sex_w.(json/csv)                                     | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and sex for cases.                                                                                                                                                          |
| *DEPRECATED* COVID19Cases_vaccpersons_sex_w.(json/csv)                      | WeeklyCasesVaccPersonsSexIncomingData                                          | Iso-Week record timelines for cases of fully vaccinated persons by vaccine and sex. Data only available for geoRegion CHFL. This file has been deprecated and will no longer be updated after 11.11.2021.          |
| COVID19Hosp_geoRegion_sex_w.(json/csv)                                      | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and sex for hospitalisations.                                                                                                                                               |
| COVID19Hosp_reason_AKL10_w.(json/csv)                                       | WeeklyHospReasonIncomingData                                                   | Iso-Week record timelines for hospitalisations by geoRegion, age brackets and primary hospitalisation reason.                                                                                                      |
| COVID19Hosp_vaccpersons_sex_w.(json/csv)                                    | WeeklyHospVaccPersonsSexIncomingData                                           | Iso-Week record timelines for hospitalisations of fully vaccinated persons by vaccine and sex. Data only available for geoRegion CHFL.                                                                             |
| COVID19Death_geoRegion_sex_w.(json/csv)                                     | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and sex for deaths.                                                                                                                                                         |
| COVID19Death_vaccpersons_sex_w.(json/csv)                                   | WeeklyDeathVaccPersonsSexIncomingData                                          | Iso-Week record timelines for deaths of fully vaccinated persons by vaccine and sex. Data only available for geoRegion CHFL.                                                                                       |
| COVID19Test_geoRegion_sex_w.(json/csv)                                      | WeeklyIncomingData                                                             | Iso-Week record timelines by geoRegion and sex for tests (all test types).                                                                                                                                         |
| COVID19Cases_extraGeoRegions_d.(json/csv)                                   | AdditionalGeoRegionDailyIncomingData                                           | Daily record timelines by (additonal) geographical units for cases. Contains data for CH, cantons, greater regions & greater labor market regions.                                                                 |
| COVID19Cases_extraGeoRegions_14d.(json/csv)                                 | AdditionalGeoRegion14dPeriodIncomingData                                       | 14d aggregated record timelines by (additional) geographical units for cases. Contains data for CH, labor market regions & districts.                                                                              |
| COVID19WeeklyReportText.(json/csv)                                          | WeeklyReportIncomingData                                                       | Weekly report texts by Iso-Week.                                                                                                                                                                                   |
| *DEPRECATED* COVID19EvalTextDaily.(json/csv)                                | DailyReportIncomingData                                                        | Optional extra texts for daily report (PDF). This file has been deprecated and will no longer be updated after 05.04.2022.                                                                                         |
| *DEPRECATED* COVID19QuarantineIsolation_geoRegion_d.(json/csv)              | ContactTracingIncomingData                                                     | Contact tracing data (current record by geoRegion where available). This file has been deprecated and will no longer be updated after 05.04.2022.                                                                  |
| COVID19HospCapacity_geoRegion.(json/csv)                                    | HospCapacityDailyIncomingData                                                  | Daily hospital capacity data timelines by geoRegion.                                                                                                                                                               |
| COVID19HospCapacity_geoRegion_certStatus.(json/csv)                         | HospCapacityCertStatusIncomingData                                             | Daily hospital capacity data timelines of certified/ad-hoc status of operational ICU beds by geoRegion.                                                                                                            |
| COVID19HospCapacity_geoRegion_w.(json/csv)                                  | HospCapacityWeeklyIncomingData                                                 | Weekly hospital capacity data timelines by geoRegion.                                                                                                                                                              |
| *DEPRECATED* COVID19IntQua.(json/csv)                                       | InternationalQuarantineIncomingData                                            | International quarantine data (mandatory quarantine requirement when entering Switzerland). This file has been deprecated and will no longer be updated after 05.04.2022.                                          |
| *DEPRECATED* COVID19IntCases.(json/csv)                                     | InternationalDailyIncomingData                                                 | International daily data (cases). This file has been deprecated and will no longer be updated after 05.04.2022.                                                                                                    |
| *DEPRECATED* COVID19Re_geoRegion.(json/csv)                                 | ReDailyIncomingData                                                            | Daily R<sub>e</sub> value data timelines by geoRegion. This file has been deprecated and will no longer be updated after 05.04.2022.                                                                               |
| *DEPRECATED* COVID19VaccDosesDelivered.(json/csv)                           | VaccinationIncomingData                                                        | Vaccine doses delivered/received data by geoRegion. This file has been deprecated and will no longer be updated after 26.04.2022.                                                                                  |
| *DEPRECATED* COVID19VaccDosesDelivered_vaccine.(json/csv)                   | VaccinationDosesReceivedDeliveredVaccineIncomingData                           | Vaccine doses delivered/received data by geoRegion and vaccine (type). This file has been deprecated and will no longer be updated after 26.04.2022.                                                               |
| COVID19VaccDosesAdministered.(json/csv)                                     | VaccinationIncomingData                                                        | Vaccine doses administered data by geoRegion.                                                                                                                                                                      |
| COVID19AdministeredDoses_vaccine.(json/csv)                                 | VaccinationVaccineIncomingData                                                 | Vaccine doses administered data by geoRegion and vaccine (type).                                                                                                                                                   |
| COVID19VaccPersons_v2.(json/csv)                                            | VaccPersonsIncomingData                                                        | Vaccinated persons data by geoRegion (aggregated by canton/country of residence).                                                                                                                                  |
| COVID19VaccPersons_vaccine.(json/csv)                                       | VaccPersonsVaccineIncomingData                                                 | Vaccinated persons data by geoRegion (aggregated by canton/country of residence) and vaccine (type).                                                                                                               |
| COVID19VaccDosesAdministered_AKL10_w.(json/csv)                             | VaccinationWeeklyIncomingData                                                  | Iso-Week record timelines by geoRegion and age brackets for vaccine doses administered.                                                                                                                            |
| COVID19VaccPersons_AKL10_w_v2.(json/csv)                                    | VaccPersonsWeeklyIncomingData                                                  | Iso-Week record timelines by geoRegion (aggregated by canton/country of residence) and age brackets for vaccinated persons.                                                                                        |
| COVID19VaccPersons_AKL10_vaccine_w.(json/csv)                               | VaccPersonsWeeklyAgeRangeVaccineIncomingData                                   | Iso-Week record timelines by geoRegion (aggregated by canton/country of residence), age brackets and vaccine for vaccinated persons.                                                                               |
| COVID19VaccDosesAdministered_sex_w.(json/csv) VaccinationWeeklyIncomingData | Iso-Week record timelines by geoRegion and sex for vaccine doses administered. |
| COVID19VaccPersons_sex_w_v2.(json/csv)                                      | VaccPersonsWeeklyIncomingData                                                  | Iso-Week record timelines by geoRegion (aggregated by canton/country of residence) and sex for vaccinated persons.                                                                                                 |
| COVID19FullyVaccPersons_indication_w_v2.(json/csv)                          | VaccPersonsWeeklyIndicationIncomingData                                        | Iso-Week record timelines by geoRegion (aggregated by canton/country of residence) and vacc indication (reason) for fully vaccinated persons.                                                                      |
| COVID19VaccDosesAdministered_indication_w.(json/csv)                        | VaccinationWeeklyIndicationIncomingData                                        | Iso-Week record timelines by geoRegion and vacc indication (reason) for vaccine doses administered.                                                                                                                |
| *DEPRECATED* COVID19VaccDosesAdministered_location_w.(json/csv)             | VaccinationWeeklyLocationIncomingData                                          | Iso-Week record timelines by geoRegion and location for vaccine doses administered. This file has been deprecated and will no longer be updated after 26.04.2022.                                                  |
| *DEPRECATED* COVID19VaccSymptoms.(json/csv)                                 | VaccinationSymptomsIncomingData                                                | Data for suspected cases of adverse vaccination reactions based on reports from Swissmedic. This file has been deprecated and will no longer be updated after 26.04.2022.                                          |
| *DEPRECATED* COVID19VaccDosesContingent.(json/csv)                          | VaccinationContingentIncomingData                                              | Allotted vaccination doses contingent data by geoRegion. This file has been deprecated and will no longer be updated after 10.03.2022.                                                                             |
| COVID19Variants_wgs.(json/csv)                                              | VirusVariantsWgsDailyIncomingData                                              | Virus variant data by geoRegion (source WGS & MSys).                                                                                                                                                               |
| *DEPRECATED* COVID19Certificates.(json/csv)                                 | CovidCertificatesDailyIncomingData                                             | Issued COVID certificates data. This file has been deprecated and will no longer be updated after 08.03.2022.                                                                                                      |
| COVID19EpiRawData_d.(json/csv)                                              | DailyEpiRawIncomingData                                                        | Combined daily record timelines for cases, hosp & death by geoRegion. Minimal content without pre-calculated values.                                                                                               |
| COVID19CasesRawData_AKL10_d.(json/csv)                                      | DailyCasesAgeRangeRawIncomingData                                              | Daily record timelines for cases by geoRegion and age brackets. Minimal content without pre-calculated values.                                                                                                     |
| COVID19EpiRawData_AKL10_sex_w.(json/csv)                                    | WeeklyEpiAgeRangeSexRawIncomingData                                            | Combined Iso-Week record timelines for cases, hosp & deaths by geoRegion, age brackets and sex. Minimal content without pre-calculated values.                                                                     |
| PopulationAgeRangeSexData.(json/csv)                                        | PopulationAgeRangeSexData                                                      | Population data by geoRegion (cantons + FL), age brackets & sex.                                                                                                                                                   |
| COVID19Wastewater_vl.(json/csv)                                             | WasteWaterDailyViralLoadData                                                   | Daily waste water viral load measurement record timelines by waste water treatment facility.                                                                                                                       |
| COVID19Wastewater_vlOverview.(json/csv)                                     | WasteWaterViralLoadOverview                                                    | Overview of the current percentile & difference to previous week of the waste water facilities by geoRegion (cantons, FL, CH & CHFL).                                                                              |

## Schema
Check the `sources.schema.json` file for schema information (only json-schema format for now).

Please note that the data schema can change in the future and be released in a new version. Changes will be tracked here and the current schema version can be read from the data context (see section Download Automation below).

### Upcoming Releases

There are currently no planned releases.

### Releases

### v.0.25.0
**Released**: `27.09.2022`
**Description**:
- added `data_expected`property to the `COVID19Wastewater_vl.(json/csv)` file to mark if data was expected (facility was participating in the waste water surveillance project)
- added records for new waste water facilites to the `COVID19Wastewater_vl.(json/csv)` file (extended `geoRegions` property)
    - `366101` Cazis (Waldau)
    - `387101` Klosters (Gulfia)
    - `395501` Landquart
    - `356101` Poschiavo (Li Geri)
    - `358201` Schluein (Gruob)
    - `376201` Scuol (Sot Ruinas)
    - `397201` Seewis (Vorderes Prättigau)
    - `603102` Bagnes-Le Châble
    - `600200` Brig-Glis (Briglina)
    - `605700` Goms
    - `613600` Martigny
    - `624801` Sierre/Noes
    - `626601` Sion/Chateauneuf
    - `630000` Zermatt
    - `100000` Liechtenstein
- remove data records for the waste water facility `40100` (Burgdorf) from the `COVID19Wastewater_vl.(json/csv)` file because of flawed sampling. record will be added back when enough data has been collected again.
- added records for vaccine `moderna_bivalent` to `COVID19AdministeredDoses_vaccine.csv`, `COVID19VaccPersons_vaccine.csv` and `COVID19VaccPersons_AKL10_vaccine_w.csv`

### v.0.24.1
**Released**: `09.08.2022`
**Description**:
- added records for persons that received a second booster (type = `COVID19SecondBoosterPersons`) to the following files: `COVID19VaccPersons_v2.(json/csv)`, `COVID19VaccPersons_vaccine.(json/csv)`, `COVID19VaccPersons_AKL10_w_v2.(json/csv)`, `COVID19VaccPersons_sex_w_v2.(json/csv)` and `COVID19VaccPersons_AKL10_vaccine_w.(json/csv)`

### v.0.24.0
**Released**: `05.07.2022`
**Description**:
#### waste water viral load data
- added file `COVID19Wastewater_vl.(json/csv)` containing daily viral load record timelines by wate water facility. model: `WasteWaterDailyViralLoadData`
- added file `COVID19Wastewater_vlOverview.(json/csv)` containing  viral load overview data by geoRegion (cantons, FL, CH & CHFL). model: `WasteWaterViralLoadOverviewation`
#### hosp/death by vacc status
- extended `COVID19Hosp_vaccpersons_AKL10_w.(json/csv)` and `COVID19Death_vaccpersons_AKL10_w` files with records for age groups by vacc strategy. the added `age_group_type`property with possible values of `age_group_AKL10` and `age_group_vacc_strategy` gives further information as to which age group type a record belongs to.
#### virus variants
- removed records from the mandatory declaration system (`data_source` = `msys`) from the `COVID19Variants_wgs` file

### v.0.23.0
**Released**: `26.04.2022`
**Description**:
- the file `COVID19VaccDosesDelivered.(json/csv)` has become deprecated and will no longer be updated after 26.04.2022.
- the file `COVID19VaccDosesDelivered_vaccine.(json/csv)` has become deprecated and will no longer be updated after 26.04.2022.
- the file `COVID19VaccDosesAdministered_location_w.(json/csv)` has become deprecated and will no longer be updated after 26.04.2022.
- the file `COVID19VaccSymptoms.(json/csv)` has become deprecated and will no longer be updated after 26.04.2022. please refer to the website of swissmedic (https://www.swissmedic.ch/covid-19-vaccines-safety-update) in the future for information about adverse reactions to COVID-19 vaccines

### v.0.22.0
**Released**: `05.04.2022`
**Description**:
- the data publication schedule has been changed to once a week (currently every tuesday at 15:30), added `nextScheduledPublication` property to the data context
- the file `COVID19Re_geoRegion.(json/csv)` has become deprecated and will no longer be updated after 05.04.2022.
- the file `COVID19QuarantineIsolation_geoRegion_d.(json/csv)` has become deprecated and will no longer be updated after 05.04.2022.
- the file `COVID19EvalTextDaily.(json/csv)` has become deprecated and will no longer be updated after 05.04.2022.
- the file `COVID19IntQua.(json/csv)` has become deprecated and will no longer be updated after 05.04.2022.
- the file `COVID19IntCases.(json/csv)` has become deprecated and will no longer be updated after 05.04.2022.
- added records for vaccine `novavax` to `COVID19VaccDosesDelivered_vaccine.(json/csv)`, `COVID19AdministeredDoses_vaccine.csv`, `COVID19VaccPersons_vaccine.csv` and `COVID19VaccPersons_AKL10_vaccine_w.csv`

### v.0.21.1
**Released**: `10.03.2022`
**Description**:
- added new timeframe phase 6 starting from 20.12.2021
- added properties `offset_Phase6`, `sumTotal_Phase6`, `inzsumTotal_Phase6`, `anteil_pos_phase6` and `timeframe_phase6` to `DailyIncomingData` model
- added properties `timeframe_phase6` to `WeeklyIncomingData` model
- added property `timeframe_phase6` to `ReDailyIncomingData` model
- added property `timeframe_phase6` to `InternationalDailyIncomingData` model
- the file `COVID19VaccDosesContingent.(json/csv)` has become DEPRECATED and will not be updated anymore after 10.03.2021
- the file `COVID19Certificates.(json/csv)` has become DEPRECATED and will not be updated anymore after 08.03.2022

### v.0.21.0
**Released**: `15.02.2021`
**Description**:
- added file `COVID19EpiRawData_d` containing combined daily record timelines for cases, hosp & death by geoRegion.
- added file `COVID19CasesRawData_AKL10_d` containing daily record timelines for cases by geoRegion and age brackets.
- added file `COVID19EpiRawData_AKL10_sex_w` containing weekly record timelines for cases, hosp & death by geoRegion, age brackets and sex.
- added file `PopulationAgeRangeSexData` containing population data by geoRegion (cantons + FL), age brackets  & sex.
- these files only contain minimal data (population or daily/weekly absolute values) without any other pre-calculated values and are intended as a lightweight alternative data source for custom calculations/analysis/research. These new files (along with the previously published files) also replace the legacy files published on the BAG/OFSP/UFSP/FOPH website

### v.0.20.0
**Released**: `'03.02.2022`
**Description**:
- added new weekly source file for hospitalisation by hosp reason: `COVID19Hosp_reason_AKL10_w.(json/csv)`
- added model `WeeklyHospReasonIncomingData`
- added new source file for hosp capacity data regarding the operational ICU beds by certified/adhoc status: `COVID19HospCapacity_geoRegion_certStatus.(json/csv)`.
- added model `HospCapacityCertStatusIncomingData`
- 
### v.0.19.1
**Released**: `01.02.2022`
**Description**:
- due to the expected reporting delay, the values of the following derived properties have been suppressed for the latest 5 complete days: `sum7d`, `sum14d`, `inzsum7d`, `inzsum14d`. This affects the following files: `COVID19Cases_geoRegion.(json/csv)`, `COVID19Hosp_geoRegion.(json/csv)` and `COVID19Death_geoRegion.(json/csv)`.

### v.0.19.0
**Released**: `20.01.2022`
**Description**:
- added new text blocks to weekly report text data file `COVID19WeeklyReportText.(json/csv)` with the following identifiers: `hospcapacityicu-summary`, `methods-cases_hosps_deaths_tests`, `methods-deadline`, `methods-contact_tracing`, `methods-hospcapacityicu`, `methods-trends`
- updated model `WeeklyReportIncomingData`
- added new source file for weekly hosp capacity data: `COVID19HospCapacity_geoRegion_w.(json/csv)`. only the data for geoRegion `CH` and type_variant `fp7d` are included currently.
- added model `HospCapacityWeeklyIncomingData`

### v.0.18.4
**Released**: `14.01.2022`
**Description**:
- extended hosp & death data by vaccination status with records for vaccination status `fully_vaccinated` and vaccine `unknown`. this affects the following files: `COVID19Hosp_vaccpersons.(json/csv)` and `COVID19Death_vaccpersons.(json/csv)`
- extended hosp & death data by vaccination status with records for the newly added vaccination_status of `fully_vaccinated_no_booster` and `fully_vaccinated_first_booster` which are a more detailed subdivision of the records with vaccination_status `fully_vaccinated`. the records with vaccination_status `fully_vaccinated` will continue to be published as they have been until now. this affects all `*_vaccpersons.(json/csv)`files but will only be added for records with vaccine `all`.
- data_completeness of hosp & death for fully vaccinated persons with first booster (`fully_vaccinated_first_booster`) is `insufficient` before 01.12.2021 for inz_entries and inzmean7d
- updated models `DailyHospVaccPersonsIncomingData`, `WeeklyHospVaccPersonsAgeRangeIncomingData`, `WeeklyHospVaccPersonsSexIncomingData`, `DailyDeathVaccPersonsIncomingData`, `WeeklyDeathVaccPersonsAgeRangeIncomingData` and `WeeklyDeathVaccPersonsSexIncomingData`

### v.0.18.3
**Released**: `23.12.2021`
**Description**:
- extended weekly vaccination records by age range with the new age group by vaccination strategy `5 - 11`. this affects the weekly administered doses and vaccinated persons files by age `COVID19VaccDosesAdministered_AKL10_w.(json/csv)` and `COVID19VaccPersons_AKL10_w_v2.(json/csv)`
- updated models `VaccinationWeeklyIncomingData` and `VaccPersonsWeeklyIncomingData`

### v.0.18.2
**Released**: `16.12.2021`
**Description**:
- added data for the current (incomplete) week to the `COVID19VaccPersons_AKL10_w_v2` file in order to provide more up-to-date information on the vaccination progress for the different age groups. the `entries` and `per100Persons` values will remain empty until the week is complete but the `sumTotal` and `per100PersonsTotal` values will be available.

### v.0.18.1
**Released**: `07.12.2021`
**Description**:
- added new virus variant `B.1.1.529`: [VirusVariantsWgsDailyIncomingData](/api/data/documentation/models/sources-definitions-virusvariantswgsdailyincomingdata.md#variant_type)

### v.0.18.0
**Released**: `02.12.2021`
**Description**:
- added records for person having recieved the first booster to the vacc person files `COVID19VaccPersons_v2`, `COVID19VaccPersons_vaccine`, `COVID19VaccPersons_AKL10_w_v2`, `COVID19VaccPersons_AKL10_vaccine_w` and `COVID19VaccPersons_sex_w_v2`
- updated models `VaccPersonsIncomingData`, `VaccPersonsVaccineIncomingData`, `VaccPersonsWeeklyIncomingData` and `VaccPersonsWeeklyAgeRangeVaccineIncomingData` extending the `type` property with the value `COVID19FirstBoosterPersons`
- the records for persons having received the first booster (type = `COVID19FirstBoosterPersons`) are a subset of the fully vaccinated person records (type = `COVID19FullyVaccPersons`)
- added new timeframe phase 5 starting from 11.10.2021
- added properties `offset_Phase5`, `sumTotal_Phase5`, `inzsumTotal_Phase5`, `anteil_pos_phase5` and `timeframe_phase5` to `DailyIncomingData` model
- added properties `timeframe_phase5` to  `WeeklyIncomingData` model
- added property `timeframe_phase5` to `ReDailyIncomingData` model
- added property `timeframe_phase5` to `InternationalDailyIncomingData` model

### v.0.17.4
**Released**: `18.11.2021`
**Description**:
- the `timeframe_all` property has been added to the weekly files for hosp & death records by vaccination status (`COVID19Hosp_vaccpersons_AKL10_w`, `COVID19Death_vaccpersons_AKL10_w`, `COVID19Hosp_vaccpersons_sex_w` and `COVID19Death_vaccpersons_sex_w`) in order to mark the weekly records data as complete enough for visualisation

### v.0.17.3
**Released**: `11.11.2021`
**Description**:
- the files for laboratory-confirmed cases by vaccination status (`COVID19Cases_vaccpersons`, `COVID19Cases_vaccpersons_AKL10_w` and `COVID19Cases_vaccpersons_sex_w`) have become DEPRECATED and will no longer be updated after 11.11.2021
- the reporting obligation for the vaccination status for outpatients was lifted on 01.10.2021. This was done because vaccinated people with no or only mild symptoms are less likely to consult a physician or be tested in test centres or pharmacies. Only physicians are obliged to file a clinical report. As a result the number of laboratory-confirmed cases despite vaccination are not representative. Furthermore, surveillance of the vaccination status is in particular of importance for cases with a severe course of disease. Therefore physicians and hospitals are only required to report the vaccination status for hosp and death. The files for hospitalisations and deaths by vaccination status will continue to be updated (`COVID19Hosp_vaccpersons`, `COVID19Death_vaccpersons`, `COVID19Hosp_vaccpersons_AKL10_w`, `COVID19Death_vaccpersons_AKL10_w`, `COVID19Hosp_vaccpersons_sex_w` and `COVID19Death_vaccpersons_sex_w`)
- added records for the Armee Apotheke (geoRegion=AA) to the delivered and administered doses files (`COVID19VaccDosesDelivered` and `COVID19VaccDosesAdministered`) and extended model `VaccinationIncomingData`. no changes to the vacc person files since the grouping is by canton of residence.

### v.0.17.2
**Released**: `28.10.2021`
**Description**:
- removed deprecated file `COVID19FullyVaccPersons_vaccine_v2`
- added a new file for vacc persons by age range AND vaccine: `COVID19VaccPersons_AKL10_vaccine_w` (model `VaccPersonsWeeklyAgeRangeVaccineIncomingData`)

### v.0.17.1
**Released**: `19.10.2021`
**Description**:
- added daily records for age group 12+ to the vacc persons file `COVID19VaccPersons_v2`
- added property `age_group` with values `total_population` and `12+` in order to distinguish between the two record sets to the `VaccPersonsIncomingData` model
- added properties `ICU_exists` and `Total_exists` to the hosp capacity file `COVID19HospCapacity_geoRegion` to explicitly mark if an ICU or hospital exists for the respective geoRegion.

### v.0.17.0
**Released**: `07.10.2021`
**Description**:
#### cases, hosp & death data by vaccination status
- the current data files for cases, hosp & death of fully vaccinated persons have been extended with a new `vaccination_status` property for the breakdown by vaccination status (`fully_vaccinated`, `partially_vaccinated`, `not_vaccinated` and `unknown`) in order to make the complete distribution of cases, hosp & deaths by vaccination status available
- the current condition that only cases, hosp & deaths of fully vaccinated persons 14 days after the final dose are counted for `fully_vaccinated` persons has been lifted. this is done to avoid an under-estimate of cases of fully vaccinated persons (and in turn an over-estimate of cases for partially vaccinated persons) because the date of the final administered dose is often not available when cases are reported. this also makes the categories of fully and partially vaccinated more consistent and comparable with the existing vaccination data published. The records with `vaccination_status` of `fully_vaccinated` include occurences of fully vaccinated persons immediately after the final dose and are thus not directly comparable to the data published up to this point.
- data for individual vaccines (`moderna`, `pfizer_biontech` & `johnson_johnson`) has been added to the daily files (`COVID19Cases_vaccpersons`, `COVID19Hosp_vaccpersons` and  `COVID19Death_vaccpersons`)
- the following properties have been added to the daily files (`COVID19Cases_vaccpersons`, `COVID19Hosp_vaccpersons` and  `COVID19Death_vaccpersons`):  `pop`, `inz_entries`, `inzsumTotal`, `mean7d`, `inzmean7d`, `prct`, `prct_mean7d`, `prctSumTotal` and `vaccination_status`
- the following properties have been added to the weekly files (`COVID19Cases_vaccpersons_AKL10_w`, `COVID19Hosp_vaccpersons_AKL10_w`, `COVID19Death_vaccpersons_AKL10_w`, `COVID19Cases_vaccpersons_sex_w`, `COVID19Hosp_vaccpersons_sex_w` and `COVID19Death_vaccpersons_sex_w`) :  `pop`, `inz_entries`, `inzsumTotal`, and  `vaccination_status`
- deprecated file `COVID19FullyVaccPersons_vaccine_v2` (will be removed after 21.10.2021), please switch to the new file `COVID19VaccPersons_vaccine`
- added new file `COVID19VaccPersons_vaccine` which replaces the now deprecated file `COVID19FullyVaccPersons_vaccine_v2` and contains records for both partially and fully vaccinated persons as well as persons with at least one dose.
- added mock data for `COVID19Cases_vaccpersons`, `COVID19Cases_vaccpersons_AKL10_w` and `COVID19Cases_vaccpersons_sex_w`: check online documentation: `https://www.covid19.admin.ch/api/data/documentation#v0170`
- added mock data for `COVID19Hosp_vaccpersons`, `COVID19Hosp_vaccpersons_AKL10_w` and `COVID19Hosp_vaccpersons_sex_w`: check online documentation: `https://www.covid19.admin.ch/api/data/documentation#v0170`
- added mock data for `COVID19Death_vaccpersons`, `COVID19Death_vaccpersons_AKL10_w` and `COVID19Death_vaccpersons_sex_w`: check online documentation: `https://www.covid19.admin.ch/api/data/documentation#v0170`

### v.0.16.4
**Released**: `05.10.2021`
**Description**:
- added new records for vaccine `johnson_johnson` to the following files: `COVID19VaccDosesDelivered_vaccine`, `COVID19AdministeredDoses_vaccine`, `COVID19FullyVaccPersons_vaccine_v2` and `COVID19VaccSymptoms`
- updated models: `VaccinationDosesReceivedDeliveredVaccineIncomingData`, `VaccinationVaccineIncomingData`, `VaccPersonsVaccineIncomingData` and `VaccinationSymptomsIncomingData`

### v.0.16.3
**Released**: `24.09.2021`
**Description**:
- added new records for age groups by vaccination strategy (`12 - 15`, `16 - 64` and `65+`) and an additional property `age_group_type` to distinguish the age groups types to the weekly administered doses and vaccinated persons files by age `COVID19VaccDosesAdministered_AKL10_w.(json/csv)` and `COVID19VaccPersons_AKL10_w_v2.(json/csv)`
- updated models: `VaccinationWeeklyIncomingData` and `VaccPersonsWeeklyIncomingData`

### v.0.16.2
**Released**: `13.09.2021`
**Description**:
- added new timeframe phase 4 starting from 21.06.2021 to daily and weekly models

### v.0.16.1
**Released**: `20.08.2021`
**Description**:
- added new timeframe and totals to daily and weekly models for comparison of all cases, hosp & death records with vaccination breakthrough data (added in release v.0.16.0)
- added properties `timeframe_vacc_info`, `sumTotal_vacc_info` and `offset_vacc_info` to `DailyIncomingData`
- added properties `timeframe_vacc_info`, `sumTotal_vacc_info` and `offset_vacc_info` to `WeeklyIncomingData`
- added new virus variants `C.37` & `B.1.1.318` and updated the virus variant `B.1.617.2` records to also include the `AY.1-AY.12` variants (delta variant family): model: `VirusVariantsWgsDailyIncomingData`

### v.0.16.0
**Released**: `05.08.2021`
**Description**:
#### cases, hosp & death data of fully vaccinated persons
- added new source files for cases of fully vaccinated persons: `COVID19Cases_vaccpersons.(json/csv)` (model `DailyCasesVaccPersonsIncomingData`), `COVID19Cases_vaccpersons_AKL10_w.(json/csv)` (model `WeeklyCasesVaccPersonsAgeRangeIncomingData`) and `COVID19Cases_vaccpersons_sex_w.(json/csv)` (model `WeeklyCasesVaccPersonsSexIncomingData`)
- added new source files for hospitalisations of fully vaccinated persons: `COVID19Hosp_vaccpersons.(json/csv)` (model `DailyHospVaccPersonsIncomingData`), `COVID19Hosp_vaccpersons_AKL10_w.(json/csv)` (model `WeeklyHospVaccPersonsAgeRangeIncomingData`) and `COVID19Hosp_vaccpersons_sex_w.(json/csv)` (model `WeeklyHospVaccPersonsSexIncomingData`)
- added new source files for deaths of fully vaccinated persons: `COVID19Death_vaccpersons.(json/csv)` (model `DailyDeathVaccPersonsIncomingData`), `COVID19Death_vaccpersons_AKL10_w.(json/csv)` (model `WeeklyDeathVaccPersonsAgeRangeIncomingData`) and `COVID19Death_vaccpersons_sex_w.(json/csv)` (model `WeeklyDeathVaccPersonsSexIncomingData`)
- added mock data for `COVID19Cases_vaccpersons`, `COVID19Cases_vaccpersons_AKL10_w` and `COVID19Cases_vaccpersons_sex_w`. check online documentation to download data: `https://www.covid19.admin.ch/api/data/documentation#v0160`
- added mock data for `COVID19Hosp_vaccpersons`, `COVID19Hosp_vaccpersons_AKL10_w` and `COVID19Hosp_vaccpersons_sex_w`. check online documentation to download data: `https://www.covid19.admin.ch/api/data/documentation#v0160`
- added mock data for `COVID19Death_vaccpersons`, `COVID19Death_vaccpersons_AKL10_w` and `COVID19Death_vaccpersons_sex_w`. check online documentation to download data: `https://www.covid19.admin.ch/api/data/documentation#v0160`
- the data is incomplete because the reporting process is still being established and should be interpreted with caution. Consult the 'data_completeness' property for the current estimate of the completeness of the data.
- until the data completeness has improved, only the data for all vaccines combined will be published
- data is only available for geoRegion CHFL
#### difference to previous day
- only the data of the last 28d will be considered to calculate the difference to the previous day so it better reflects the current epidemiologic situation (changes to older data due to late reporting or data quality improvements efforts will not have any influence any more)
- updated the `entries_diff_last` property of the `DailyIncomingData` model accordingly
#### cleanup
- removed source files deprecated by the v.0.14.0 release

### v.0.15.0
**Released**: `27.07.2021`
**Description**:
- added new source file `COVID19VaccDosesDelivered_vaccine.(json/csv)` contains data by vaccine for both received (`COVID19VaccDosesReceived`) and delivered (`COVID19VaccDosesDelivered`) vaccination doses
- added model `VaccinationDosesReceivedDeliveredVaccineIncomingData`
- added mock data for `COVID19VaccDosesDelivered_vaccine`, check online documentation: `https://www.covid19.admin.ch/api/data/documentation#v0150`
- data is only available for geoRegion CHFL

### v.0.14.0
**Released**: `21.07.2021`
**Description**:
- once all cantons report detailed vaccination data, the data on vaccinated person (types `COVID19FullyVaccPersons`, `COVID19AtLeastOneDosePersons` and `COVID19PartiallyVaccPersons`) will be updated to be aggregated geographically by the residence of the person and no longer by the location of the administered doses.
- the following files (aggregation based on location of administered doses) will be DEPRECATED and will not be updated anymore after 16.07.2021 and removed after 30.07.2021: `COVID19VaccPersons.(json/csv)`, `COVID19FullyVaccPersons_vaccine.(json/csv)`, `COVID19FullyVaccPersons_indication_w`, ` COVID19VaccPersons_AKL10_w.(json/csv)` and `COVID19VaccPersons_sex_w.(json/csv)`
- added new source files `COVID19VaccPersons_v2.(json/csv)`, `COVID19FullyVaccPersons_vaccine_v2.(json/csv)`, `COVID19VaccPersons_AKL10_w_v2.(json/csv)`, `COVID19VaccPersons_sex_w_v2.(json/csv)` and `COVID19FullyVaccPersons_indication_w_v2.(json/csv)`
- added models  `VaccPersonsIncomingData`, `VaccPersonsVaccineIncomingData`, `VaccPersonsWeeklyIncomingData` and `VaccPersonsWeeklyIndicationIncomingData`
- mock data added for files `COVID19VaccPersons_v2`, `COVID19FullyVaccPersons_vaccine_v2`, `COVID19VaccPersons_AKL10_w_v2`, `COVID19VaccPersons_sex_w_v2` and `COVID19FullyVaccPersons_indication_w_v2`. Visit the online documentation to download the mock data files: `https://www.covid19.admin.ch/api/data/documentation#upcoming-releases`

### v.0.13.0
**Released**: `21.06.2021`
**Description**:
- added new source file for allotted contigent of vaccination doses: `COVID19VaccDosesContingent.(json/csv)`
- added model `VaccinationContingentIncomingData`

### v.0.12.0
**Released**: `17.06.2021`
**Description**:
- the data for virus variant B.1.617 (Kappa/Delta) will be removed and replaced by individual entries for B.1.617.1 (Kappa) and B.1.617.2 (Delta)
- udpated model `VirusVariantsWgsDailyIncomingData`
- the file `COVID19Variants.(json/csv)` has become DEPRECATED and will not be updated anymore after 17.06.2021 and will be removed after 30.06.2021
- the data for the following variants sourced from MSys (formerly available in the file `COVID19Variants.(json/csv)`) have been added to the `COVID19Variants_wgs.(json/csv)` file: P.1, B.1.617.1  B.1.617.2, B.1.525 (newly reported from 17.06.2021 onward), B.1.351, B.1.1.7 and B.1.1.7 & E484K. Check the `data_source` property to distinguish between the different sources.
- removed DEPRECATED files from version `v.0.8.0`

### v.0.11.0
**Released**: `14.06.2021`
**Description**:
- added new source files for additional geographical unit (greater regions, labor market regions, greater labor market regions and districts) breakdown for cases data: `COVID19Cases_extraGeoRegions_d.(json/csv)` and `COVID19Cases_extraGeoRegions_14d`
- added model documentation for `AdditionalGeoRegionDailyIncomingData`

### v.0.10.0
**Released**: `08.06.2021`
**Description**:
- added new source file for covid certificate data: `COVID19Certificates.(json/csv)`
- added model documentation `CovidCertificatesDailyIncomingData`

### v.0.9.0
**Released**: `25.05.2021`
**Description**:
- added new source files for suspected cases of adverse vaccination reactions based on reports from Swissmedic: `COVID19VaccSymptoms.(json/csv)`
- added model documentation `VaccinationSymptomsIncomingData`

### v.0.8.0
**Released**: `18.05.2021`
**Description**:
- added new source files for virus variant data from WGS: `COVID19Variants_wgs`
- added model documentation `VirusVariantsWgsDailyIncomingData`
- added new source files for vaccinated person data (including fully vaccinated persons, persons with at least one dose and partially vaccinated persons): `COVID19VaccPersons.(json/csv)`, `COVID19VaccPersons_AKL10_w.(json/csv)` and `COVID19VaccPersons_sex_w.(json/csv)`
- the following files are being DEPRECATED and will be removed after 15.06.2021: `COVID19FullyVaccPersons.(json/csv)`, `COVID19FullyVaccPersons_AKL10_w.(json/csv)` and `COVID19FullyVaccPersons_sex_w.(json/csv)`. The information about fully vaccinated persons is included in the files mentioned above (COVID19VaccPersons*)

### v.0.7.0
**Released**: `11.05.2021`
**Description**:
- added new source files for daily vaccination by vaccine (type) data: `COVID19FullyVaccPersons_vaccine.(json/csv)` and `COVID19VaccDosesAdministered_vaccine.(json/csv)`
- added model documentation `VaccinationVaccineIncomingData`

### v.0.6.0
**Released**: `04.05.2021`
**Description**:
- added new source files for weekly vaccination by indication (reason) data: `COVID19FullyVaccPersons_indication_w.(json/csv)` and `COVID19VaccDosesAdministered_indication_w.(json/csv)`
- added model documentation `VaccinationWeeklyIndicationIncomingData`
- added new source file for weekly vaccination by location data: `COVID19VaccDosesAdministered_location_w.(json/csv)`
- added model documentation `VaccinationWeeklyLocationIncomingData`

### v.0.5.0
**Released**: `29.04.2021`
**Description**:
- added new source file for weekly report text data: `COVID19WeeklyReportText.(json/csv)`
- added new source file for weekly test data by test type: `COVID19Test_geoRegion_PCR_Antigen_w.(json/csv)`
- extended the `WeeklyIncomingData` model with data regarding differences to the previous week & extension for test types

### v.0.4.6
**Released**: `26.04.2021`
**Description**:
  - added property `timeframe_phase3` to `HospCapacityDailyIncomingData` model

### v.0.4.5
**Released**: `19.04.2021`
**Description**:
- added new timeframe phase 3 starting from 15.02
  - added properties `offset_Phase3`, `sumTotal_Phase3`, `inzsumTotal_Phase3`, `anteil_pos_phase3` and `timeframe_phase3` to `DailyIncomingData` model
  - added properties `timeframe_phase3` to  `WeeklyIncomingData` model
  - added properties `sumTotal_Phase3` and `timeframe_phase3` to `VirusVariantsDailyIncomingData` model
  - added property `timeframe_phase3` to `ReDailyIncomingData` model

### v.0.4.4
**Released**: `25.03.2021`
**Description**:
- added `granularity` value `partial` to  `VaccinationWeeklyIncomingData` model

### v.0.4.3
**Released**: `19.03.2021`
**Description**:
- added data context history API, see documentation below for details
- added new properties `anteil_pos`, `lower_ci_day` and `upper_ci_day` to the `VirusVariantsDailyIncomingData` model

### v.0.4.2
**Released**: `26.02.2021`
**Description**:
- added new property `mean7d` to the `VaccinationIncomingData` model

### v.0.4.1
**Released**: `23.02.2021`
**Description**:
- added new weekly source files for fully vaccinated persons: `COVID19FullyVaccPerson_AKL10_ws.(json/csv)`, `COVID19FullyVaccPerson_sex_ws.(json/csv)`
- added new weekly source files for vaccination doses administered: `COVID19VaccDosesAdministered_AKL10_w.(json/csv)`, `COVID19VaccDosesAdministered_sex_w.(json/csv)`
- added model documentation `VaccinationWeeklyIncomingData`
- added new property `median_R_mean_mean7d` to R<sub>e</sub> data file `COVID19Re_geoRegion.(json/csv)`
- updated model documentation `ReDailyIncomingData`

### v.0.4.0
**Released**: `18.02.2021`
**Description**:
- added new source file for virus variant data: `COVID19Variants.(json/csv)`
- added model documentation `VirusVariantsDailyIncomingData`

### v.0.3.3
**Released**: `16.02.2021`
**Description**:
- added new source file for fully vaccinated persons: `COVID19FullyVaccPersons.(json/csv)`
- updated model documentation `VaccinationIncomingData`

#### v.0.3.2
**Released**: `05.02.2021`
**Description**:
- added type `COVID19VaccDosesReceived` data for CHFL to `COVID19VaccDosesDelivered.(json/csv)` (doses received by manufacturers)
- updated model documentation `VaccinationIncomingData`

#### v.0.3.1
**Released**: `28.01.2021`
**Description**:
- added new source files for vaccination data: `COVID19VaccDosesDelivered.(json/csv)`, `COVID19VaccDosesAdministered.(json/csv)`
- added new model documentation `VaccinationIncomingData`

#### v.0.3.0
**Released**: `13.01.2021`
**Description**:
- added new daily source file for international cases data `COVID19IntCases.(json/csv)`
- added new model documentation `InternationalDailyIncomingData`

#### v.0.2.0
**Released**: `17.12.2020`
**Description**:
- added new daily source file for R<sub>e</sub> Value by Cantons, CH and FL `COVID19Re_geoRegion.(json/csv)`
- added new source file for mandatory quarantine requirement when entering Switzerland `COVID19IntQua.(json/csv)`

#### v0.1.2

**Released**: `15.12.2020`

**Description**:
 - added new weekly source files for cases, hospitalisations, deaths and tests by geoRegion only
   - `COVID19Cases_geoRegion_w.(json/csv)`
   - `COVID19Hosp_geoRegion_w.(json/csv)`
   - `COVID19Death_geoRegion_w.(json/csv)`
   - `COVID19Test_geoRegion_w.(json/csv)`
 - added `default` weekly source file location group to `sources` of the data context for weekly data by geoRegion only
 - added new source file for daily hospital capacity data timelines by geoRegion `COVID19HospCapacity_geoRegion.(json/csv)`
 - added new model documentation for `HospCapacityDailyIncomingData`, check `https://www.covid19.admin.ch/api/data/documentation` for html version of model documentations
 - added `hospCapacity` file source location to `sources` of the data context
 - added fields `offset_Phase2b`, `sumTotal_Phase2b`, `inzsumTotal_Phase2b` and `anteil_pos_phase2b`to `DailyIncomingData`

#### v0.1.1
**Released**: `20.11.2020`

**Description**:
 - added new source file for test data by test type (pcr/antigen) `COVID19Test_geoRegion_PCR_Antigen.(json/csv)`
 - added `testPcrAntigen` file source location to `sources` of the data context
 - added fields `entries_pos` and `entries_neg` to DailyIncomingData

#### v0.1.0

**Released**: `05.11.2020`

**Description**: Initial version

## Data Context API

### Current Data Context
The current data context can be queried at a static location and provides information about the source date of the current data and source file locations.

```
GET https://www.covid19.admin.ch/api/data/context
```

### Data Model
`sourceDate` contains the overall source date of the data. Multiple publications per day are possible with the same `sourceDate`. Check the `dataVersion` to decide if you need to update your data.

`dataVersion` contains the current data version. Download links may be generated directly using the `dataVersion` but using the pre-generated urls in the `sources` field (see documentation below) is recommended.

`sources` contains information about the source location of all currently available raw source data (zip and individual files) to download as well as the schema version/content. OpenData DCAT-AP-CH metadata information will be published in the future in addition to this API to further facilitate automation of data downloads.

```
{
  "sources": {
    "schema": {
      "version": "{current-schema-version}",
      "jsonSchema": "{current-schema-location-url}"
    },
    "readme": "{current-readme-location-url}",
    "zip": {
      "json": "{current-source-location-url}",
      "csv": "{current-source-location-url}"
    },
    "individual": {
      "json": {
        "daily": {
          "cases": "{current-source-location-url}",
          "hosp": "{current-source-location-url}",
          "death": "{current-source-location-url}",
          "test": "{current-source-location-url}",
          "testPcrAntigen": "{current-source-location-url}",
          "hospCapacity": "{current-source-location-url}",
          "re": "{current-source-location-url}",
          "intCases": "{current-source-location-url}"
        },
        "weekly": {
          "byAge": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
          "bySex": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
          "default": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
        },
        "dailyReport": "{current-source-location-url}",
        "contactTracing": "{current-source-location-url}",
        "intQua": "{current-source-location-url}"
      },
      "csv": {
        "daily": {
          "cases": "{current-source-location-url}",
          "hosp": "{current-source-location-url}",
          "death": "{current-source-location-url}",
          "test": "{current-source-location-url}",
          "testPcrAntigen": "{current-source-location-url}",
          "hospCapacity": "{current-source-location-url}",
          "re": "{current-source-location-url}",
          "intCases": "{current-source-location-url}"
        },
        "weekly": {
          "byAge": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
          "bySex": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
          "default": {
            "cases": "{current-source-location-url}",
            "hosp": "{current-source-location-url}",
            "death": "{current-source-location-url}",
            "test": "{current-source-location-url}"
          },
        },
        "dailyReport": "{current-source-location-url}",
        "contactTracing": "{current-source-location-url}",
        "intQua": "{current-source-location-urxl}"
      }
    }
  }
}
```

### Data Context History

The data context history can be queried at a static location and provides a list of previously published data contexts.

```
GET https://www.covid19.admin.ch/api/data/context/history
```
Multiple publications per day are possible due to delays or data corrections etc. By default only the latest data context per day is returned from the API. Query `https://www.covid19.admin.ch/api/data/context/history/full` for all previously published data contexts (multiple per day returned).

### Data Model
`current` Url pointing to the current data context.

`documentation` Url of this documentation

`dataContexts` List of the individual data context history items

### Data Model (individual data context history item)
`date` Day of the publication, formatted as YYYY-MM-DD (e.g. 2021-03-18)

`latest` Multiple publications per day are possible due to delays or data corrections etc. This property indicates if the current data context is the latest one published for this day.

`published` Date and time of publication formatted as ISO 8601 string (e.g. 2021-03-18T13:30:35+01:00)

`dataVersion` Data version of thsi dataContext (see documentation above for details)

`dataContextUrl` Url pointing to the full data context object.

```
{
    "current": "https://www.covid19.admin.ch/api/data/context",
    "documentation": "https://www.covid19.admin.ch/api/data/documentation#data-context-history",
    "dataContexts: [
        {
            "date": "2021-03-18",
            "published": "2021-03-18T13:30:35+01:00",
            "latest": true,
            "dataVersion": "20210318-dec0fnrh",
            "dataContextUrl": "https://www.covid19.admin.ch/api/data/20210318-dec0fnrh/context"
        }
    ]
}
```
