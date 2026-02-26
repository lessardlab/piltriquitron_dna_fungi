# Piltriquitrón  Data 

Data preparation workflows for the Piltriquitrón field site.

This repository contains R scripts that transform raw field + sequencing tables into curated `.RDS` datasets used for downstream ecological analyses.

## What this repository does

The pipeline builds three data domains:

1. **Aboveground** (insects, leaf traits, plant composition)
2. **Belowground** (ITS fungi, AMF fungi, bacteria)
3. **Soil** (chemistry + temperature + coordinates)

The entrypoint script is:

- `src/master_data_prep.R`

It sources the domain scripts under `src/data_prep/`.

---

## Repository layout

- `src/master_data_prep.R` – orchestration script
- `src/data_prep/aboveground_data.R` – prepares aboveground datasets
- `src/data_prep/belowground_data.R` – prepares sequencing-derived microbial datasets
- `src/data_prep/soil_data_prep.R` – prepares soil chemistry/temperature dataset
- `data/` – raw input files and generated `.RDS` outputs

---

## Prerequisites

- **R** (recommended: R 4.1+)
- Packages used by the scripts:
  - `tidyverse`
  - `data.table`
  - `reshape2`
  - `FUNGuildR`

Install dependencies (example):

```r
install.packages(c("tidyverse", "data.table", "reshape2"))
# FUNGuildR is commonly installed from GitHub, as referenced in script comments:
# devtools::install_github("brendanf/FUNGuildR")
```

> Note: `belowground_data.R` calls `FUNGuildR::funguild_assign(...)`, so `FUNGuildR` must be available for full pipeline execution.

---

## Running the pipeline

From repository root:

```bash
Rscript src/master_data_prep.R
```

This runs all three data-prep scripts in sequence.

---

## Expected outputs

After a successful run, these files are created in `data/`.

### Aboveground outputs

- `insectDat.RDS`
- `LeafTraitData.RDS`
- `plant.RDS`
- `p2.RDS`

### Belowground outputs

- `fungiMaster_plants.RDS`
- `AMFMaster_plants.RDS`
- `BACMaster_plants.RDS`

### Soil outputs

- `soil.RDS`

---

## Input data assumptions

The scripts expect input CSV files to exist in `data/` with the filenames currently referenced in source code (for example `ITS.community.6.10.2021.csv`, `SoilDATA.csv`, `PlantDATAMar2019.csv`, etc.).

If names or locations change, update the corresponding `read.csv(...)` / `data.table::fread(...)` calls in the scripts.

---

## Troubleshooting

- If the pipeline fails on fungal guild assignment, verify `FUNGuildR` installation and network/API availability.
- If a script fails while reading data, check that required input files are present in `data/` and have expected column names.
- The project is script-based (not an R package), so there is no `DESCRIPTION` or formal test suite.
