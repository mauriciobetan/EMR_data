# This script will read in raw data from the input directory, clean it up to produce 
# the analytical dataset, and then write the analytical data to the output directory. 

#source in any useful functions
source("check_packages.R")
source("useful_functions.R")

#####################################################
#I. LOAD

# 1. 1908-2008 Birds from Salvacetti 2018: https://doi.pangaea.de/10.1594/PANGAEA.888403?format=html#download
guano_birds <- read_excel("~/Downloads/guano_birds_peru.xlsx")
# 2. Anchoveta catch, 1950-2024: https://www.fao.org/fishery/statistics-query/en?dataset=capture&timeseries=capture_quantity
fish_fao <- read_excel("~/Downloads/capture_quantity-7.xlsx")
# 3. Anchoveta biomass (SSB). From Oliveros-Ramos, p. 306-307
ssb_biomass <- read_excel("~/Downloads/anchoveta_biomass_ssb.xlsx")
#. AGRORURAL birds census available upon request.
aves_guaneras <- read_excel("~/Downloads/aves_guaneras.xlsx")

### II. EDIT AND MERGE DATASETS

#a)
# Put FAO fish in column format
fish_fao <- pivot_longer(fish_fao, cols = 3:ncol(fish_fao), names_to = "year", 
                        values_to = "value")
fish_fao$year <- as.integer(sub(" value$", "", fish_fao$year))
#Remove unnecessary columns
fish_fao[,1:2]<- list(NULL)
# Change column name
colnames(fish_fao)[colnames(fish_fao)=="value"] <- "anch_catch"
# Divide by 1 million so it's in million tons
fish_fao$anch_catch <- fish_fao$anch_catch / 1e6

#b) average SSB to get single value for each year

ssb_biomass <- aggregate(ssb ~ floor(year), data = ssb_biomass, FUN = mean)
names(ssb_biomass) <- c("year", "ssb")

## Merge datasets

final_dataset <-merge(guano_birds, fish_fao, all.x=TRUE, all.y=TRUE)

final_dataset <-merge(final_dataset, ssb_biomass, all.x=TRUE, all.y=TRUE)

#Save dataset in output directory
save(final_dataset, file="output/analytical_data.RData")
