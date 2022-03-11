# COVerAGE-DB: a global demographic database of COVID-19 cases and deaths.

## Getting started

A short guide to reading the data into `R` can be found [here](https://timriffe.github.io/covid_age/GettingStarted.html). We will add other basic scripts for common data operations, and we will add some `Stata` examples too.

## Data availability
You can get the most up-to-date data at the `OSF` site that we mirror to: [https://osf.io/mpwjq/](https://osf.io/mpwjq/). 

Here's an overview of global coverage as of now. A country marked as *forthcoming* means we've identified a source, but that collection is pending for one reason or another. Are you from one of the countries not yet in the collection and want to pitch in? Are you interested in adopting collection for one of our time series that has fallen behind? We're in need of more support. Please reach out, if so by emailing us as `coverage-db < at > demogr.mpg.de`.
![coverage map](https://raw.githubusercontent.com/timriffe/covid_age/master/assets/coveragemap.svg)

A detailed dashboard of data availability can be found [here](https://timriffe.github.io/covid_age/DataAvail.html).

## Data processing steps

A draft Method Protocol is available [here](https://osf.io/jcnw3/)

A dash overview of which steps are applied to each country-region-date subset of data can be found [here](https://timriffe.github.io/covid_age/DataSteps.html).  

## Documentation
Source documentation is presently being gathered and standardized, and we will find a slick way of displaying it when it's further along. All data results are provisional and may change if we decide to change particular sources, or if we change our minds about how to split age groups, etc. So **please always use the most up-to-date version**.

### Sources
A basic data source dashboard is available  [here](https://timriffe.github.io/covid_age/DataSources.html).

## Notes
Most populations in the database contain multiple time snapshots, and all are continually monitored for new data releases.  All statistics reported here are **cumulative**. 

If you know of sources for other populations, please either email, Tweet, or leave an *Issue* in this repository, and we'll look into it. If you would like to assist this project in gathering data, or other tasks, please let us know and I'm sure we can find a task!

## Citation

Please cite the International Journal of Epidemiology paper also listing the OSF repository, which has a doi. 

Tim Riffe, Enrique Acosta, the COVerAGE-DB team (2021) Data Resource Profile: COVerAGE-DB: a global demographic database of COVID-19 cases and deaths. International Journal of Epidemiology, Volume 50, Issue 2, April 2021, Pages 390–390f, DOI: https://doi.org/10.1093/ije/dyab027 Data downloaded from [DATE] (https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ]

The long citation including all coauthors is:

Tim Riffe, Enrique Acosta, José Manuel Aburto, Diego Alburez-Gutierrez, Anna Altová, Ainhoa Alustiza, Ugofilippo Basellini, Simona Bignami, Didier Breton, Eungang Choi, Jorge Cimentada, Gonzalo De Armas, Emanuele Del Fava, Alicia Delgado, Viorela Diaconu, Jessica Donzowa, Christian Dudel, Antonia Fröhlich, Alain Gagnon, Mariana Garcia-Crisóstomo, Victor M. Garcia-Guerrero, Armando González-Díaz, Irwin Hecker, Dagnon Eric Koba, Marina Kolobova, Mine Kühn, Mélanie Lépori, Chia Liu, Andrea Lozer, Mădălina Manea, Lilian Marey, Muntasir Masum, Ryohei Mogi, Céline Monicolle, Saskia Morwinsky, Ronald Musizvingoza, Mikko Myrskylä, Marília R. Nepomuceno, Michelle Nickel, Natalie Nitsche, Anna Oksuzyan, Samuel Oladele, Emmanuel Olamijuwon, Oluwafunke Omodara, Soumaila Ouedraogo, Mariana Paredes, Marius D. Pascariu, Manuel Piriz, Raquel Pollero, Larbi Qanni, Federico Rehermann, Filipe Ribeiro, Silvia Rizzi, Francisco Rowe, Adil R. Sarhan, Isaac Sasson, Erez Shomron, Jiaxin Shi, Rafael Silva-Ramirez, Cosmo Strozza, Catalina Torres, Sergi Trias-Llimos, Fumiya Uchikoshi, Alyson van Raalte, Paola Vazquez-Castillo, Estevão A. Vilela, Muhammad Ali Waqar, Iván Williams, Virginia Zarulli (2021) Data Resource Profile: COVerAGE-DB: a global demographic database of COVID-19 cases and deaths. International Journal of Epidemiology, Volume 50, Issue 2, April 2021, Pages 390–390f, DOI: https://doi.org/10.1093/ije/dyab027 Data downloaded from [DATE] (https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ]


## The team (so far), alphabetical by last name
José Manuel Aburto, Enrique Acosta, Diego Alburez-Gutierrez, Anna Altová, Ainhoa Alustiza, Ugofilippo Basellini, Simona Bignami, Didier Breton, Eungang Choi, Jorge Cimentada, Gonzalo De Armas, Emanuele Del Fava, Alicia Delgado, Alicia Delgado, Viorela Diaconu, Jessica Donzowa, Christian Dudel, Vanessa Sophie Ernst, Antonia Fröhlich, Alain Gagnon, Mariana Garcia Cristómo, Victor M. Garcia-Guerrero, Armando González-Díaz, Irwin Hecker, Nityanand Jain, Dagnon Eric Koba, Marina Kolobova, Mine Kühn, Mélanie Lépori, Chia Liu, Andrea Lozer, Mădălina Manea, Lilian Marey, Muntasir Masum, Ryohei Mogi, Céline Monicolle, Saskia Morwinsky, Waqar Muhammad Ali, Ronald Musizvingoza, Mikko Myrskylä, Marília R. Nepomuceno, Michelle Nickel, Natalie Nitsche, Anna Oksuzyan, Samuel Oladele, Emmanuel Olamijuwon, Oluwafunke Omodara, Soumaila Ouedraogo, Mariana Paredes, Marius Pascariu, Manuel Piriz, Raquel Pollero, Larbi Qanni, Larbi Qanni, Federico Rehermann, Filipe Ribeiro, Tim Riffe, Silvia Rizzi, Francisco Rowe, Adil R. Sarhan, Isaac Sasson, Jonas Schöley, Jiaxin Shi, Erez Shomron, Rafael Silva-Ramirez, Cosmo Strozza, Catalina Torres, Sergi Trias-Llimos, Fumiya Uchikoshi, Alyson van Raalte, Paola Vazquez-Castillo, Estevão Vilela, Iván Williams, Virginia Zarulli

Maybe you too? We could still use a hand, really!

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
- World Mortality Database [https://github.com/akarlinsky/world_mortality](https://github.com/akarlinsky/world_mortality)





