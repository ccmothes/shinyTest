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
