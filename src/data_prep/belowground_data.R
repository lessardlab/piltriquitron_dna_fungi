library(tidyverse)
# devtools::install_github("brendanf/FUNGuildR")

#==========================
# Data on belowground  
#==========================
Plant_genetic_metadata <- read.csv("data/by.plant.data.ARG.June.2020.csv")
#Load Datasets from sequencing

#### ============================================================================================================
# update, to data.table::fread to read in data faster

### LOAD NEWER VERSION of ITS FUNGI
seqtabFun <- data.table::fread("data/ITS.community.6.10.2021.csv") %>% 
  as_tibble()## 
fungiTaxFun <- data.table::fread("data/ITS.taxonomy.6.10.2021.csv")%>% 
  as_tibble()
fungiKey <- data.table::fread("data/meta_ARG_ITS_v1.csv")%>% 
  as_tibble()

## rarefy matrices based on number of reads. 

# using 10% of the log-sum as threshold

# removing records with less than 10% of the 

seqtabFun <- reshape2::melt(seqtabFun)

seqtabFun <- seqtabFun %>% 
  filter(value != 0)
# keep records above the set threshold of reads
seqtabFun <- seqtabFun[log1p(seqtabFun$value) > quantile(log1p(seqtabFun$value), 0.1),]

# Linkage with Fun Guild assigment 

# match the taxonomy to the dataset

seqtabFun <- seqtabFun %>% 
  left_join(fungiTaxFun, c("variable" = "V1"))


# create taxo file for FunGuild 

funGuild <- data.frame("ASV_ID" = seqtabFun$variable, 
                       "Taxonomy" = seqtabFun %>% 
                         dplyr::select(matches("V[2-7]")) %>%
                         apply(1, function(x) paste(x, collapse = "_"))) %>% 
  distinct()

# call api to identify trophic position 
funGuild <- FUNGuildR::funguild_assign(funGuild)

# keep those records with high confidence 
funGuild <- funGuild %>% 
  filter(!confidenceRanking %in% c("Possible")) %>% 
  filter(!is.na(confidenceRanking))



### FYI: Confidence Ranking FUNGUILD:
#### Probable = fairly certain
#### possible = suspected not proven / conflicting reports = **not reliable**
#### - = no guild assigned 
# append info back to fungi dataset

seqtabFun <- seqtabFun %>% 
  left_join(funGuild, c("variable" = "ASV_ID")) 



# append metadata 

seqtabFun <- seqtabFun %>% 
  left_join(fungiKey, "V1")

# append plant data and create master 

fungiMaster <- seqtabFun %>%  
  left_join(Plant_genetic_metadata %>% 
              dplyr::select(Plant, Morphospecies, 
                            PlantSpecies, MYC, 
                            PlantFUNCT.group), 
            c("Plant" )) 


## keep master only with relevant data

fungiMaster <- fungiMaster %>% 
  dplyr::filter(Plot_Number %in% c(1:15) &
           Treatment %in% c("Pine", "Control", "Sapling")) %>% 
  distinct()


# filter data from soil and pine roots
fungiMaster_soil_root <- fungiMaster %>%
  filter(Plant %in% c("Soil", "Root"))

# filter data from plants
fungiMaster_plants <- fungiMaster %>%
  filter(!Plant %in% c("Soil", "Root"))


# erase negative wells
fungiMaster_plants <- fungiMaster_plants %>% 
  filter(!str_detect(V1,"neg")) %>%
  filter(Treatment != "" & Plant != "") %>%
  droplevels()

# remove trailing white space
fungiMaster_plants$PlantFUNCT.group <- stringr::str_trim(fungiMaster_plants$PlantFUNCT.group, "both")


message("ITS Fungi data available in the environment as <<fungiMaster_plants>>")

saveRDS(fungiMaster_plants, 'data/fungiMaster_plants.RDS')
message("ITS fungi  data available stored in /data as <<fungiMaster_plants.RDS>>")




## AMF FUNGI ========================================================================================================
seqtabAMF <- data.table::fread("data/comm_ARG_AMF_v1.csv",header = T) %>% 
  tibble()
AMFTax <- data.table::fread("data/EDIT_amf_tax.ARG.csv",header = T)%>% 
  tibble()
AMFKey <- data.table::fread("data/meta_ARG_AMF_v1.csv",header = T)%>% 
  tibble()

# using 10% of the log-sum as threshold

# removing records with less than 10% of the 

seqtabAMF <- reshape2::melt(seqtabAMF)

# remove 0 observations
seqtabAMF <- seqtabAMF[log1p(seqtabAMF$value) >0,]

