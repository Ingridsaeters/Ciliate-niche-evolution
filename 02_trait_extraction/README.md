# Extracting trait information

## Choice of traits

## Soil

We have extracted trait information for 977 unique soil samples.  
The extracted values were combined in a complete table using the traits_soil.R script. 

### SoilGrids

We extracted the following variables from Soilgrids, with a depth of 0-5cm: 
- pH
- Nitrogen, cg/kg
- Soil organic carbon content, dg/kg

This information was extracted with the R script soilgrids.R. 

### CHELSA

We extracted the following climatic variables from CHELSA: 
- Average annual temperature, °C (Bio1)
- Annual mean precipitation, precipitation seasonality, kg m-2 (Bio15)
- Annual precipitation amount, precipitation accumulated, kg m-2 year-1 (Bio12)
- Mean monthly precipitation amount for wettest qaurter of the year, kg m-2 month-1 (Bio16)
- Mean monthly precipitation amount for the coldest quarter of the year, kg m-2 month-1 (Bio19)
- Daily mean temperature for the warmest quarter of the year, °C (Bio10)

We downloaded the bio1, bio10, bio12, bio15, bio16 and bio19 CHELSA data in tif format from https://chelsa-climate.org/downloads/   
path: Downloads/climatologies/1981-2010/bio

These variables were extracted using the R script chelsa.R. 

### SoilTemp

Soil temperature values (°C) were extracted from a dataset by Lembrechts et al. 2022. Soil temperature layers have been calculated by adding monthly soil temperature offsets to monthly air-temperature maps from CHELSA (date range 1979-2013). 

SoilTemp data was downloaded in tif format from https://zenodo.org/records/7134169, and extracted with the R script soiltemp.R.

### Topography

We extracted the following topography variables: 
- Elevation, m
- Slope, °
- Topographical Position Index (TPI), m

These variables were extracted using the R script topography_soil.R. 

## Marine

We have extracted trait information for 5493 unique marine samples.  
The extracted values were combined in a complete table using the traits_marine.R script. 

### World Ocean Atlas (WOA)
 
We extracted the following variables from World Ocean Atlas
- Mean annual temperature, °C
- Nitrate, µmol/kg
- Phosphate, µmol/kg
- Silicate, µmol/kg
- Dissolved oxygen, µmol/kg
- Oxygen saturation, %
- Apparent oxygen utilized, µmol/kg

Values were extracted for the specific depth the samples have been collected.

The WOA data was downloaded from: https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/, and extracted using the R script WOA.R.  

### Global Marine Environment Dataset (GMED)

We extracted the following variables from GMED:
- Chlorophyll-A mean, mg/m³
- Photosynthetic active radiation (PAR), Einstein/m²/day
- Particulate inorganic carbon (PIC), mol.m-3
- Particulate organic carbon (POC), mg.m-3
- Primary productivity, mgC·m-²·/day/cell
- Total suspended matter, g.m-3
- pH

The GMED data was downloaded from: https://gmed.auckland.ac.nz/download.html, and extracted using the R script GMED.R. 

## Freshwater

