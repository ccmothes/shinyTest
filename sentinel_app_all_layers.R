#sentinel shiny

library(shiny)
library(rgee)

#ee_Initialize(user = 'ccmothes@gmail.com')


source("get_local.R")


#ui



ui <- fluidPage(#Application Title
  titlePanel("Sentinel Imagery"),
  
  fluidRow(column(
    8,
    sliderInput(
      "date",
      "Observation Range",
      min = as.Date("2020-01-01", "%Y-%m-%d"),
      max = Sys.Date(),
      value = c(
        as.Date("2021-06-01", "%Y-%m-%d"),
        Sys.Date()))
      )
    )
  ,
  
  fluidRow(column(4,
                  
                  leaflet::leafletOutput("true",  height = 600)),
  column(4,
         leaflet::leafletOutput("snow", height = 600)),
  column(4,
         leaflet::leafletOutput("fire", height = 600))))



#server

server <- function(input, output, session) {

  s2 <- reactive({
    ee$ImageCollection('COPERNICUS/S2_SR')$
      filterBounds(region)$
      filterDate(rdate_to_eedate(input$date[1]), rdate_to_eedate(input$date[2]))$
      filter(ee$Filter$lte("CLOUDY_PIXEL_PERCENTAGE", 10)) 
    
  })  
  

  
  output$true <- leaflet::renderLeaflet({
    Map$centerObject(region)
    #Map$addLayer(s2()$median(), visParams = viz$Wildfire, name = "Wildfire") +
      #Map$addLayer(s2()$median(),
                   #visParams = viz$`Snow Probability`,
                   #'Snow Probability') +
      Map$addLayer(s2()$median(), visParams = viz$`True Color`, 'True Color') +
      Map$addLayer(watershed_ee, "Watersheds", visParams = list(color = "Blue")) +
      Map$addLayer(locations_ee,
                   "Stream Gages",
                   visParams = list(color = "Pink",
                                    pointRadius = 10))
  })
  
  output$snow <- leaflet::renderLeaflet({
    Map$centerObject(region)
    
    Map$addLayer(s2()$median(),
    visParams = viz$`Snow Probability`,
    'Snow Probability') +
   
      Map$addLayer(watershed_ee, "Watersheds", visParams = list(color = "Blue")) +
      Map$addLayer(locations_ee,
                   "Stream Gages",
                   visParams = list(color = "Pink",
                                    pointRadius = 10))
  })
  
  output$fire <- leaflet::renderLeaflet({
    Map$centerObject(region)
    Map$addLayer(s2()$median(), visParams = viz$Wildfire, name = "Wildfire") +
    
      Map$addLayer(watershed_ee, "Watersheds", visParams = list(color = "Blue")) +
      Map$addLayer(locations_ee,
                   "Stream Gages",
                   visParams = list(color = "Pink",
                                    pointRadius = 10))
  })
}




shinyApp(ui,server)