# filter out those below the 10% of reads 
seqtabAMF <- seqtabAMF[log1p(seqtabAMF$value) > quantile(log1p(seqtabAMF$value), 0.1),]

# Linkage with F

## remove all samples less than 250 before rarifying
# 
# row_threshold <- seqtabAMF %>% 
#   group_by(variable) %>% 
#   summarize("row_sum" = sum(value)) %>%
#   filter(row_sum < 250) %>% 
#   select(variable) %>% 
#   droplevels() %>%
#   unlist() %>%
#   as.character()



# append metadata 

seqtabAMF <- seqtabAMF %>% 
  left_join(AMFKey, "V1")

# append plant data and create master 


AMFMaster <- seqtabAMF %>%  
  left_join(Plant_genetic_metadata %>% 
              dplyr::select(Plant, Morphospecies, PlantSpecies, MYC, PlantFUNCT.group), 
            c("Plant")) 


## keep master only with relevant data

AMFMaster <- AMFMaster %>% 
  filter(Plot_Number %in% c(1:15) & Treatment %in% c("Pine", "Control", "Sapling"))




# filter data from soil and pine roots
AMFMaster_soil_root <- AMFMaster %>%
  filter(Plant %in% c("Soil", "Root"))

# filter data from plants
AMFMaster_plants <- AMFMaster %>%
  filter(!Plant %in% c("Soil", "Root"))




# erase negative wells
AMFMaster_plants <- AMFMaster_plants %>% 
  filter(!str_detect("V1","neg")) %>%
  filter(Treatment != "" & Plant != "") %>%
  droplevels()


# remove trailing white space
AMFMaster_plants$PlantFUNCT.group <- stringr::str_trim(AMFMaster_plants$PlantFUNCT.group, "both")


message("AMF Fungi data available in the environment as <<AMFMaster_plants>>")

saveRDS(AMFMaster_plants, 'data/AMFMaster_plants.RDS')
message("AMF fungi  data available stored in /data as <<AMFMaster_plants.RDS>>")


# ==============================================================================================================
# BACTERA new files - updated April 2023
seqtabBAC <- data.table::fread("data/comm_ARG_BACT_v2.csv", header = T) %>% as_tibble()
BACTax <- data.table::fread("data/taxo_ARG_BACT_v2.csv", header = T)%>% as_tibble()
BACKey <- data.table::fread("data/meta_ARG_BACT_v2.csv", header = T)%>% as_tibble()



# using 10% of the log-sum as threshold

# removing records with less than 10% of the 

seqtabBAC <- reshape2::melt(seqtabBAC)

# keep only those non zero recods
seqtabBAC <- seqtabBAC[log1p(seqtabBAC$value) >0,]

#filter out those below the 10% of reads 
seqtabBAC <- seqtabBAC[log1p(seqtabBAC$value) > quantile(log1p(seqtabBAC$value), 0.1),]


# ## remove all samples less than 9500 
# 
# row_threshold <- seqtabBAC %>% 
#   group_by(variable) %>% 
#   summarize("row_sum" = sum(value)) %>%
#   filter(row_sum < quantile(row_sum, 0.1)) %>% 
#   select(variable) %>% 
#   droplevels() %>%
#   unlist() %>%
#   as.character()

# append metadata 

seqtabBAC <- seqtabBAC %>% 
  left_join(BACKey, "V1") %>%
  left_join(BACTax, 'V1')



# append plant data and create master 


BACMaster <- seqtabBAC %>%  
  left_join(Plant_genetic_metadata %>% 
              dplyr::select(Plant, Morphospecies, PlantSpecies, MYC, PlantFUNCT.group), 
            c("Plant")) 


## keep master only with relevant data

BACMaster <- BACMaster %>% 
  filter(Plot_Number %in% c(1:15) & 
           Treatment %in% c("Pine", "Control", "Sapling"))


# filter data from soil and pine roots
BACMaster_soil_root <- BACMaster %>%
  filter(Plant %in% c("Soil", "Root")) %>% 
  distinct()

# filter data from plants
BACMaster_plants <- BACMaster %>%
  filter(!Plant %in% c("Soil", "Root")) %>% 
  distinct()


# erase negative wells
BACMaster_plants <- BACMaster_plants %>% 
  filter(!str_detect("V1","neg")) %>%
  filter(Treatment != "" & Plant != "") %>%
  droplevels()


# remove trailing white space
BACMaster_plants$PlantFUNCT.group <- stringr::str_trim(BACMaster_plants$PlantFUNCT.group, "both")

message("Bacteria  data available in the environment as <<BACMaster_plants>>")

saveRDS(BACMaster_plants, 'data/BACMaster_plants.RDS')
message("Bacteria  data available stored in /data as <<BACMaster_plants.RDS>>")
