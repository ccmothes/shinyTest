# load and manage data from local file

library(readr)
library(purrr)
library(dplyr)
library(sf)

#read in all daily excel files

daily_data <-
  purrr::map(list.files(
    path = "data/",
    pattern = "daily",
    full.names = TRUE
  ),
  read_csv) %>% set_names(c("Andrews", "Bighorn", "Dry", "Michigan", "Mill")) %>% 
  bind_rows(.id = "Site")

# read in locations and watersheds

locations <- read_sf("data/locations.shp")
watersheds <- read_sf("data/watersheds.shp")



# #set bounding box around watersheds to pull images from
# region <- ee$Geometry$BBox( -105.89218, 40.27989, -105.17284, 40.72316)
# 
# #set mapping parameters
# viz <- list(bands = c('B4', 'B3', 'B2'), min = 300, max = 1600)
# 
# 

#convert watersheds and points to ee_object

# watershed_ee <- sf_as_ee(watersheds)
# 
# locations_ee <- sf_as_ee(locations)

