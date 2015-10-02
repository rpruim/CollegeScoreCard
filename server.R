
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

ScoreCard <- readRDS("Data/CollegeScoreCardAll.rds")

CalvinPeerIDs <- c(
  222178, 210669, 164562, 143084, 201195, 173160, 143358, 150163, 201654, 174747,
  173300, 144962, 205957, 173647, 170301, 145646, 203368, 213321, 192323, 219976,
  213996, 214175, 193584, 193973, 204635, 204936, 236230, 154235, 102049, 236577,
  167899, 174844, 216278, 152530, 174899, 150534, 204185, 209825, 152600, 149781
)

CalvinID <- 169080

CalvinAndPeerIDs <- union(CalvinID, CalvinPeerIDs)

smoothness <-
  c(.30, .32, .34, .36, .38,
    .40, .42, .44, .46, .48,
    .50, .54, .58, .62, .66,
    .71, .77, .84, .92, 1.0)

CP <-
  ScoreCard %>%
  filter(UNITID %in% CalvinAndPeerIDs) %>%
  mutate(
    Institution = derivedFactor(
      Calvin = UNITID == CalvinID,
      Other = ! UNITID == CalvinID
    ),
    UNITID = factor(UNITID)
  )

shinyServer(function(input, output) {

  mainData <- reactive({
    res <- select_(CP, "year", "INSTNM", "UNITID", input$yvar, "Institution")
    res[complete.cases(res), ] %>%
      group_by( UNITID ) %>%
      mutate( n = n() ) %>%
      filter( n > 5 )
  })

  hiliteData <- reactive({
    o <- 1:40
    mainData() %>%
      filter( UNITID ==
        CalvinPeerIDs[ o[input$institutionSlider] ] )
  })

  output$TSplot <- renderPlot({
    q <-
      if (input$smooth == "Yes") {
        ggplot() +
          geom_line(
            data = mainData(),
            stat = "smooth",
            span = smoothness[input$smoothness],
            method = "loess",
            aes_string(x = "year", y=input$yvar,
                       color = "Institution",
                       alpha = "Institution",
                       size = "Institution",
                       group = "UNITID"
            )
          ) +
          geom_line(
            data = hiliteData(),
            stat = "smooth",
            method = "loess",
            span = smoothness[input$smoothness],
            aes_string(x = "year", y=input$yvar),
            color = "goldenrod",
            alpha = 0.8,
            size = 1.2
          )
      } else {
        ggplot() +
          geom_line(
            data = mainData(),
            stat = "identity",
            aes_string(x = "year", y=input$yvar,
                       color = "Institution",
                       alpha = "Institution",
                       size = "Institution",
                       group = "UNITID"
            )
          ) +
          geom_line(
            data = hiliteData(),
            stat = "identity",
            aes_string(x = "year", y=input$yvar),
            color = "goldenrod",
            alpha = 0.8,
            size = 1.2
          )
      }
    q <- q +
      #      lims(y = c(0, 30000)) +
      scale_alpha_manual(values = c(1, .3)) +
      scale_size_manual(values = c(1.8, .4)) +
      scale_color_manual(values = c("maroon", "goldenrod")) +
      #  guides(color = FALSE) +
      theme_minimal()
    q
  })

  #  output$info <- renderText({
  #    paste0("x=", input$plot_hover$x, "\ny=", input$plot_hover$y)
  #  })

  output$institutionName <- renderText({
    id <- CalvinPeerIDs[input$institutionSlider]
    D <- CP %>% filter( UNITID == id ) %>% select(INSTNM) %>% tail()
    D$INSTNM[1]
  })

  output$data <- renderDataTable({
    hiliteData() %>% select_("INSTNM", "year", input$yvar)
  })

  output$info <- renderPrint({
    # With ggplot2, no need to tell it what the x and y variables are.
    # threshold: set max distance, in pixels
    # maxpoints: maximum number of rows to return
    # addDist: add column with distance, in pixels
    nearPoints(
      hiliteData(), input$plot_hover,
      threshold = 10, maxpoints = 1,
      addDist = TRUE) %>%
      select(INSTNM)
  })

})
