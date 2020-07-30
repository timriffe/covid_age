# COVerAGE-DB 

## COVID-19 cases, deaths, and tests by age and sex

This project is currently in development, stay tuned for documentation. You can get preliminary output in 5 and 10-year age groups in the `/Data` folder. This contains columns for `Cases`, `Deaths`, and `Tests`. There may be more populations availale in the unharmonized input database (`inputDB.csv`), because some are awaiting corrections or additional inputs .

## Getting started

A short guide to reading the data into `R` can be found [here](https://timriffe.github.io/covid_age/GettingStarted.html). We will add other basic scripts for common data operations, and we will add some `Stata` examples too.

## Data availability
You can get the most up-to-date data at the `OSF` site that we mirror to: [https://osf.io/mpwjq/](https://osf.io/mpwjq/). 

Here's an overview of global coverage as of now. A country marked as *forthcoming* means we've identified a source, but that collection is pending for one reason or another. Are you from one of those countries? Please reach out, if so.
![coverage map](https://raw.githubusercontent.com/timriffe/covid_age/master/assets/coveragemap.svg)

A detailed dashboard of data availability can be found [here](https://timriffe.github.io/covid_age/DataAvail.html).

## Data processing steps

A (preliminary) description of data processing steps, and dash overview of which steps are applied to each country-region-date subset of data can be found [here](https://timriffe.github.io/covid_age/DataSteps.html).

This does not yet give an overview of age-group harmonization performed, but we'll add this soon. Further details will be spelled out in a methods protocol, presently in preparation.

## Documentation
Source documentation is presently being gathered and standardized, and we will find a slick way of displaying it when it's further along. All data results are provisional and may change if we decide to change particular sources, or if we change our minds about how to split age groups, etc. So **please always use the most up-to-date version**.

## Notes
Most populations in the database contain multiple time snapshots, and all are continually monitored for new data releases.  All statistics reported here are **cumulative**. 

If you know of sources for other populations, please either email, Tweet, or leave an *Issue* in this repository, and we'll look into it. If you would like to assist this project in gathering data, or other tasks, please let us know and I'm sure we can find a task!

## Citation

Please cite using the OSF repository, which has a doi. All collaborators are coauthors (see full list below), but this short form is preferred:

### APA
Riffe, T., Acosta, E., et. al. (DATE). COVerAGE-DB: A database of COVID-19 cases and deaths by age . (https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ]

### MLA
Riffe, Tim, Enrique Acosta, et. al. “COVerAGE-DB: A Database of COVID-19 Cases and Deaths by Age .” OSF, DATE. Web.(https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ]

### Chicago
Riffe, Tim, Enrique Acosta, et. al. 2020. “COVerAGE-DB: A Database of COVID-19 Cases and Deaths by Age .” OSF. DATE. doi:10.17605/OSF.IO/MPWJQ.

## The team (so far), alphabetical by last name
José Manuel Aburto, Enrique Acosta, Diego Alburez-Gutierrez, Anna Altová, Lateef Amusa, Ugofilippo Baselini, Simona Bignami, Didier Breton, Jorge Cimentada, Gonzalo De Armas, Emanuele del Fava, Viorela Diaconu, Jessica Donzowa, Christian Dudel, Toni Froehlich, Alain Gagnon, Mariana Garcia Cristómo, Victor M. Garcia-Guerrero, Armando González, Irwin Hecker, Eric Koba, Marina Kolobova, Mine Kühn, Chia Liu, Andrea Lozer, Mădălina Manea, Muntasir Masun, Ryohei Mogi, Saskia Morwinsky, Mikko Myrskylä, Marilia Nepomuceno, Michelle Nickel, Natalie Nitsche, Anna Oksuzyan, Samuel Oladele, Emmanuel Olamijuwon, Soumaila Ouedraogo, Mariana Paredes, Marius Pascariu, Manuel Piriz, Raquel Pollero, Federico Rehermann, Filipe Ribeiro, Tim Riffe, Silvia Rizzi, Francisco Rowe, Isaac Sasson, Jiaxin Shi, Rafael Silva, Cosmo Strozza, Catalina Torres, Sergi Trias-Llimos, Fumiya Uchikoshi, Alyson van Raalte, Paola Vasquez, Estevão Vilela, Iván Williams, Virginia Zarulli

(and a few more people at the moment have made commitments. )

Maybe you too? (we could still use a hand!)

## See also
Some other databases relevant to this one:

### Age-structured, also related to COVID-19 directly

- INED database on COVID-19 deaths by age and sex: [https://dc-covid.site.ined.fr/en/](https://dc-covid.site.ined.fr/en/)
- Global Health 5050 also provides data by age and sex [https://globalhealth5050.org/covid19/sex-disaggregated-data-tracker/](https://globalhealth5050.org/covid19/sex-disaggregated-data-tracker/)
- The Short Term Mortality Fluctutions (STMF) database (all cause mortality) [www.mortality.org](www.mortality.org)
- Eurostat compiled data on all-cause mortality by weeks [demo_r_mweek3](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en)

### Total counts, interesting to relate or compare

- Our World in Data testing data [https://ourworldindata.org/coronavirus-testing](https://ourworldindata.org/coronavirus-testing)
- JHU total cases and deaths [https://github.com/CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)
  





