#time loop test

library(shiny)
library(bslib)
library(dplyr)
library(leaflet)
library(plotly)
library(readr)
library(sf)
library(shinyWidgets)
library(stringr)

camPeak_simple <- readRDS("data/camPeakSimple.RDS")

weather_data <- readRDS("data/weather_update.RDS") %>% 
  rename(Site = id, Date = date, long = longitude, lat = latitude) %>% 
  mutate(source = "NOAA")

water_data <- readRDS("data/water_data.RDS") %>% arrange(Date) %>% 
  mutate(source_spec = if_else(source == "CSU_Kampf", "CSU-Stephanie Kampf", source)) %>%
  mutate(source = if_else(source == "CSU_Kampf", "CSU", source)) %>% 
  mutate(p = if_else(!(is.na(precip_mm)), "Precipitation", "")) %>% 
  mutate(s = if_else(!(is.na(stage_cm)), "Streamflow", "")) %>% 
  mutate(d = if_else(!(is.na(discharge_Ls)), "Streamflow", "")) %>% 
  mutate(t = if_else(!(is.na(Turbidity)), "Water Quality", "")) %>% 
  mutate(p2 = if_else(!(is.na(pH)), "Water Quality", "")) %>% 
  mutate(d2 = if_else(!(is.na(DO)), "Water Quality", "")) %>% 
  mutate(c = if_else(!(is.na(Conductivity)), "Water Quality", "")) %>% 
  mutate(category = paste(p,s,d,t,p2,d2,c))
  
  
  
  
  

sites <- water_data %>% distinct(Site, .keep_all = TRUE) %>% dplyr::select(Site, source, long, lat)


#from shinyTime:
dateToTimeList <- function(value){
  if(is.null(value)) return(NULL)
  posixlt_value <- unclass(as.POSIXlt(value))
  time_list <- lapply(posixlt_value[c('hour', 'min', 'sec')], function(x) {
    sprintf("%02d", trunc(x))
  })
  return(time_list)
}




