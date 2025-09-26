# Extracting trait information

## Traits

|**Terrestrial**| **Source**| **Scale**|
|----|----|----|
| Mean annual air temperature (°C) | Chelsa (Bio1) | 1km|
|Mean daily mean air temperatures of the warmest quarter (°C)| Chelsa (Bio10) | 1km|
| Mean daily mean air temperatures of the coldest quarter (°C) | Chelsa (Bio11) | 1km|
| Annual precipitation amount (kg m-2 year -1)| Chelsa (Bio12) | 1km |
| Precipitation seasonality (kg m-2) | Chelsa (Bio15) | 1km |
| Mean monthly precipitation amount of the wettest quarter (kg m-2 month -1)| Chelsa (Bio16) | 1km |
| Mean monthly precipitation amount of the driest quarter (kg m-2 month -1)| Chelsa (Bio17) | 1km|
| Soil temperature (°C) | SoilTemp | 1km |
| Soil pH (pH x 10)| SoilGrids | 250m |
| Soil organic carbon content in the fine earth fraction (SOC, dg/kg) | SoilGrids | 250m |
| Total nitrogen (cg/kg) | SoilGrids | 250m |

| **Marine** | **Source** | **Scale** |
|----|----|----|
| Annual mean temperature (°C) | WOA | 27km | 
|Salinity | WOA | 27km |
|Silicate (µmol/kg)| WOA | 27km |
| Phosphate (µmol/kg) | WOA | 27km |
| Nitrate (µmol/kg) | WOA | 27km |
| Apparent Oxygen Utilized (AOU, µmol/kg)| WOA | 27km |
| Dissolved Oxygen (DO, µmol/kg) | WOA | 27km |
| Percent Oxygen Saturation (POS, %) | WOA | 27km |
|pH | GMED | 27km |
| Mean chlorophyll-A (mg/m-3) | GMED | 9.2km |
| Photosynthetic Active Radiation (PAR, Einstein/m-2/day)| GMED | 9.2km |
|Primary productivity (mg C m-2/day/cell) | GMED | 9.2km |
| Particulate Inorganic Carbon  (PIC, mol.m-3)| GMED | 4km |
|Particulate Organic Carbon  (POC, mol.m-3) | GMED | 4km |
|Total Suspended Matter (TSM, g m-3)  | GMED | 4km |

Iron is not part of any of these datasets, and we were unable to find a good source for global iron values. 

## Remove ASVs found in multiple environments

Remove the ASVs found in multiple environments from the metadata files using the script remove_ASVs_in_multiple_environments.R. 

## Visualize sampling locations

Make world maps with points for sampling location for soil, marine and freshwater samples, using the R script maps_sampling_points.R. 
Make a visualization of the number of shared ASVs with the R script shared_ASVs.R. 

## Soil

We have extracted trait information for 727 unique soil samples.  

### SoilGrids

Extract the following variables from Soilgrids, with a depth of 0-5cm: 
- pH
- Nitrogen, cg/kg
- Soil organic carbon content, dg/kg

These variables can be extracted with the R script soilgrids.R. 

### CHELSA
Extract the following climatic variables from CHELSA: 
Mean annual air temperature, °C (Bio1)
Mean daily mean air temperatures of the warmest quarter, °C (Bio10) 
Mean daily mean air temperatures of the coldest quarter, °C (Bio11) 
Annual precipitation amount, kg m-2 year -1 (Bio12) 
Precipitation seasonality, kg m-2 (Bio15)
Mean monthly precipitation amount of the wettest quarter, kg m-2 month-1 (Bio16) 
Mean monthly precipitation amount of the driest quarter, kg m-2 month-1 (Bio17) 

Download the bio1, bio10, bio11, bio12, bio15, bio16 and bio17 CHELSA data in tif format from https://chelsa-climate.org/downloads/   
path: Downloads/climatologies/1981-2010/bio

These variables can be extracted using the R script chelsa.R. 

### SoilTemp

Extract soil temperature values (°C) from the dataset by Lembrechts et al. 2022. Soil temperature layers have been calculated by adding monthly soil temperature offsets to monthly air-temperature maps from CHELSA (date range 1979-2013). 

Download SoilTemp data in tif format from https://zenodo.org/records/7134169, and extract the variables with the R script soiltemp.R.

### Make a table for all soil traits

Combine the extracted values in a complete table using the traits_soil.R script. 

## Marine

We have extracted trait information for 1346 unique marine samples.  

### World Ocean Atlas (WOA)
 
Extract the following variables from World Ocean Atlas
- Mean annual temperature, °C
- Salinity
- Nitrate, µmol/kg
- Phosphate, µmol/kg
- Silicate, µmol/kg
- Dissolved Oxygen, µmol/kg
- Percent Oxygen Saturation, %
- Apparent Oxygen Utilized, µmol/kg

Extract values for the specific depth the samples have been collected.

Download the WOA data from: https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/, and extract the variables using the R script WOA.R.  

### Global Marine Environment Dataset (GMED)

Extract the following variables from GMED:
- Chlorophyll-A mean, mg/m³
- Photosynthetic active radiation (PAR), Einstein/m²/day
- Particulate inorganic carbon (PIC), mol.m-3
- Particulate organic carbon (POC), mg.m-3
- Primary productivity, mgC·m-²·/day/cell
- Total suspended matter, g.m-3
- pH

Download the GMED data from: https://gmed.auckland.ac.nz/download.html, and extract the variables using the R script GMED.R. 

### Make a table for all marine traits

Combine all extracted values in a complete table using the traits_marine.R script. 

## Phylogenetic Principal Coordinate Analysis (pPCA)

Do a pPCA for terrestrial and marine traits, with the script pPCA.R. 

