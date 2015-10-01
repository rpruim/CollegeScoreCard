
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

  output$TSplot <- renderPlot({
    p <- ggplot(CP)
    if (input$smooth == "Yes") {
      p <- p +
        geom_line(
          stat = "smooth",
          se = FALSE,
          method = "loess",
          aes_string(x = "year", y = input$yvar,
                     colour = "UNITID",
                     size = "Institution", alpha = "Institution"))
    } else {
      p <- p +
        geom_line(
          aes_string(x = "year", y = input$yvar, group="UNITID",
                     colour = "Institution",
                     size = "Institution", alpha = "Institution"))
    }
    p <- p +
      scale_alpha_manual(values = c(1, .3)) +
      scale_size_manual(values = c(1.8, .4)) +
      scale_color_manual(values = c("maroon", rep("goldenrod", 40))) +
      theme_minimal()

    q <- CP %>%
      ggplot() +
      geom_line(
        stat = "smooth",
        method = "loess",
        aes_string(x = "year", y=input$yvar,
            color = "Institution",
            alpha = "Institution",
            size = "Institution",
            group = "UNITID"
        )
      ) +
      geom_line(
        data = CP %>% filter( UNITID == CalvinPeerIDs[input$institutionSlider] ),
        stat = "smooth",
        method = "loess",
        aes_string(x = "year", y=input$yvar),
        color = "black",
        alpha = 1.0,
        size = 1.2
      ) +
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

  output$info <- renderPrint({
    # With ggplot2, no need to tell it what the x and y variables are.
    # threshold: set max distance, in pixels
    # maxpoints: maximum number of rows to return
    # addDist: add column with distance, in pixels
    nearPoints(
      CP, input$plot_hover,
      threshold = 10, maxpoints = 1,
      addDist = TRUE) %>%
      select(INSTNM)
  })

})
