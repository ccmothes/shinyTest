# base code for updating weather data

library(rnoaa)

options(noaakey = "VAOckuKZRAFPIOuippCpMBAUPTiAtVMn")



stations <- readRDS("data/location_stations.RDS")

weather_data <- readRDS("data/weather_data.RDS")


weather_data_new <- meteo_pull_monitors(stations$id, date_min = max(weather_data$date),
                                    date_max = Sys.Date())


weather_update <- bind_rows(weather_data, weather_data_new) %>% left_join(stations, by = "id") %>%
  mutate(Precipitation = prcp*0.1,
         Minimum_temp = tmin*0.1, Maximum_temp = tmax*0.1, Average_temp = tavg*0.1) %>% 
  dplyr::select(id, date, Precipitation, Snowfall = snow, Snow_depth = snwd,
                Minimum_temp, Maximum_temp, Average_temp, latitude,
                longitude)

saveRDS(weather_update, "data/weather_update.RDS")
saveRDS(weather_update, "portal_demo/data/weather_update.RDS")
