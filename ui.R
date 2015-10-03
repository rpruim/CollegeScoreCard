
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source("global.R")

shinyUI(fluidPage(
  # Application title
  titlePanel("College Score Card"),
  radioButtons("smooth", "Smooth?", choices = c("No", "Yes")),
  selectInput("yvar", label = "variable",
              choices = setdiff(names(CP), c("year", "Institution")), selected = "ACTMTMID"),
  sliderInput("institutionSlider", label = "Institution", value = 1, min = 1, max = 40),
  sliderInput("smoothness", label = "Smoothness", value = 10, min = 1, max = 20, step=1),
  textOutput("institutionName"),
  plotOutput("TSplot", hover = "plot_hover", click = "plot_click"),
  # verbatimTextOutput("info"),
  dataTableOutput("data")
))
