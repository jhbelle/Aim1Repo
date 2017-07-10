## -----------
## Name: 



TotMassSF <- read.csv("C:/Users/Jess/Desktop/Data_Diss/TotMassResults.csv", stringsAsFactors=F)
TotMassAtl <- read.csv("C:/Users/Jess/Desktop/Data_Diss/TotMassResultsAtl.csv", stringsAsFactors=F)
SpecMassSF <- read.csv("C:/Users/Jess/Desktop/Data_Diss/SpecMassResultsSF.csv", stringsAsFactors=F)
SpecMassAtl <- read.csv("C:/Users/Jess/Desktop/Data_Diss/SpecMassResultsAtl.csv", stringsAsFactors=F)

AllMass <- rbind.data.frame(TotMassAtl, TotMassSF, SpecMassAtl, SpecMassSF)
AllMass$SigPred = ifelse((AllMass$X2.5.. < 0 & AllMass$X97.5.. < 0) | (AllMass$X2.5.. > 0 & AllMass$X97.5.. > 0), 1, 0)
AllMass$Vars <- factor(AllMass$Vars, levels=c("(Intercept)", "CenteredTemp", "WindSpeed", "r_heightAboveGround", "pblh", "cape2", "Raining", "CloudAOD", "CloudEmmisivity", "CloudRadius"), ordered=T, labels=c("Intercept", "Temperature (C)", "Wind Speed (m/s)", "RH", "PBL height (km)", "CAPE", "Precipitatation", "Cloud AOD", "Emissivity", "Droplet Radius"))
AllMass$Site <- factor(AllMass$Site, levels=c("SF", "Atl"), ordered=T, labels=c("San Francisco", "Atlanta"))
AllMass$PMSpec <- factor(AllMass$PMSpec, levels=c("TotMass", "OCMass", "SMass", "NMass"), ordered=T, labels=c("Total", "OC", "Sulfate", "Nitrate"))
AllMass$AQ <- factor(AllMass$AQ, levels=c("T", "A"), ordered=T, labels=c("Terra", "Aqua"))

library(ggplot2)

jpeg(filename="C:/Users/Jess/Desktop/Plot1.jpg", width=8, height=18, units="in", res=600)

ggplot(AllMass, aes(y=Estimate, ymin=X2.5.., ymax=X97.5.., alpha=as.factor(SigPred), x=PMSpec, color=Mod, linetype=AQ)) + 
    geom_point(position=position_dodge(width=0.6)) + 
    geom_hline(aes(yintercept=0), color="gray50") + 
    scale_y_continuous(bquote('Change in the natural log of the mass concentration (' *mu~'g/'~m^3*')')) + 
    scale_x_discrete(bquote(~PM[2.5]~ 'fraction')) +
    scale_color_brewer("Cloud Type", type="qual", palette="Set1", labels=c("Ice", "Possibly \ncloudy", "Water")) + 
    scale_alpha_discrete("Significant \npredictor", labels=c("No", "Yes")) + 
    scale_linetype_discrete("MODIS \ninstrument") + 
    facet_grid(Vars~Site, scales="free") + 
    theme_classic(base_size=16)

dev.off()

jpeg(filename="C:/Users/Jess/Desktop/Plot2.jpg", width=8, height=18, units="in", res=600)
ggplot(AllMass[AllMass$Mod != "Maybe",], aes(y=Estimate, x=Mod, color=PMSpec)) + 
  geom_point(position=position_dodge(width=0.6)) + 
  geom_hline(aes(yintercept=0), color="gray50") + 
  scale_y_continuous(bquote('Change in the natural log of the mass concentration  (' *mu~'g/'~m^3*')')) + 
  #scale_x_discrete(bquote(~PM[2.5]~ 'fraction')) +
  scale_x_discrete("Cloud Type", labels=c("Ice", "Water")) +
  #scale_color_brewer("Cloud Type", type="qual", palette="Paired", labels=c("Ice", "Possibly \ncloudy", "Water")) + 
  scale_color_brewer(bquote(~PM[2.5]~ 'fraction'), type="qual", palette="Set1") +
  scale_alpha_discrete("Significant \npredictor", labels=c("No", "Yes")) + 
  facet_grid(Vars~Site+AQ, scales="free") + 
  theme_classic(base_size=16)
dev.off()


## -------
## Get CAPE/PBL height outliers
## -------

# Atl
Atl <- read.csv("C:/Users/Jess/Desktop/Data_Diss/AtlG24_MAIACCldRUC.csv")
hist(Atl$cape_surface)
plot(Atl$cape_surface, log(Atl$X24hrPM))
hist(Atl$hpbl_surface)
plot(Atl$hpbl_surface, log(Atl$X24hrPM))


# SF 
SF <- read.csv("C://Users/Jess/Desktop/Data_Diss/CalifG24_MAIACCldRUC_10km.csv")
hist(SF$cape_surface)
plot(SF$cape_surface, log(SF$X24hrPM))
hist(SF$hpbl_surface)
plot(SF$hpbl_surface, log(SF$X24hrPM))


## --------
## Correlation plot/matrix
## --------

