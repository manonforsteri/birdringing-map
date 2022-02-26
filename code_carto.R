#installer et ouvrir le package nécessaire
#un redémarrage de R peut être nécessaire
install.packages("birdring")
library(birdring)

#si vous recevez un message d'erreur vous indiquant qu'il manque un package ("aucun package "..." est trouvé), 
#installez ce package avec la formule install.packages("nom du package"), puis relancez le script depuis le début
#il est possible que l'opération soit à répéter plusiers fois si plusieurs packages sont manquants.

#crér un dossier nommé "map bird ring"  sur votre ordinateur dans "mes documents"
#et y mettre le fichier de données, puis l'ouvrir : 
setwd("~/map bird ring")

#Créer un fichier en .CSV avec toutes vos données baguages/controles
#Pour simplifier l'importation, ne gardez dans ce fichier que les colonnes : 
# ACTION CENTRE       BAGUE       DATE ESPECE PAYS      LAT       LON
#vérifier qu'il n'y a pas de cases vides dans le fichier excel

#Importer le fichier
data_bird<-read.table("data_bird.csv", header = TRUE, sep = ";" ,
                         dec = ".", na.strings ="")

#Quelques modifs rapides pour le rendre compatible avec le package
head(data_bird)
data_bird$lat<-data_bird$LAT
data_bird$lon<-data_bird$LON
data_bird$metal.ring.info<-NA
data_bird$metal.ring.info[data_bird$ACTION=="B"]<-1
data_bird$metal.ring.info[data_bird$ACTION=="C"]<-4
data_bird$metal.ring.info[data_bird$ACTION=="R"]<-4
data_bird$ring<-data_bird$BAGUE
data_bird$scheme<-data_bird$CENTRE

#sélection des données présentes avec au moins un controle ou une reprise
bird_recapt<-as.data.frame(table(data_bird$BAGUE))
bird_recapt2<-bird_recapt[which(bird_recapt$Freq>1),]
data_bird<-data_bird[which(data_bird$BAGUE %in% bird_recapt2$Var1),]

#créer un tableau et sélectionner une espèce
acrsci<-data_bird[which(data_bird$ESPECE=="ACRSCI"),]
embsch<-data_bird[which(data_bird$ESPECE=="EMBSCH"),]
sylatr<-data_bird[which(data_bird$ESPECE=="SYLATR"),]


#tracer la carte (il faut juste modifier le nom de l'espèce)
#ça peut prendre un petit moment si vous avez beaucoup de données
draw.recmap(sylatr, points=1, lines=1, pcol="black", lcol="red",
            mercator=TRUE, bbox=c(-20, 40, 0, 70),
            projection= "mercator", border= "gray")




#Bonus : pour "recadrer" automatiquement les cartes aux bonnes latitudes et longitudes
#faire tourner ces lignes, en remplaçant l'espèce à la première ligne et dans la formule
coords<-sylatr

minlat<-min(coords$lat)-2
maxlat<-max(coords$lat)+2
minlon<-min(coords$lon)-2
maxlon<-max(coords$lon)+2
draw.recmap(sylatr, points=1, lines=1, pcol="black", lcol="red",
            mercator=TRUE,   projection= "mercator", border= "gray",
            bbox=c(minlon, maxlon, minlat, maxlat))






 
