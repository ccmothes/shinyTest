#time loop test

library(bslib)
library(data.table)
readRDS("data/camPeakSimple.RDS")

ui <-   fluidPage(theme = bs_theme(bootswatch = "flatly"),
                  
                  #Application Title
                  titlePanel("Portal Demo"),
                  
                  fluidRow(column(12,
                                  
                                  sliderInput(
                                    "date",
                                    "Observation Date",
                                    value =as.Date("2021-08-01"),
                                    min = as.Date("2020-08-01"),
                                    max = as.Date("2021-08-01"),
                                    timezone = "-0600",
                                    width = '100%'
                                    
                                  )
                  )),
                  
                  fluidRow(column(6,
                                  sliderInput(
                                    "time",
                                    "Time",
                                    value = strptime("12:00", "%H:%M"),
                                    min = strptime("00:00", "%H:%M"),
                                    max = strptime("23:50", "%H:%M"),
                                    timeFormat = "%H:%M",
                                    timezone = "-0600",
                                    width = '100%',
                                    step = 900,
                                    animate = animationOptions(interval = 3000)
                                  ))),
                  
                  fluidRow(column(6,
                                  selectInput(
                                    "variable",
                                    "Variable",
                                    choices = c("Precipitation",
                                                "Snowfall",
                                                "Snow_depth",
                                                "Average_temp",
                                                "Minimum_temp",
                                                "Maximum_temp")
                                  ))),

                  fluidRow(column(12,
                                  
                                  leaflet::leafletOutput("plot", width = '80%' , height = 600))
                  )
)

  
server <-  function(input, output, session){
  
  data <- reactive({
    weather_coords %>% filter(date == input$date) %>% 
      dplyr::select(date, id, latitude, longitude, variable = input$variable) %>% 
      filter(!is.na(variable))
  })
  
  time <- reactive({
    # value <- dateToTimeList(time)
    paste(c(dateToTimeList(input$time)$hour, dateToTimeList(input$time)$min, 
            dateToTimeList(input$time)$sec), collapse = ':')
    
    
  })
  
  output$plot <- leaflet::renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addWMSTiles(
        "https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0q-t.cgi?",
        layers = "nexrad-n0q-wmst",
        options = WMSTileOptions(
          format = "image/png",
          transparent = TRUE,
          time = as.POSIXct(paste(input$date, time()),
                            format = "%Y-%m-%d %H:%M", tz = "UTC"),
          group = "Radar"
        )
      ) %>%
      addPolygons(
        data = st_transform(watersheds, 4326),
        color = "red",
        opacity = 1,
        popup = ~ Site,
        group = "watersheds"
      ) %>%
      addCircleMarkers(
        data = data(),
        lng = ~ longitude,
        lat = ~ latitude,
        radius = ~ sqrt(variable),
        color = "red",
        stroke = TRUE,
        fillOpacity = 1,
        popup = paste("Station:", data()$id, "<br>",
                      input$variable, data()$variable
                      ),
        group = "Weather Stations"
          
      ) %>% 
      addPolygons(
        data = camPeak_simple,
        color = NA,
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.9,
        fillColor = ~ colorFactor("Reds", Severity)(Severity),
        group = "Cameron Peak Fire"
      ) %>%
      addScaleBar() %>% 
      addLayersControl(overlayGroups = c("Watersheds", "Weather Stations",
                                         "Radar", "Cameron Peak Fire"),
                       options =layersControlOptions(collapsed = FALSE)
                       ) %>% 
      hideGroup(c("Weather Stations", "Radar", "Cameron Peak Fire"))
    

  })
  
}


shinyApp(ui,server)

  
