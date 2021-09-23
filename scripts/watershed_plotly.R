# add watershed data plotly

library(plotly)

#combine daily data with watershed geometry

watershed_data <- left_join(daily_data, watersheds, by = "Site")


#filter to single site to demo with


dry <-
  daily_data %>% filter(Site == "Dry Creek") %>% #group_by(Date) %>%
  #summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE))) %>%
  mutate(Date = as.POSIXct(Date, format = "%m/%d/%Y"))

dry_test <- dry %>% dplyr::select(Date, P_mm) %>% filter(!is.na(Date)) %>% 
  filter(P_mm != "NaN")

#make plotly of variable over time

fig <- plot_ly(dry, type = 'scatter', mode = 'lines')%>%
  add_trace(x = ~Date, y = ~P_mm, name = 'Precipitation')%>%
  layout(showlegend = F)

fig <- fig %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    yaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6', width = 900)


# add weather data to ploty
weather_test <- weather_coords %>% filter(id == "USC00057296") %>% 
  mutate(date = as.POSIXct(date, format = "%m/%d/%Y"))

plot_ly() %>%
  add_lines(x = dry$Date, y = dry$P_mm, name = "Stream Data") %>% 
  add_lines(x = weather_test$date, y = weather_test$Precipitation, name = "Weather Data",
              yaxis = "y2", color=I("red"), opacity = 0.5) %>% 
  layout(title = "Data Test",
         yaxis2 = list(side = "right", title = "Weather Station Precipitation",
                       overlaying = "y"),
         yaxis = list(title = "Stream Gage Precipitation"))



#waterqual plotly

water_test <- water_qual %>% filter(Site == "Deadman")

plotly::plot_ly() %>%
  add_lines(x = water_test$Date,
            y = water_test$Turbidity,
            name = "Turbidity") %>%
  plotly::layout(yaxis = list(title = "Turbidity"),
                 xaxis = list(range = c(min(water_test$Date), max(water_test$Date)),
                              showgrid = T))
