# 0. Installation des packages nécessaires (à lancer une seule fois)
install.packages(c("readxl", "tidyverse", "rnaturalearth", "rnaturalearthdata"))

# 1. Chargement des librairies
library(readxl)         # Pour ouvrir un fichier Excel
library(tidyverse)      # Comprend ggplot2, dplyr, et tout le nécessaire
library(rnaturalearth)  # Pour le fond de carte

# 2. Importation du fichier de données (tel qu'exporté par le CRBPO)
data_bird <- read_excel("GHISLAIN, Manon 2022030409h11h12.xls", sheet = 1)

# 3. Préparation des données 
# On s'assure que les coordonnées sont bien des nombres
data_bird$LAT <- as.numeric(data_bird$LAT)
data_bird$LON <- as.numeric(data_bird$LON)

# On sélectionne l'espèce et on filtre les oiseaux vus au moins 2 fois
# Remplacer "ACRSCH" avec l'espèce qui vous intéresse
data_carte <- data_bird %>%
  filter(ESPECE == "ACRSCH") %>%           # 1. On ne garde que l'espèce choisie
  group_by(BAGUE) %>%                      # 2. On groupe par n° de bague
  filter(n() > 1) %>%                      # 3. On garde ceux qui ont plus d'une ligne
  arrange(BAGUE, DATE) %>%                 # 4. On trie par date pour que le trait soit dans le bon sens
  ungroup()

# 4. Calcul automatique des limites de la carte 
limites <- coord_sf(
  xlim = range(data_carte$LON) + c(-2, 2), # Marge de 2 degrés longitude
  ylim = range(data_carte$LAT) + c(-2, 2), # Marge de 2 degrés latitude
  expand = FALSE
)

# 5. Création de la carte avec ggplot2
# On récupère le fond de carte mondial
monde <- ne_countries(scale = "medium", returnclass = "sf")

ggplot(data = data_carte) +
  # --- Couche 1 : Le fond de carte ---
  geom_sf(data = monde, fill = "antiquewhite", color = "grey70") + #couleur du sol et des côtes
  
  # --- Couche 2 : Les trajets ---
  # group = BAGUE dit à R : "Relie les points qui ont le même numéro de bague"
  geom_path(aes(x = LON, y = LAT, group = BAGUE), 
            color = "darkblue", alpha = 0.6, linewidth = 0.8) +  #couleur des traits
  
  # --- Couche 3 : Les points ---
  # On peut colorier selon l'action (Baguage, Contrôle ou Reprise)
  geom_point(aes(x = LON, y = LAT, color = ACTION), size = 2) +
  
  # --- Mise en forme ---
  limites +                            # Applique les limites de carte calculées plus haut
  theme_bw() +                         
  theme(panel.background = element_rect(fill = "aliceblue")) + # Couleur de l'eau
  labs(title = paste("Mouvements de", unique(data_carte$ESPECE)),
       subtitle = "Données de Baguage-Contrôles",
       x = "Longitude", y = "Latitude", 
       color = "Action")
