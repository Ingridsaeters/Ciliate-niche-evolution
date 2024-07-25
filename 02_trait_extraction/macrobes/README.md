# Extracting trait information for animals and plants

## Data from Liu et al. 2020 (20240725)
For preliminary analyses I used the phylogenies and climatic data provided in the supplementary information of [Liu et al 2020](https://doi.org/10.1038/s41559-020-1158-x). 

I extracted just Bio1 (mean annual temperature in °C) and Bio12 (mean annual precipitation in mm) along with the number of observations and standard deviations for Bio1 and Bio12. It is important to note that all values are derived from WorldClim and not CHELSA.

Diffused Brownian Motion (DBM - implemented in Tapestree) requires a table with tip labels, trait values, and (optional but recommended) standard deviation values. These files have the extension `dbm.txt`. The column headers (not included in the files) are as follows: Species, number of observations, mean temp value, temp stdev, mean precipitation value, precipitation stdev. The files were generated as follows:

```
for i in *txt; do file=$(echo $i | cut -f1 -d '.'); grep -v "Species" $i > $file.dbm.txt; done
```



   

## References
Liu, H., Ye, Q., & Wiens, J. J. (2020). Climatic-niche evolution follows similar rules in plants and animals. Nature Ecology & Evolution, 4 (5), 753–763. https://doi.org/10.1038/s41559-020-1158-x

