# radar shiny app
library(tidyverse)
library(leaflet)
library(shiny)
library(lubridate)
library(hms)
library(shinyTime)

#source("scripts/get_local.R")


#ui



ui <- fluidPage(
  #Application Title
  titlePanel("Weather Radar"),
  
  fluidRow(column(12,
                  
                  sliderInput(
                    "date",
                    "Observation Date",
                    value = Sys.Date(),
                    min = as.Date("2020-08-01"),
                    max = Sys.Date(),
 
                    width = '100%'
                    
  )
  )),
  
  fluidRow(column(6,
                  timeInput(
                    "time",
                    "Time",
                    value = Sys.time(),
                    minute.steps = 10
                  ))),
  
  # fluidRow(column(12,
  #                 sliderInput(
  #                   "time",
  #                   "Time",
  #                   value = "12:00:00",
  #                   min = "1:00:00",
  #                   max = "24:00:00")
  # 
  #                 )),

  
  fluidRow(column(12,
                  
                  leaflet::leafletOutput("plot", width = '80%' , height = 600))
  )
)



#server

server <- function(input, output, session) {
  
  time <- reactive({
    
  })

  
  
  output$plot <- leaflet::renderLeaflet({
    leaflet() %>% 
    addTiles() %>% 
      addCircleMarkers(data = locations, radius = 3, color = "red") %>% 
      # addCircleMarkers(data = location_stations, color = "red",
      #                  stroke = TRUE, fillOpacity = 1) %>% 
      addWMSTiles(
        "https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0q-t.cgi?",
        layers = "nexrad-n0q-wmst",
        options = WMSTileOptions(format = "image/png", transparent = TRUE,
                                 time = as.POSIXct(paste(input$date, strftime(input$time, format="%H:%M")), 
                                                   format="%Y-%m-%d %H:%M"))
      )
                                 
    
  })
  
}




shinyApp(ui,server)


# try 'shinyTime r package to enter sepcific date and time and
# 'update' button so it only calls new radar image when ready. OR choose
# range and it forms an animation











