

require(shiny)
require(ggplot2)
require(dplyr)

# ScoreCard <- readRDS("Data/CollegeScoreCardAll.rds")

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
#
# CP <-
#   ScoreCard %>%
#   filter(UNITID %in% CalvinAndPeerIDs)
#
# CP$Institution <-
#   derivedFactor(
#       Calvin =   CP$UNITID == CalvinID,
#       Other  = ! CP$UNITID == CalvinID
#     )
# saveRDS(CP, file = "Data/CalvinAndPeersScoreCard.rds")
CP <- readRDS("Data/CalvinAndPeersScoreCard.rds")

