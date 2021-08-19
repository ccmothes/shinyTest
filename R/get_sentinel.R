# test sentinel data download

library(sen2r)
install.packages(c("leafpm", "mapedit", "shinyFiles", "shinydashboard", "shinyjs",
                   "shinyWidgets"))


source("R/get_local.R")

#list available sentinel products in watershed boundary

s2_list(
  spatial_extent = watersheds,
  time_interval = c("2021-8-01", "2021-08-19"),
  level = "L2A"
)


