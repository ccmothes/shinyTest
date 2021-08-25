#test out google earth engine

library(rgee)
library(magrittr)


rgee::ee_install()

ee_check() #everything okay, but note about version


ee_Initialize(user = 'ccmothes@gmail.com')


# get sentinel imagery and mask clouds

s2 <- ee$ImageCollection('COPERNICUS/S2_SR')

#create cloud mask function

getQABits <- function(image, qa) {
  # Convert binary (character) to decimal (little endian)
  qa <- sum(2^(which(rev(unlist(strsplit(as.character(qa), "")) == 1))-1))
  # Return a mask band image, giving the qa value.
  image$bitwiseAnd(qa)$lt(1)
}


#example from https://rdrr.io/github/csaybar/rgee/f/vignettes/rgee03.Rmd
images <- ee$ImageCollection("COPERNICUS/S2_SR")
sf <- ee$Geometry$Point(c(-122.463, 37.768))

# Expensive function to reduce the neighborhood of an image.
reduceFunction <- function(image) {
  image$reduceNeighborhood(
    reducer = ee$Reducer$mean(),
    kernel = ee$Kernel$square(4)
  )
}

bands <- list("B4", "B3", "B2")
# Select and filter first!
reasonableComputation <- images$select(bands)$
  filterBounds(sf)$
  filterDate("2018-01-01", "2019-02-01")$
  filter(ee$Filter$lt("CLOUDY_PIXEL_PERCENTAGE", 1))$
  aside(ee_print)$ # Useful for debugging.
  map(reduceFunction)$
  reduce('mean')$
  rename(bands)

viz <- list(bands = bands, min = 0, max = 10000)
Map$addLayer(reasonableComputation, viz, "resonableComputation")


#youtube demo

#use watershed shapefile as bounds
shp <- sf_as_ee(watersheds$geometry)
# not incorporating all of them for some reason...try this
bbox <- st_transform(watersheds, 4326) %>% 
  st_bbox() %>% 
  as.vector()

region <- ee$Geometry$BBox( -105.89218, 40.27989, -105.17284, 40.72316)

#import filtered sentinel data

# add cloud masking function...
getQABits <- function(image, qa) {
  # Convert decimal (character) to decimal (little endian)
  qa <- sum(2^(which(rev(unlist(strsplit(as.character(qa), "")) == 1))-1))
  # Return a single band image of the extracted QA bits, giving the qa value.
  image$bitwiseAnd(qa)$lt(1)
}

s2_clean <- function(img) {
  # Select only band of interest, for instance, B2,B3,B4,B8
  img_band_selected <- img$select("B[2-4|8]")
  
  # quality band
  ndvi_qa <- img$select("QA60")
  
  # Select pixels to mask
  quality_mask <- getQABits(ndvi_qa, "110000000000")
  
  # Mask pixels with value zero.
  img_band_selected$updateMask(quality_mask)
}

s2_sr <- ee$ImageCollection('COPERNICUS/S2_SR')$
  filterBounds(region)$
  filterDate('2021-07-01', rdate_to_eedate(Sys.Date()))$
  filter(ee$Filter$lte("CLOUDY_PIXEL_PERCENTAGE", 10))$
  map(s2_clean)



#VIZUALIZE
viz <- list(bands = c('B4', 'B3', 'B2'), min = 300, max = 1600)
viz2 <- list(bands = c('TCI_R', 'TCI_G', 'TCI_B'))
viz_snow <- list(bands = c('MSK_SNWPRB'))


Map$addLayer(s2_sr$mosaic(), viz, 'mosaic')
Map$addLayer(s2_sr$mosaic(), viz_snow, 'mosaic')+
  Map$addLayer(shp)

#final map
Map$centerObject(region)
  Map$addLayer(s2_sr$mosaic(), viz, 'mosaic')+
  Map$addLayer(shp)
  
#test what bands are plotted
viz <- list(bands = c('MSK_SNWPRB'), min = 0, max = 1, palette = c("white", "
#4acfed"), opacity = 0.8)

s2_sr <- ee$ImageCollection('COPERNICUS/S2_SR')$
  filterBounds(region)$
  filterDate('2021-07-25', '2021-08-20')$
  filter(ee$Filter$lte("CLOUDY_PIXEL_PERCENTAGE", 10))
  
Map$centerObject(region)
Map$addLayer(s2_sr$median(), viz$`True Color`, 'Wildfire')+
  Map$addLayer(watershed_ee, "Watersheds", visParams = list(color = "Blue"))+
  Map$addLayer(locations_ee, "Stream Gages", visParams = list(color = "Pink",
                                                              pointRadius = 10))

#map individual images
  
nimages <- s2_sr$size()$getInfo()
ic_date <- ee_get_date_ic(s2_sr)

s2_img <- vector("list", length = 15)
for (i in 1:15) {
  py_index <- index - 1
  s2_img[[i]] <- ee$Image(s2_sr$toList(1, py_index)$get(0))
}

map_list <- vector("list", length = 15)  
for (i in 1:15){
  map_list[[i]] <- Map$addLayer(s2_img[[i]], viz, 
                                name = as.character(ee_get_date_ic(s2_sr)$time_start[i]))
}

Reduce('+', map_list)
  




