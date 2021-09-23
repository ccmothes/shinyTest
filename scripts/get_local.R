# load and manage data from local file

library(readr)
library(purrr)
library(dplyr)
library(sf)

#read in all daily excel files

#updated data
sites <- c("andrews", "Bighorn", "Dry", "Michigan", "Mill")
names(sites) <- c("Andrews Creek", "Bighorn Creek", "Dry Creek", "Michigan River", "Mill Creek")

files <- vector("list", length = length(sites))


for (i in 1:length(sites)){
  
  files[[i]] <- purrr::map(list.files(
    path = "data/",
    pattern = sites[i],
    full.names = TRUE
  ), read_csv) %>% 
    purrr::map(function(x) mutate(x, Date = as.POSIXct(Date, format = "%m/%d/%Y"))) %>% 
    set_names(rep(names(sites[i]), length(.))) %>% 
    bind_rows(.id = "Site")
  
}

daily_data <- bind_rows(files)


#old data
# daily_data <-
#   purrr::map(list.files(
#     path = "data/",
#     pattern = "daily",
#     full.names = TRUE
#   ),
#   read_csv) %>% set_names(c("Andrews Creek", "Bighorn Creek", "Dry Creek", "Michigan River", "Mill Creek")) %>% 
#   bind_rows(.id = "Site") %>% 
#   mutate(Date = as.POSIXct(Date, format = "%m/%d/%Y"))

# read in locations and watersheds

locations <- read_sf("data/locations.shp")
watersheds <- read_sf("data/watersheds.shp")


#tie daily data to watersheds
daily_data <- left_join(watersheds, daily_data, by = "Site") %>% 
  st_transform(4326)

saveRDS(daily_data, "portal_demo/data/daily_data.RDS")



#read in water quality data

cp_coords <- read_csv("data/CamPeak_Coordinates.csv") %>% rename(Site =  SITE,
                                                                 long = "X_WGS84",
                                                                 lat = "Y_WGS84")
waterQual <- readxl::read_excel("data/CamPk_toMothes_trial.xlsx") %>% 
  left_join(cp_coords, by = "Site")
saveRDS(waterQual, "portal_demo/data/water_qual.RDS")


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

