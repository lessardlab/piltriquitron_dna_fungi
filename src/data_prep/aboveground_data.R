# Soil dwelling arthropods
insectDat <- read.csv("data/InsectData.csv", header = T, sep = ",")


saveRDS(insectDat, 'data/insectDat.RDS')
message("Aboveground insect data available stored in /data as <<insectDat.RDS>>")



#==========================
# Data on leaf_traits  
#==========================


# Upload clean dataset 
LeafTraitData <- read.csv("data/leafTraits_clean_mar2020.csv", stringsAsFactors = F, header = T)
# Order levels so it makes sense
LeafTraitData$Treatment <- factor(LeafTraitData$Treatment, levels  = c("Control", "Sapling", "Pine"))
# Calculate trait index's
LeafTraitData$LWC <- LeafTraitData$H2O_weight / LeafTraitData$LeafNumber
LeafTraitData$LDMC <- LeafTraitData$leaveDryMass / LeafTraitData$LeafNumber
LeafTraitData$MLA <- ((LeafTraitData$RawTotalLeafArea/LeafTraitData$pixelDens^2)*100)/ LeafTraitData$LeafNumber
LeafTraitData$SLA <- LeafTraitData$MLA / (LeafTraitData$leaveDryMass*1000)
## get rid of lower areas for now 
LeafTraitData <- LeafTraitData[!LeafTraitData$Area == "Lower",]


saveRDS(LeafTraitData, 'data/LeafTraitData.RDS')
message("Aboveground leaf-trait data available stored in /data as <<LeafTraitData.RDS>>")


#==========================
# Data on plant_composition 
#==========================

plant <- read.csv("data/PlantDATAMar2019.csv", header = T)
plant <- plant[plant$Zone== "Plateau",]
plant <- plant[plant$Number<16,]
plant<- droplevels(plant)


p2 <-read.csv("data/plant_clean_mar2020.csv")
p2 <-p2[p2$Sample != "ConXX",]


saveRDS(plant, 'data/plant.RDS')
saveRDS(p2, 'data/p2.RDS')

message("Aboveground plant composition data available stored in /data as <<plant.RDS & p2.RDS>>")

