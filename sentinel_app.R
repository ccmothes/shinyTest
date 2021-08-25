#sentinel shiny

library(shiny)
library(rgee)

#ee_Initialize(user = 'ccmothes@gmail.com')


source("get_local.R")


#ui



ui <- fluidPage(
  #Application Title
  titlePanel("Sentinel Imagery"),
  
  fluidRow(column(10,

    sliderInput(
      "date",
      "Observation Range",
      min = as.Date("2020-01-01", "%Y-%m-%d"),
      max = Sys.Date(),
      value = c(
        as.Date("2021-07-01", "%Y-%m-%d"),
        Sys.Date()))
      )
    ),
  
  
  fluidRow(column(12,
      
    leaflet::leafletOutput("plot", width = '80%' , height = 600))
  )
)



#server

server <- function(input, output, session) {

  s2 <- reactive({
    ee$ImageCollection('COPERNICUS/S2_SR')$
      filterBounds(region)$
      filterDate(rdate_to_eedate(input$date[1]), rdate_to_eedate(input$date[2]))$
      filter(ee$Filter$lte("CLOUDY_PIXEL_PERCENTAGE", 10)) 
    
  })  
  

  
  output$plot <- leaflet::renderLeaflet({
    Map$centerObject(region)
      Map$addLayer(s2()$median(), visParams = viz$`True Color`, 'Sentinel 2') +
      Map$addLayer(watershed_ee, "Watersheds", visParams = list(color = "Blue")) +
      Map$addLayer(locations_ee,
                   "Stream Sensors",
                   visParams = list(color = "Yellow",
                                    pointRadius = 10))
  })
  
}




shinyApp(ui,server)