DatA <- read.csv("C://Users/Jess/Desktop/Data_Diss/Aqua2_Atl.csv", stringsAsFactors = F)
DatA1 = DatA[,c("LogPM", "CenteredTemp", "r_heightAboveGround", "WindSpeed", "cape2", "pblh", "Raining", "CloudEmmisivity", "CloudRadius", "CloudAOD", "CloudCatFin")]
colnames(DatA1) <- c("PM25", "Temp", "RH", "WindSpeed", "CAPE", "PBLheight", "Rain", "Emissivity", "DropRadius", "CloudAOD", "CloudCatFin")
WatMatAA = cor(DatA1[DatA1$CloudCatFin == "WaterCld",1:10])
IceMatAA = cor(DatA1[DatA1$CloudCatFin == "IceCld",1:10])
MaybeMatAA = cor(DatA1[DatA1$CloudCatFin == "MaybeCld" | DatA1$CloudCatFin == "UndetCld",1:10])

DatT <- read.csv("C://Users/Jess/Desktop/Data_Diss/Terra2_Atl.csv", stringsAsFactors = F)
DatT1 = DatT[,c("LogPM", "CenteredTemp", "r_heightAboveGround", "WindSpeed", "cape2", "pblh", "Raining", "CloudEmmisivity", "CloudRadius", "CloudAOD", "CloudCatFin")]
#colnames(DatT1) <- c("Ln(PM2.5)", "Temp (C)", "RH", "Wind Speed", "CAPE", "PBL height", "Rain", "Emissivity", "Droplet radius", "Cloud AOD")
WatMatTA = cor(DatT1[DatT1$CloudCatFin == "WaterCld",1:10])
IceMatTA = cor(DatT1[DatT1$CloudCatFin == "IceCld",1:10])
MaybeMatTA = cor(DatT1[DatT1$CloudCatFin == "MaybeCld" | DatT1$CloudCatFin == "UndetCld",1:10])

jpeg("C:/Users/Jess/Desktop/PlotCorr_WaterAtl.jpg")
corrplot(WatMatAA, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col = "black")
corrplot(WatMatTA, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()

jpeg("C:/Users/Jess/Desktop/PlotCorr_IceAtl.jpg")
corrplot(IceMatAA, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col="black")
corrplot(IceMatTA, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()

jpeg("C:/Users/Jess/Desktop/PlotCorr_MaybeAtl.jpg")
corrplot(MaybeMatAA, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col="black")
corrplot(MaybeMatTA, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()


DatA <- read.csv("C://Users/Jess/Desktop/Data_Diss/Aqua2_SF.csv", stringsAsFactors = F)
DatA1 = DatA[,c("LogPM", "CenteredTemp", "r_heightAboveGround", "WindSpeed", "cape2", "pblh", "Raining", "CloudEmmisivity", "CloudRadius", "CloudAOD", "CloudCatFin")]
colnames(DatA1) <- c("PM25", "Temp", "RH", "WindSpeed", "CAPE", "PBLheight", "Rain", "Emissivity", "DropRadius", "CloudAOD", "CloudCatFin")
WatMatAS = cor(DatA1[DatA1$CloudCatFin == "WaterCld",1:10])
IceMatAS = cor(DatA1[DatA1$CloudCatFin == "IceCld",1:10])
MaybeMatAS = cor(DatA1[DatA1$CloudCatFin == "MaybeCld" | DatA1$CloudCatFin == "UndetCld",1:10])

DatT <- read.csv("C://Users/Jess/Desktop/Data_Diss/Terra2_SF.csv", stringsAsFactors = F)
DatT1 = DatT[,c("LogPM", "CenteredTemp", "r_heightAboveGround", "WindSpeed", "cape2", "pblh", "Raining", "CloudEmmisivity", "CloudRadius", "CloudAOD", "CloudCatFin")]
#colnames(DatT1) <- c("Ln(PM2.5)", "Temp (C)", "RH", "Wind Speed", "CAPE", "PBL height", "Rain", "Emissivity", "Droplet radius", "Cloud AOD")
WatMatTS = cor(DatT1[DatT1$CloudCatFin == "WaterCld",1:10])
IceMatTS = cor(DatT1[DatT1$CloudCatFin == "IceCld",1:10])
MaybeMatTS = cor(DatT1[DatT1$CloudCatFin == "MaybeCld" | DatT1$CloudCatFin == "UndetCld",1:10])

jpeg("C:/Users/Jess/Desktop/PlotCorr_WaterSF.jpg")
corrplot(WatMatAS, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col = "black")
corrplot(WatMatTS, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()

jpeg("C:/Users/Jess/Desktop/PlotCorr_IceSF.jpg")
corrplot(IceMatAS, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col = "black")
corrplot(IceMatTS, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()

jpeg("C:/Users/Jess/Desktop/PlotCorr_MaybeSF.jpg")
corrplot(MaybeMatAS, method="square", type="upper", col=brewer.pal(n=10, "RdBu"), diag=T, tl.pos="t", tl.col="black")
corrplot(MaybeMatTS, method="square", type="lower", col=brewer.pal(n=10, "RdBu"), add=T, diag=F, tl.pos="n", cl.pos="n")
dev.off()
