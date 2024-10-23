#A cheat sheet for opening, preprocessing and plotting spatial datasets in R

#Note:
#- This script must be modified to suit your data - it will not work without modification.
#- Capitalised text must be replaced.
#- You don't necessarily need all of this script for your project, chose which functions you want to use.

#Load required libraries
library(readr)
library(raster)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(tidyr)
library(rnaturalearth)
library(sf)

#load data from raw GBIF TSV
data <- read_delim("PATH TO FILE/FILENAME.tsv.csv", 
                   delim = "\t", escape_double = FALSE, 
                   trim_ws = TRUE) #Add file path to open

#Save as a CSV
write_csv(data, "PATH TO FILE/NEW_FILENAME.csv") #Add file path to be saved

#trim data to only columns of interest
trimmed_data <- select(data, genus, species, NAMES_OF_COLUMNS_YOU_WANT_TO_KEEP) #Add the names of columns you want to save

#remove rows with missing data - be careful, this will remove a whole row even if one cell has missing data
data_clean <- trimmed_data %>% drop_na()

#Filter data
#by numeric
data_atSea <- data_clean %>% filter(DEPTH_COLUMN_NAME > 10) #this removes all data less than 10m depth - adapt to what you want to do with your data
#by factor
data_iNat <- data_clean %>% filter(species == 'Hydrophis major') #only keeps H. major data - adapt to what you want to do with your data

#Convert a CSV to a shapefile 
seasnake_locations <- st_as_sf(data_clean, coords = c("decimalLongitude", "decimalLatitude"))

#Save shapefile
st_write(seasnake_locations,"PATH/FILENAME.shp")

#load an existing shapefile, such as from TomBio in QGIS
seasnake_locations <- read_sf("PATH TO FILE/FILENAME.shp")

#set CRS
st_crs(seasnake_locations) <- "+proj=longlat +ellps=WGS84 +datum=WGS84"

#sense-check plot
ggplot() +
  geom_sf(data = seasnake_locations)

#better plot
world_coordinates <- map_data("world") 
ggplot() + 
  geom_map( 
    data = world_coordinates, map = world_coordinates, 
    aes(long, lat, map_id = region) 
  ) +
  geom_sf(data = seasnake_locations, color = "red")+
  #geom_sf(data = OTHER_SPECIES_DATA, color = 'YOUR CHOICE OF COLOUR') #you can add in multiple species, but remember to include a legend
#You can make the above plot even better if you want to, there are plenty of ggplot tutorials online.

#heatmap
xy_coords = st_coordinates(seasnake_locations)
ggplot() + 
  geom_density_2d_filled(data = xy_coords, aes(x = xy_coords[,1], y = xy_coords[,2]))+
  geom_map( 
    data = world_coordinates, map = world_coordinates, 
    aes(long, lat, map_id = region) 
  )

#R plots can be saved using the 'Export' button on plot window.