# load and manage data from local file

library(readr)
library(purrr)
library(dplyr)
library(sf)

#read in all daily excel files

daily_data <-
  map(list.files(
    path = "data/",
    pattern = "daily",
    full.names = TRUE
  ),
  read_csv) %>% set_names(c("Andrews", "Bighorn", "Dry", "Michigan", "Mill")) %>% 
  bind_rows(.id = "Site")

# read in locations and watersheds

locations <- read_sf("data/locations.shp")
watersheds <- read_sf("data/watersheds.shp")



#set bounding box around watersheds to pull images from
region <- ee$Geometry$BBox( -105.89218, 40.27989, -105.17284, 40.72316)

#create a list of mapping parameters

viz <-
  list(
    "True Color" = list(
      bands = c('B4', 'B3', 'B2'),
      min = 300,
      max = 1600
    ),
    "Snow Probability" = list(
      bands = c('MSK_SNWPRB'),
      min = 0,
      max = 1,
      palette = c("white", "Red")
    ),
    "Wildfire" = list(
      bands = c('B12', 'B8', 'B4'),
      min = 600,
      max = 2300
    )
  )


#convert watersheds and points to ee_object

watershed_ee <- sf_as_ee(watersheds)

locations_ee <- sf_as_ee(locations)

