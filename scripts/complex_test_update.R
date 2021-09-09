#time loop test

library(bslib)
library(data.table)
readRDS("data/camPeakSimple.RDS")





ui <- navbarPage(
  theme = bs_theme(bootswatch = "flatly"),
  
  "Portal Demon",
  id = "nav",
  
  tabPanel(
    "Interactive Map",
    # tags$style("
    #     #controls {
    #       background-color: #ddd;
    #       opacity: 0.5;
    #     }
    #     #controls:hover{
    #       opacity: 1;
    #     }
    #            "),
    leaflet::leafletOutput("map", width = '100%' , height = 800),
    
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 80,
      left = "auto",
      right = 20,
      bottom = "auto",
      width = 360,
      height = "auto",
      h4("Data Explorer"),
      style = "opacity: 0.9; background-color: white; padding: 0 20px 20px 20px",
      sliderInput(
        "date",
        "Observation Date",
        value = as.Date("2021-08-01"),
        min = as.Date("2020-08-01"),
        max = as.Date("2021-08-31"),
        timezone = "-0600",
        width = '100%'
        
      ),
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
      ),
      selectInput(
        "variable",
        "Variable",
        choices = c(
          "Precipitation",
          "Snowfall",
          "Snow_depth",
          "Average_temp",
          "Minimum_temp",
          "Maximum_temp"
        )
      ),
      plotlyOutput("plot")
    )
  ),
  tabPanel(
    "Sentinel Explorer",
    h2("This is where the Sentinel interactive map would go")
  )
)
server <-  function(input, output, session){
  
  
  weather <- reactive({
    weather_coords %>% filter(date == input$date) %>% 
      dplyr::select(date, id, latitude, longitude, variable = input$variable) %>% 
      filter(!is.na(variable))
  })
  
  time <- reactive({
    # value <- dateToTimeList(time)
    paste(c(dateToTimeList(input$time)$hour, dateToTimeList(input$time)$min, 
            dateToTimeList(input$time)$sec), collapse = ':')
  })

  
  output$map <- leaflet::renderLeaflet({
    leaflet() %>%
      addTiles(layerId = "A") %>%
      # addWMSTiles(
      #   "https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0q-t.cgi?",
      #   layers = "nexrad-n0q-wmst",
      #   options = WMSTileOptions(
      #     format = "image/png",
      #     transparent = TRUE,
      #     time = as.POSIXct(paste(input$date, time()),
      #                       format = "%Y-%m-%d %H:%M", tz = "UTC"),
      #     group = "Radar"
      #   )
      # ) %>%
      addPolygons(
        data = st_transform(watersheds, 4326),
        color = "red",
        opacity = 1,
        popup = ~ Site,
        group = "watersheds"
      ) %>%
      # addCircleMarkers(
      #   data = data(),
      #   lng = ~ longitude,
      #   lat = ~ latitude,
      #   radius = ~ sqrt(variable),
      #   color = "red",
      #   stroke = TRUE,
      #   fillOpacity = 1,
      #   popup = paste("Station:", data()$id, "<br>",
      #                 input$variable, data()$variable
      #                 ),
      #   group = "Weather Stations"
      #     
      # ) %>% 
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
      addScaleBar(position = "bottomright") %>% 

      addLayersControl(overlayGroups = c("Watersheds", "Weather Stations",
                                         "Radar", "Cameron Peak Fire"),
                       options =layersControlOptions(collapsed = FALSE)
                       ) %>%
      hideGroup(c("Weather Stations", "Radar", "Cameron Peak Fire"))
    

  })
  
  observe({
    
    
    leafletProxy("map") %>%
      clearMarkers() %>% 
    addCircleMarkers(
      data = weather(),
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

    )
  })
  
  observe({
    
    leafletProxy("map") %>% 
      removeTiles("B") %>% 
    addWMSTiles(
      layerId = "B",
      "https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0q-t.cgi?",
      layers = "nexrad-n0q-wmst",
      options = WMSTileOptions(
        format = "image/png",
        transparent = TRUE,
        time = as.POSIXct(paste(input$date, time()),
                          format = "%Y-%m-%d %H:%M", tz = "UTC"),
        group = "Radar"
      )
    )
    
    
  })
  
  rv <- reactiveValues()
  
  output$plot <- renderPlotly(
    plot_ly(watershed(), type = 'scatter', mode = 'lines')%>%
      add_trace(x = ~Date, y = ~input$choice)%>%
      layout(showlegend = F)
  )
}


shinyApp(ui,server)

  
