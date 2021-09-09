# add watershed data plotly

library(plotly)

#combine daily data with watershed geometry

watershed_data <- left_join(daily_data, watersheds, by = "Site")


#filter to single site to demo with


dry <-
  watershed_data %>% filter(Site == "Dry Creek") %>% #group_by(Date) %>%
  #summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE))) %>%
  mutate(Date = as.POSIXct(Date, format = "%m/%d/%Y"))

dry_test <- dry %>% dplyr::select(Date, P_mm) %>% filter(!is.na(Date)) %>% 
  filter(P_mm != "NaN")

#make plotly of variable over time

fig <- plot_ly(dry_test, type = 'scatter', mode = 'lines')%>%
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



