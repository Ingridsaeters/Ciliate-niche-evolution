# Extracting trait information

## Traits

| **Marine** | **Soil** | **Freshwater** | 
|--------|------|------------|
| **World Ocean Atlas (WOA)** | **Soilgrids** | **ERA5-LAND** |
| - Mean annual temperature | - pH | - Bottom temperature |
| - Nitrate | - Nitrogen | - Ice depth | 
| - Phosphate | - Carbon | - Ice surface temperature |
| - Silicate | **Chelsa** | - Depth of mixed layer |
| - Dissolved oxygen | - Annual average temperature | - Temperature of mixed layer |  
| - Oxygen saturation | - Annual mean percipitation | - Temperature of total layer |
| - Apparent oxygen utilized | - Annual percipitation amount | **Topography** | 
| **Global Marine Environment Dataset (GMED)** | - Mean daily mean air temperatures of the warmest quarter | - Elevation |
| - Chlorophyll-A mean | **SoilTemp** | **Afilazzola** | 
| - Photosynthetic active radiation (PAR) | - Annual soil temperature | - Total Nitrogen |
| - Particulate inorganic carbon (PIC) | **Topography** | - Total phosphorous | 
| - Particulate organic carbon (POC) | - Elevation | - Chlorophyll-A |
| - Primary productivity | - Topographical Position Index (TPI)
| - Total suspended matter | - Slope |
| - pH |

## Visualize sampling locations

Make world maps with points for sampling location for soil, marine and freshwater samples, using the R script maps_sampling_points.R

## Soil

We have extracted trait information for 977 unique soil samples.  

### SoilGrids

Extract the following variables from Soilgrids, with a depth of 0-5cm: 
- pH
- Nitrogen, cg/kg
- Soil organic carbon content, dg/kg

These variables can be extracted with the R script soilgrids.R. 

### CHELSA

Extract the following climatic variables from CHELSA: 
- Average annual temperature, °C (Bio1)
- Annual mean precipitation, precipitation seasonality, kg m-2 (Bio15)
- Annual precipitation amount, precipitation accumulated, kg m-2 year-1 (Bio12)
- Mean monthly precipitation amount for wettest qaurter of the year, kg m-2 month-1 (Bio16)
- Mean monthly precipitation amount for the coldest quarter of the year, kg m-2 month-1 (Bio19)
- Daily mean temperature for the warmest quarter of the year, °C (Bio10)

Download the bio1, bio10, bio12, bio15, bio16 and bio19 CHELSA data in tif format from https://chelsa-climate.org/downloads/   
path: Downloads/climatologies/1981-2010/bio

These variables can be extracted using the R script chelsa.R. 

### SoilTemp

Extract soil temperature values (°C) from the dataset by Lembrechts et al. 2022. Soil temperature layers have been calculated by adding monthly soil temperature offsets to monthly air-temperature maps from CHELSA (date range 1979-2013). 

Download SoilTemp data in tif format from https://zenodo.org/records/7134169, and extract the variables with the R script soiltemp.R.

### Topography

Extract the following topography variables: 
- Elevation, m
- Slope, °
- Topographical Position Index (TPI), m

These variables can be extracted using the R script topography_soil.R. 

### Make a table for all soil traits

Combine the extracted values in a complete table using the traits_soil.R script. 

## Marine

We have extracted trait information for 5493 unique marine samples.  

### World Ocean Atlas (WOA)
 
Extract the following variables from World Ocean Atlas
- Mean annual temperature, °C
- Nitrate, µmol/kg
- Phosphate, µmol/kg
- Silicate, µmol/kg
- Dissolved oxygen, µmol/kg
- Oxygen saturation, %
- Apparent oxygen utilized, µmol/kg

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

## Freshwater

## Phylogenetic Principal Coordinate Analysis (pPCA)

Do a pPCA for soil, marina and freshwater traits, with the script pPCA.R. Add the PC1 values to the trait table. 

