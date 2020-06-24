# New data storage location!

This repository now only houses code used to harmonize data.

Data is now available in an OSF repository: [https://osf.io/mpwjq/](https://osf.io/mpwjq/)

The folder `/Current` always contains the most recent build
Weekly snapshots are archived as well.

Each build contains
 - `inputDB.csv`, the compiled and lightly filtered input database
 - `offsets.csv`, the offsets used for age harmonization
 - `Output_5.csv` harmonized outputs in 5-year age groups
 - `Output_10.csv` harmonized outputs in 10-year age groups
 
The output files have timestamps, as well as git commit ids. The git commit id identifies the state of the code repository that was used to produce the output files. Therefore, the `R` code in that repository snapshot together with the `inputDB.csv` 