ui <- navbarPage(
  theme = bslib::bs_theme(
    bootswatch = "flatly",
    #bg = "#FFFFFF",
    #fg = "#000",
    primary = "#186D03",
    secondary = "#DD5B27",
    success = "#f28e35",
    base_font = font_google("Cairo")
  ) %>% 
    bslib::bs_add_rules(" label.control-label {
        font-size: 15px;
        font-weight: bold;
      }
      i.glyphicon.glyphicon-play {
      color: #e1210d; line-height: 2}
      i.glyphicon.glyphicon-pause {
      color: #e1210d; line-height: 2}
      a#bs-select-1-0.dropdown-item {
      color: #d92809}
      a#bs-select-1-1.dropdown-item {
      color: #f5a04c}
      a#bs-select-1-2.dropdown-item {
      color: #88db7d}
      a#bs-select-1-3.dropdown-item {
      color: #1c73a6}
      "),

  
  "Poudre Portal Demo",
  id = "nav",
  
  tabPanel("Data Explorer",
           # tags$style("
           #     #controls {
           #       background-color: #ddd;
           #       opacity: 0.5;
           #     }
           #     #controls:hover{
           #       opacity: 1;
           #     }
           #            "),
           
           fluidPage(#sidebarLayout(
             #position = "right",
             # tags$head(
             #   tags$style(type = "text/css", "#weatherVar {color: orange}"
             #                  )),
                               
                               
             #                   .selectize-input {
             #                   white-space: nowrap;
             #                   font-weight: bold;
             #                   height: 25px;
             #                   width: 150px;
             #                   padding: 0}
             #                   "))
             # ),
             fluidRow(
               column(4,
                      tabsetPanel(
                        tabPanel(
                          "Map",
                          leaflet::leafletOutput("map1", width = '100%' , height = 400)
                      ),
                      tabPanel("Table", div(DT::dataTableOutput("table"), style = "font-size:80%")
                      )),
               em("Click on an object to view time series plots to the right"),
               hr(),
               actionButton("clear", "Clear Plots"),
               br(),
               br(),
               pickerInput("sourceChoice", "Filter by Source:",
                          choices = c("CSU", "FoCo", "USFS", "USGS"),
                          selected = c("CSU", "FoCo", "USFS", "USGS"),
                          multiple = TRUE),
               checkboxGroupButtons(
                 inputId = "varChoice",
                 label = "Filter by Category:",
                 choices = c("Precipitation", "Snow", "Streamflow", "Water Quality", "Temperature"),
                 selected = c("Precipitation", "Snow", "Streamflow", "Water Quality", "Temperature"),
                 direction = "horizontal",
                 individual = TRUE,
                 status = "primary",
                 checkIcon = list(
                   yes = icon("check-square"),
                   no = icon("square-o")
                 ))
               # checkboxGroupInput("varChoice", label = "Filter by Category",
               #                    choices = c("Precipitation", "Snow", "Streamflow", "Water Quality", 'Temperature'))
               
              
               ),

                column(8,
                       # checkboxGroupButtons(
                       #   inputId = "varChoice",
                       #   label = "Filter by Category:",
                       #   choices = c("Precipitation", "Snow", "Streamflow", "Water Quality", "Temperature"),
                       #   checkIcon = list(
                       #     yes = icon("check-square"),
                       #     no = icon("square-o")
                       #   )),
                      
                       # checkboxGroupButtons(
                       #   inputId = "varChoice", label = "",
                       #   choices = c("Precipitation", "Snow", "Streamflow", "Water Quality"),
                       #   justified = TRUE, status = c("danger"), individual = TRUE,
                       #   checkIcon = list(yes = icon("ok", lib = "glyphicon"), no = icon("remove", lib = "glyphicon"))
                       # ),
                       fluidRow(
                        sliderInput(
                          "range",
                          "",
                          value = c(as.Date("2020-01-01"), as.Date("2021-10-01")),
                          min = as.Date("2015-10-01"),
                          max = as.Date("2021-10-01"),
                          timezone = "-0600",
                          width = '100%'
                          
                        ),
                        p(strong("Precipitation")),
                        
                        plotlyOutput("precip", width = "100%", height = 120),
                       
                        selectInput(
                          "weatherVar",
                          "NOAA Weather Stations",
                          choices = c(
                            "Precipitation",
                            "Snowfall",
                            "Snow Depth" = "Snow_depth",
                            "Minimum Temperature" = "Minimum_temp",
                            "Maximum Temperature" = "Maximum_temp",
                            "Average Temperature" = "Average_temp"
                          ),
                          selected = "Snowfall"
                        ),
                       #tags$style(type = "text/css", "#weatherVar {color: orange}"),
                        plotlyOutput("noaa", width = "100%", height = 150),
                        selectInput(
                          "streamVar",
                          "Streamflow",
                          choices = c("Discharge" = "discharge_Ls",
                                      "Stage" = "stage_cm")
                        ),
                        
                        plotlyOutput("q", width = "100%", height = 150),
                        selectInput(
                          "qual",
                          "Water Quality",
                          choices = c(
                            "Turbidity" = "Turbidity",
                            "pH" = "pH",
                            "DO" = "DO",
                            "Conductivity" = "Conductivity"
                          )
                        ),
                        plotlyOutput("waterQual", width = "100%", height = 150),
                        # h4(
                        #   "NOAA Weather Viewer"
                        # ),
                        
                        
                        strong("Note: some data may be missing for certain dates/variables")
                        #plotlyOutput("plot1", width = "100%")
                        
                      )
                )
             ))),
  
  tabPanel(
    "Interactive Map",
    
    sidebarLayout(
      position = "right",
      
      mainPanel(leaflet::leafletOutput(
        "map2", width = '100%' , height = 800
      )),
      sidebarPanel(
        # strong(
        #   "This map will also include a Sentinel Imagery explorer and the ability to turn on/off datasets to view study site/sensor locations"
        # ),
        
        #setSliderColor(color = c("LightGray", "LightGray"), sliderId = c(2,3)),
        
        # absolutePanel(
        #   id = "controls",
        #   class = "panel panel-default",
        #   fixed = TRUE,
        #   draggable = TRUE,
        #   top = 90,
        #   left = 20,
        #   right = "auto",
        #   bottom = "auto",
        #   width = 500,
        #   height = "auto",
        #   style = "opacity: 0.9; background-color: white; padding: 0 20px 20px 20px",
        switchInput(inputId = "radarButton", label = "Radar", value = FALSE, inline = TRUE,
                    onStatus = "success", offStatus = "danger"),
        sliderInput(
          "date",
          label = "Observation Date:",
          value = as.Date("2021-08-30"),
          min = as.Date("2015-10-01"),
          max = Sys.Date(),
          dragRange = FALSE,
          timezone = "-0600",
          width = '100%'
          
        ),
        
        sliderInput(
          "time",
          "Time (MST):",
          value = strptime("12:00", "%H:%M"),
          min = strptime("00:00", "%H:%M"),
          max = strptime("23:50", "%H:%M"),
          timeFormat = "%H:%M",
          timezone = "-0600",
          width = '100%',
          step = 900, 
          animate = animationOptions(interval = 3000, loop = TRUE)
        ),
        selectInput(
          "variable",
          "Weather Variable:",
          choices = c(
            "Precipitation",
            "Snowfall",
            "Snow Depth" = "Snow_depth",
            "Minimum Temperature" = "Minimum_temp",
            "Maximum Temperature" = "Maximum_temp",
            "Average Temperature" = "Average_temp"
          )
        ),
        em("Circle size represents variable value"),
        hr(),
        br(),
        p("Link to Sentinel Explorer", a(href="", "here"), em("(not active yet)"))
      )
      
    )
  )
)


server <-  function(input, output, session){
  
  weather1 <- reactive({
    weather_data %>% filter(Date == input$range) %>% 
      dplyr::select(Date, Site, lat, long, variable = input$weatherVar) %>% 
      filter(!(is.na(variable)))
    
  })
  
  weather2 <- reactive({
    weather_data %>% filter(Date == input$date) %>%
      dplyr::select(Date, Site, lat, long, variable = input$variable) %>%
      filter(!is.na(variable))
  })
  
  time <- reactive({
    # value <- dateToTimeList(time)
    paste(c(dateToTimeList(input$time)$hour, dateToTimeList(input$time)$min, 
            dateToTimeList(input$time)$sec), collapse = ':')
  })
  
  
  water_data_filtered <- reactive({
    
    if(is.null(input$varChoice))
      return(water_data %>% filter(is.na(category)))
    
    water_data %>% filter(source %in% input$sourceChoice) %>% 
      filter(str_detect(category, input$varChoice))
  })
  
  
  Precipitation <- c("Precipitation", "precip_mm")
  Snow <- c("Snow", "Snowfall", "Snow_depth")
  Streamflow <- c("Streamflow", "stage_cm", "discharge_Ls")
  WaterQuality <- c("Water Quality", "Turbidity", "pH", "DO", "Conductivity")
  Temperature <- c("Temperature", "Minimum_temp", "Maximum_temp", "Average_temp")
  
  # weather_data_filtered <- reactive({
  #   
  #   
  # })
    
  

  pal <- colorFactor(palette = "Spectral", water_data$source)
  
  output$map1 <- leaflet::renderLeaflet({
    leaflet() %>%
      addTiles(group = "Open Street Map") %>%
      addProviderTiles("Esri.WorldImagery", layerId = "C", group = "Satellite") %>%
      addWMSTiles(
        sprintf(
          "https://%s/arcgis/services/%s/MapServer/WmsServer",
          "basemap.nationalmap.gov",
          "USGSTopo"
        ),
        group = "USGS Topo",
        attribution = paste0(
          "<a href='https://www.usgs.gov/'>",
          "U.S. Geological Survey</a> | ",
          "<a href='https://www.usgs.gov/laws/policies_notices.html'>",
          "Policies</a>"
        ),
        layers = "0"
      ) %>% 
      addMapPane("fire", zIndex = 410) %>%
      addMapPane("water", zIndex = 440) %>%
      addMapPane("weather", zIndex = 430) %>%
      addPolygons(
        data = camPeak_simple,
        color = NA,
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.9,
        fillColor = ~ colorFactor("Reds", Severity)(Severity),
        group = "Cameron Peak Fire",
        options = pathOptions(pane = "fire")
      ) %>%
      # addCircleMarkers(
      #   data = water_data,
      #   layerId = ~ Site,
      #   lng = ~ long,
      #   lat = ~ lat,
      #   radius = 6,
      #   color = "black",
      #   fillColor = ~ pal(source),
      #   stroke = TRUE,
      #   weight = 1,
      #   fillOpacity = 1,
      #   popup = paste(
      #     "Source:",
      #     water_data$source_spec,
      #     "<br>",
      #     "Site:",
      #     water_data$Site
      #   ),
      # 
      #   options = pathOptions(pane = "water")
      # ) %>%
      # addCircleMarkers(
      #   data = weather1(),
      #   layerId = ~Site,
      #   lng = ~ long,
      #   lat = ~ lat,
      #   radius = 4,
      #   color = "black",
      #   fillColor = "gray50",
      #   stroke = TRUE,
      #   weight = 1,
      #   fillOpacity = 0.6,
      #   popup = paste("Station:", weather1()$Site
      #   ),
      #   group = "Weather Stations",
      #   options = pathOptions(pane = "weather")) %>%
    addLegend("topright", data = weather1(), colors = "black", group = "Weather Stations", labels = "NOAA Weather Stations") %>% 
    
      # addLegend("bottomright", data = daily_data, group = "watersheds", colors = "blue", labels = "Watersheds") %>%
      # addLegend("bottomright", data = water_qual, group = "Water Quality Censors", colors = "yellow", labels = "Water Quality Sensors") %>%
      # addLegend("bottomright", values = camPeak_simple, group = "Cameron Peak Fire", pal = ~ colorFactor("Reds", Severity)(Severity)) %>%
      addLegend("topright", data = water_data, values = ~source, 
                pal = pal, title = "Data source") %>% 
      
      addScaleBar(position = "bottomright") %>%
      
      addLayersControl(
        baseGroups = c("USGS Topo", "Open Street Map", "Satellite"),
        overlayGroups = c(
          "Weather Stations", "Cameron Peak Fire"
          
        ),
        position = "topleft",
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      hideGroup(c("Cameron Peak Fire"))
    
  })
  
  # observe({
  #   
  #   leafletProxy("map1") %>% 
  #     
  #     addCircleMarkers(
  #       data = water_data_filtered(),
  #       layerId = ~ Site,
  #       lng = ~ long,
  #       lat = ~ lat,
  #       radius = 6,
  #       color = "black",
  #       fillColor = ~ pal(source),
  #       stroke = TRUE,
  #       weight = 1,
  #       fillOpacity = 1,
  #       popup = paste(
  #         "Source:",
  #         water_data_filtered()$source_spec,
  #         "<br>",
  #         "Site:",
  #         water_data_filtered()$Site
  #       ),
  #       
  #       options = pathOptions(pane = "water")
  #     )
  #     
  #     
  # })
  
  output$table <- DT::renderDataTable(sites, rownames = FALSE,
                                      options = list(autoWidth = TRUE, scrollX = TRUE,
                                      scrollY = "200px", scrollCollapse = TRUE,
                                      paging = FALSE, float = "left"),
                                      width = "80%", height = "70%")
  
  
  tableProxy <- DT::dataTableProxy("table")
    
  #   output$table <- DT::renderDataTable({
  #     DT::datatable(
  #     round(data.frame(replicate(50, runif(1000, 0, 10))), 2),
  #     rownames = TRUE,
  #     extensions = 'Buttons',
  #     options = list(
  #       autoWidth = FALSE, scrollX = TRUE,
  #       columnDefs = list(list(
  #         width = "125px", targets = "_all"
  #       )),
  #       dom = 'tpB',
  #       lengthMenu = list(c(5, 15,-1), c('5', '15', 'All')),
  #       pageLength = 15,
  #       buttons = list(
  #         list(
  #           extend = "collection",
  #           text = 'Show More',
  #           action = DT::JS(
  #             "function ( e, dt, node, config ) {
  #                             dt.page.len(50);
  #                             dt.ajax.reload();}"
  #           )
  #         ),
  #         list(
  #           extend = "collection",
  #           text = 'Show Less',
  #           action = DT::JS(
  #             "function ( e, dt, node, config ) {
  #                             dt.page.len(10);
  #                             dt.ajax.reload();}"
  #           ))
  #       )))
  #   
  #   
  # })
  

  observe({

    input$nav

    tab1 <- leafletProxy("map1") %>%
      #removeMarker("Weather Stations") %>%
      clearMarkers() %>% 
    addCircleMarkers(
      data = weather1(),
      layerId = ~Site,
      lng = ~ long,
      lat = ~ lat,
      radius = 4,
        color = "black",
        fillColor = "gray50",
        stroke = TRUE,
        weight = 1,
        fillOpacity = 0.6,
        popup = paste("Station:", weather1()$Site
        ),
        group = "Weather Stations",
        options = pathOptions(pane = "weather")) %>%
      #addLegend("topright", data = weather1(), colors = "black", group = "Weather Stations", labels = "NOAA Weather Stations")
      addCircleMarkers(
              data = water_data_filtered(),
              layerId = ~ Site,
              lng = ~ long,
              lat = ~ lat,
              radius = 6,
              color = "black",
              fillColor = ~ pal(source),
              stroke = TRUE,
              weight = 1,
              fillOpacity = 1,
              popup = paste(
                "Source:",
                water_data_filtered()$source_spec,
                "<br>",
                "Site:",
                water_data_filtered()$Site
              ),
              group = "water",

              options = pathOptions(pane = "water")
            )

      tab2 <- leafletProxy("map2") %>%
        clearMarkers() %>%
        addCircleMarkers(
                data = weather2(),
                layerId = ~Site,
                lng = ~ long,
                lat = ~ lat,
                radius = ~ sqrt(variable),
                color = "black",
                weight = 4,
                stroke = TRUE,
                fillOpacity = 1,
                fillColor = "black",
                popup = paste("Station:", weather2()$Site, "<br>",
                              paste0(input$variable, ":"), weather2()$variable,
                              if(input$variable %in% c("Precipitation", "Snowfall",
                                                       "Snow_depth")) {"mm"} else {"degrees Celcius"}
                ),
                group = "Weather Stations",
                options = pathOptions(pane = "weather")

              )


  })


  # plotlys
  
  df <- reactiveVal(bind_rows(water_data, weather_data) %>% mutate(key = 1:nrow(.)))
  combined <- reactiveVal(data.frame())
  
  
  filtered_df <- reactive({
    res <- df() %>% filter(as.Date(Date) >= input$range[1] & as.Date(Date) <= input$range[2])
    #res <- res %>% rename(streamflow = input$streamVar, quality = input$qual)
    res
    
    
  })
  
  observeEvent(input$map1_marker_click, {
    
    combined(bind_rows(combined(),
                       filtered_df() %>% 
                         #df() %>% filter(key %in% filtered_df()$key) %>%
                         filter(Site == input$map1_marker_click))) 
    
    
    #df(df() %>% filter(!key %in% filtered_df()$key))
    
  })
  
  observeEvent(input$table_rows_selected, {
    
    tableSelected <- sites[input$table_rows_selected,]
    
    combined(bind_rows(combined(),
                       filtered_df() %>% 
                         filter(Site %in% tableSelected$Site)))
  })
  
  final_df <- reactive({
    combined() %>% rename(streamflow = input$streamVar, quality = input$qual,
                          weather = input$weatherVar)
    
  })
  
  
  
  output$precip <- renderPlotly({
    
    
    if(nrow(combined()) == 0)
      return(NULL)
    
    
    plotly::plot_ly() %>% 
      add_bars(x = combined()$Date, y = combined()$precip_mm, name = ~combined()$Site,
               color = ~ combined()$Site) %>% 
      plotly::layout(yaxis = list(title = "P (mm)", autorange = "reversed"),
                     xaxis = list(range = c(input$range[1], input$range[2]),
                                  showgrid = TRUE))
    
  })
  
  output$q <- renderPlotly({
    
    
    if(nrow(combined()) == 0)
      return(NULL)
    
    plot_ly() %>%
      add_lines(x = final_df()$Date,
                y = final_df()$streamflow,
                name = ~final_df()$Site,
                linetype = ~ final_df()$Site) %>%
      plotly::layout(yaxis = list(title = input$streamVar),
                     xaxis = list(range = c(input$range[1], input$range[2]),
                                  showgrid = T))
    
    
  })
  
  
  
  
  output$waterQual <- renderPlotly({
    
    if(nrow(combined()) == 0)
      return(NULL)
    
    if(!(input$qual %in% names(combined())))
      return(NULL)
    
    plotly::plot_ly() %>%
      add_lines(x = final_df()$Date,
                y = final_df()$quality,
                name = ~final_df()$Site,
                mode = 'lines+markers',
                linetype = ~ final_df()$Site) %>%
      plotly::layout(yaxis = list(title = input$qual),
                     xaxis = list(range = c(input$range[1], input$range[2]),
                                  showgrid = T))
    
    
  })
  
  
  
  output$noaa <- renderPlotly({
    
    if(nrow(combined()) == 0)
      return(NULL)
    
    if(!(input$weatherVar %in% names(combined())))
      return(NULL)
    
    
    if(input$weatherVar == "Precipitation"){
      
      plotly::plot_ly() %>%
        add_bars(x = final_df()$Date, y = final_df()$weather, name = ~ final_df()$Site,
                 color = ~ final_df()$Site) %>%
        plotly::layout(yaxis = list(title = "P (mm)", autorange = "reversed"),
                       xaxis = list(range = c(input$range[1], input$range[2]),
                                    showgrid = TRUE))
    }else {
      
      plot_ly() %>%
        add_lines(x = final_df()$Date,
                  y = final_df()$weather,
                  name = ~ final_df()$Site) %>%
        plotly::layout(yaxis = list(title = input$weatherVar),
                       xaxis = list(range = c(input$range[1], input$range[2]),
                                    showgrid = T))
      
      
    }
    
    
    
  })
  
  
  observeEvent(input$clear, {
    combined(data.frame())
    
    tableProxy %>% DT::selectRows(NULL)
    
  })
  
  
    # 
    # #map tab ------------------------ 
    # 
    # 
    output$map2 <- leaflet::renderLeaflet({
      leaflet() %>%
        addTiles(layerId = "A", group = "Open Street Map") %>%
        addProviderTiles("Esri.WorldImagery", layerId = "C", group = "Satellite") %>%
        addWMSTiles(
          sprintf(
            "https://%s/arcgis/services/%s/MapServer/WmsServer",
            "basemap.nationalmap.gov",
            "USGSTopo"
          ),
          group = "USGS Topo",
          attribution = paste0(
            "<a href='https://www.usgs.gov/'>",
            "U.S. Geological Survey</a> | ",
            "<a href='https://www.usgs.gov/laws/policies_notices.html'>",
            "Policies</a>"
          ),
          layers = "0"
        ) %>%
        addMapPane("fire", zIndex = 410) %>%
        addMapPane("water", zIndex = 430) %>%
        addMapPane("weather", zIndex = 420) %>%
        addPolygons(
          data = camPeak_simple,
          color = NA,
          weight = 1,
          smoothFactor = 0.5,
          opacity = 1.0,
          fillOpacity = 0.9,
          fillColor = ~ colorFactor("Reds", Severity)(Severity),
          group = "Cameron Peak Fire",
          options = pathOptions(pane = "fire")
        ) %>%
        addScaleBar(position = "bottomright") %>%
        addLegend(pal = colorNumeric(palette = c("#646464", "#04e9e7", "#019ff4", "#0300f4",
                                                 "#02fd02", "#01c501", "#008e00", "#fdf802",
                                                 "#e5bc00", "#fd9500", "#fd0000", "#d40000",
                                                 "#bc0000", "#f800fd", "#9854c6", "#fdfdfd"),
                                     domain = c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75)),
                  values = c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75),
                  title = "Radar Base Reflectivity (dBZ)",
                  position = "bottomright", group = "Radar") %>% 

        addLayersControl(
          baseGroups = c("USGS Topo", "Open Street Map", "Satellite"),
          overlayGroups = c("Cameron Peak Fire", "Weather Stations", "Radar"),
          position = "topright",
          options = layersControlOptions(collapsed = TRUE)
        ) %>%
        hideGroup(c("Cameron Peak Fire", "Radar"))



    })

    # observe({
    # 
    #   leafletProxy("map2") %>%
    #     clearMarkers() %>%
    #     addCircleMarkers(
    #       data = weather2(),
    #       layerId = ~Site,
    #       lng = ~ long,
    #       lat = ~ lat,
    #       radius = ~ sqrt(variable),
    #       color = "red",
    #       stroke = TRUE,
    #       fillOpacity = 1,
    #       popup = paste("Station:", weather2()$Site, "<br>",
    #                     input$variable, weather2()$variable
    #       ),
    #       group = "Weather Stations",
    #       options = pathOptions(pane = "weather")
    # 
    #     )
    # })
    # 
  
  observe({
    
    if(input$radarButton == TRUE)
      leafletProxy("map2") %>%
      showGroup("Radar") %>% 
      removeTiles(layerId = "B") %>% 
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
    
    if(input$radarButton == FALSE)
      leafletProxy("map2") %>% 
      clearControls() %>% 
      removeTiles(layerId = "B")
  })
  


}


shinyApp(ui,server)

  
