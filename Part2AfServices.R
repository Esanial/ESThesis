##Diversity calculation with package entropart##

library(entropart)
#Data opening#

botadiv<-read.csv2("C:/Users/Elsa/Documents/Recherche/These/Datanalysis/ESThesis/Databota3.csv")
str(botadiv)

#Metacommunity creation#
#Pondération par la surface#
#Abundance#
abd<-table(botadiv$nom_arb,botadiv$code)
abd


#Metacommunity creation#
Metacom<-MetaCommunity(abd)
Metacom

#Alpha, Bêta and Gamma diversity for q=0#
q0<-DivEst(0,Metacom)
summary(q0)
str(q0)
plot(q0)
q0$CommunityAlphaDiversities

#Alpha, Bêta and Gamma diversity for q=1#
q1<-DivEst(1,Metacom)
summary(q1)

#Alpha, Bêta and Gamma diversity for q=2#
q2<-DivEst(2,Metacom)
summary(q2)
plot(q2)

test<-DivProfile(q.seq = seq(0, 2, 0.1), Metacom)
plot(test)



##Above-ground biomass calculation with package BIOMASS##

install.packages("BIOMASS",dependencies = TRUE)
library(BIOMASS)

biom<-read.csv2("C:/Users/Elsa/Documents/Recherche/These/Datanalysis/ESThesis/Databota3.csv")
str(biom)
Arbres<-as.data.frame(unique(biom$Espèce))
str(Arbres)
library(dplyr)


nomarb<-read.csv2("C:/Users/Elsa/Documents/Recherche/These/Datanalysis/ESThesis/Nomarbtot.csv")
str(nomarb)
biom2<-merge(biom,nomarb,by="nom_arb")
str(biom2)
#correct taxo#
??correctTAxo
Taxo<-correctTaxo(genus=biom2$Genre,species=biom2$Espèce)
table(biom2$Genre==biom2$genusCorr)
biom2$genusCorr<-Taxo$genusCorrected
table(biom2$Espèce==biom2$speciesCorr)
biom2$speciesCorr<-Taxo$speciesCorrected

#correction de la famille#
APG<-getTaxonomy(Taxo$genusCorrected,findOrder=T)
biom2$familyAPG<-APG$family
biom2$orderAPG<-APG$order
str(biom2)

dataWD<-getWoodDensity(genus=biom2$genusCorr,
                       species=biom2$speciesCorr,
                       stand=biom2$code)
table(factor(dataWD$levelWD))
biom2$WD=dataWD$meanWD
biom2$WDsd=dataWD$sdWD
str(biom2)

#Estimation de biomasse#
AGBtree<-computeAGB(D=biom2$diam,WD=biom2$WD,H=biom2$heig)
biom2$AGB=AGBtree
AGBtree

#Ajout des données de diversité dans un data.frame Finaldata#
#Conversion AGB en tableau de données#
Finaldata<-as.data.frame(tapply(biom2$AGB,biom2$code,sum))
Finaldata
#Ajout alphaq0 et q2#
Finaldata$alphaq0<-q0$CommunityAlphaDiversities
Finaldata$alphaq2<-q2$CommunityAlphaDiversities
names(Finaldata)[1]<-"AGB" 
plot(Finaldata$alphaq0,Finaldata$AGB)

plot(Finaldata$alphaq2,Finaldata$AGB)
