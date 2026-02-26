
library(tidyverse)

# read in raw csv dataset
soil <- read.csv("data/SoilDATA.csv", header  = T, stringsAsFactors = F)

# transform to ppm, calculate n and c totals, and ratios 
soil <- soil %>% 
  mutate(Pdisp =  Pdisp/10000,
         N.NH4 = N.NH4/10000,
         N.NO3 = N.NO3/10000,
         C = C/10000,
         N_tot = (N.NO3 * (14/62)) + (N.NH4 * (14/18)),
         CN_rat = log(C/N_tot),
         PN_rat = log(N_tot/Pdisp))



# read temperature measurememnts 
TempSoilRaw <- read.csv("data/TEMPDATAfe2019.csv", header = T)

# Summarize temperature records 

TempSoil_fix <- TempSoilRaw %>% 
  group_by(Tag) %>% 
  summarise(mean_hour = mean(Hour, na.rm=T),
            mean_temp = mean(Temperature, na.rm=T),
            count = n(), 
            Treatment = Treatment) %>% 
  separate(Tag, c("Treatment", "Number", "Code")) %>% 
  mutate(Muestra = paste0(Treatment, Number))



# Join temperature and soil chemistry data (ugly code but works )

# Split tags 
TempSoilRaw <- data.frame(TempSoilRaw, stringr::str_split(TempSoilRaw$Tag, "-", simplify = T))
# fix mistakes 
TempSoilRaw <- TempSoilRaw[order(TempSoilRaw$X2),]
TempSoilRaw$X2 <- as.character(TempSoilRaw$X2)

TempSoilRaw$X2[TempSoilRaw$X1 == "Con" & TempSoilRaw$X2 %in% c("004","006","014","030", "025")] <- c("034","036", "044", "045","040")
TempSoilRaw$X2[TempSoilRaw$X1 == "Sap" & TempSoilRaw$X2 %in% c("031","032","033","034")] <- c("015","016","017", "018")
TempSoilRaw$X1[TempSoilRaw$X1 == "Pine" & TempSoilRaw$X2 %in% c("017")] <- c("Sap")
TempSoilRaw$X1[TempSoilRaw$X1 == "Pine " & TempSoilRaw$X2 %in% c("006")] <- c("Pine")
# Remove non-wanted plots 
TempSoilRaw$PlotNum <- as.numeric(TempSoilRaw$X2)
TempSoilRaw <- TempSoilRaw[TempSoilRaw$PlotNum <= 45,]
# Create ID to match 
TempSoilRaw$Plot <- paste0(TempSoilRaw$X1, TempSoilRaw$X2)
# aggregate by its median by plot 
TemSoilAgg <- aggregate(TempSoilRaw$Temperature, list(TempSoilRaw$Plot), median, na.rm =T)
# recreate official plot codes
TemSoilAgg$Plot <- paste0(stringr::str_split(TemSoilAgg$Group.1, "0", simplify = T)[,1],
                          rep(c("001", "002", "003","004","005", "006", "007",
                                "008", "009","010", "011", "012", "013", "014", "015"), 3))
TemSoilAgg$Treatment <- stringr::str_split(TemSoilAgg$Group.1, "0", simplify = T)[,1]

soil$Temp <- TemSoilAgg$x[match(soil$Muestra,TemSoilAgg$Plot)]

soil$Treatment <- factor(as.factor(soil$Treatment), levels = c("Control", "Sapling", "Pine"))


#==========================
# Pine measurements  
#==========================
PineDat <- read.csv("data/PineMeasuresFeb2019.csv")


soil <- data.frame(soil,PineDat[c("Lat", "Lon")][match(soil$Muestra, PineDat$Code),])

saveRDS(soil, 'soil.RDS')
message("final dataset <<soil>> stored in /data at soil.RDS")
#==============
# Figures
#==============


# Check for biases with temperature records with record time 

ggplot(TempSoil_fix, 
       aes(mean_hour, mean_temp, color = Treatment)) + 
  geom_point() +
  geom_smooth(method = "lm", fill = "grey80") + 
  scale_color_manual(values = c(conCol,sapCol,pineCol)) + 
  theme_minimal(base_size = 20) + 
  xlab('Hour of day') + 
  ylab('Mean soil temperature')
