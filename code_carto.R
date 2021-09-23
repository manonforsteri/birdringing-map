#installer et ouvrir le package nécessaire
#un redémarrage de R peut être nécessaire
install.packages("birdring")
library(birdring)

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


#Bonus : pour "recarder" les cartes aux bonnes latitudes et longitudes
#vous pouvez utiliser les fonctions ci dessous, pour connaitre les 
#latitudes et longitudes min et max de votre jeu de données, 
#et garder les mêmes dimensions pour toutes les cartes
#il faut ensuite les modifier dans la formule ci-dessus dans le paramètre "bbox" :
#avec bbox=c(min lon, max long, min lat, max lat)

min(data_bird$lat)
max(data_bird$lat)
min(data_bird$lon)
max(data_bird$lon)


 