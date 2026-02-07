# 0. Installation des packages nécessaires (à lancer uniquement la première fois)
install.packages(c("readxl", "tidyverse", "rnaturalearth", "rnaturalearthdata", "sf"))

# 1. Chargement des librairies
library(readxl)         # Pour ouvrir un fichier Excel
library(tidyverse)      # Comprend ggplot2, dplyr, et tout le nécessaire
library(rnaturalearth)  # Pour le fond de carte
library(sf)             # Pour gérer les coordonnées géographiques

# 2. Importation du fichier de données (tel qu'exporté par le CRBPO)
data_brute <- read_excel("GHISLAIN, Manon 2022030409h11h12.xls", sheet = 1)

# 3. Préparation et filtre des données
# Choix de l'espèce à cartographier (Code EURING en 6 lettres)
espece_choisie <- "ACRSCH"

data_carte <- data_brute %>%
  # On s'assure que les coordonnées sont bien numériques
  mutate(LAT = as.numeric(LAT), 
         LON = as.numeric(LON)) %>%
  # On filtre l'espèce
  filter(ESPECE == espece_choisie) %>%
  # On ne garde que les oiseaux vus au moins 2 fois
  group_by(BAGUE) %>%
  filter(n() > 1) %>%
  # On trie par date pour tracer les traits dans le bon ordre
  arrange(BAGUE, DATE) %>%
  ungroup()

# 4. Création de la carte

# Téléchargement du fond de carte (pays)
monde <- ne_countries(scale = "medium", returnclass = "sf")

# Calcul automatique des limites de la carte (avec une marge de 2 degrés autour des points)
limites_carte <- coord_sf(
  xlim = range(data_carte$LON, na.rm = TRUE) + c(-2, 2),
  ylim = range(data_carte$LAT, na.rm = TRUE) + c(-2, 2),
  expand = FALSE
)

# Le graphique
ggplot(data = data_carte) +
  # Le fond de carte (Terre et frontières)
  geom_sf(data = monde, fill = "antiquewhite", color = "grey70") +  #Couleur du sol et des côtes
  
  # Les trajets (Lignes reliant les points d'une même bague)
  geom_path(aes(x = LON, y = LAT, group = BAGUE), 
            color = "darkblue", alpha = 0.5, linewidth = 0.8) +
  
  # Les points (Colorés selon l'Action : B, C ou R)
  geom_point(aes(x = LON, y = LAT, color = ACTION), size = 3) +
  
  # Définition des couleurs des ACTION
  scale_color_manual(values = c("B" = "blue",    # Baguage en Bleu
                                "C" = "green4",  # Contrôle en Vert
                                "R" = "red")) +  # Reprise en Rouge
  
  # Mise en forme
  limites_carte +
  theme_bw() +
  theme(panel.background = element_rect(fill = "aliceblue"), # Couleur de l'eau
        legend.position = "right") +
  labs(title = paste("Mouvements de", espece_choisie),
       subtitle = "Données de Baguage-Contrôles",
       x = "Longitude", y = "Latitude", 
       color = "Type d'observation")
