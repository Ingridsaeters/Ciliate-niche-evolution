# Ciliate-niche-evolution

## Directories

```
├── 00_phylogenies\
├── 01_dating\
├── 02_trait_extraction\
├── 03_modelling_niches\
└── README.md
```

Each directory contains a README.md file with detailed pipelines and corresponding scripts. 

<put link to google doc>

## To-do list

### To-do
- Share dated phylogenies with Ingrid. *Mahwash*
- Prune away the backbone. *Ingrid*
- Remove ASVs present in multiple habitats. *Ingrid*
- Figure 1. *Mahwash*
- Share metadata (temp, precip etc). *Ingrid*
- Figure 2. *Mahwash*
- How much of the ciliate niche conservatism is explained by biogeography? *Ingrid* (double check if okay)
- Get data from https://doi.org/10.1098/rspb.2022.0091. *Mahwash*
- How many ciliate species are there (terrestrial and marine)? *Mahwash*
- Are marine results biased because of sinking particles? *Ingrid*

### In progress  
- Test DBM on animal and plants. *Mahwash*
- Test Evorates on animals and plants. *Mahwash*

### Done
- Check if terrestrial sampling biases inferred evolutionary rates. *Ingrid*
  - Prune 10, 20, 30, 50, and 70% of ASVs and infer evolutionary rates for terrestrial ciliates (for any 5 variables including temp and precipitation).  
  - Prune away all ASVs from Europe, North America, and South East Asia (one by one) and infer evolutionary rates for terrestrial ciliates (for any 5 variables including temp and precipitation). 
- Check if metaPR2 has greater ciliate diversity. *Mahwash* (If yes, switch to metaPR2??).
- Download new version of EukBank (https://zenodo.org/records/7804946). *Ingrid*  
- Download animal and plant phylogenies and metadata from Liu et al 2020. *Mahwash*
- Infer new ciliate phylogenies with EukBank (or metaPR2). *Ingrid*
- Date phylogenies. *Mahwash*

### Notes/Ideas/etc  
- Maybe exclude climate measurements outside 2-3 standard deviations as they could be due to "windblown" ciliates.
- A lot more animal and plant observations per species compared to us. Is it comparable???
- What strategy to use for plants and animals? Already existing, well-sampled phylogenies (like Liu et al 2020) with a minimum of 50% taxonomic coverage? Or just all the big phylogenies and get distributions from GBIF/IUCN? For now, I will likely just use the phylogenies from Liu et al 2020 and run models on those. Once we have preliminary results, we can discuss with Micah, Helene and Ignacio on what seems more reasonable. 
