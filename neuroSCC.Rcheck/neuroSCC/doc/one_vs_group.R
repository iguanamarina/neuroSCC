## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
library(neuroSCC)

## -----------------------------------------------------------------------------
cat("Creating required matrices from sample data...\n")

databaseControls <- databaseCreator(pattern = "^syntheticControl.*\\.nii\\.gz$", control = TRUE, quiet = TRUE)
databasePathological <- databaseCreator(pattern = "^syntheticPathological1\\.nii\\.gz$", control = FALSE, quiet = TRUE)

matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = TRUE)
matrixPathological <- matrixCreator(databasePathological, paramZ = 35, quiet = TRUE)

normalizedMatrix <- meanNormalization(matrixControls)
normalizedPathological <- meanNormalization(matrixPathological)

niftiPath <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")
contours <- neuroContour(niftiPath, paramZ = 35, levels = c(0), plotResult = FALSE)

cat("Data prepared successfully.\n")

## -----------------------------------------------------------------------------
# Select the single pathological patient
SCC_AD <- normalizedPathological[1, , drop = FALSE]
SCC_CN <- normalizedMatrix

# Toy parameters for Poisson clone generation (modifiable by user)
numClones <- 2
factorLambda <- 0.1

# Generate synthetic clones
SCC_AD_clones <- generatePoissonClones(SCC_AD, numClones, factorLambda)

# Combine the patient with generated clones
SCC_AD_expanded <- rbind(SCC_AD, SCC_AD_clones)
SCC_AD_expanded <- meanNormalization(SCC_AD_expanded)

## ----eval=FALSE, echo=TRUE----------------------------------------------------
# result_file <- "SCCcomp.RData"
# scccomp_path <- system.file("data", result_file, package = "neuroSCC")
# 
# if (file.exists(scccomp_path)) {
#   cat("Precomputed SCC comparison found. Loading it...\n")
#   load(scccomp_path)
# } else {
#   cat("Precomputed SCC data not found. Skipping due to computational complexity.\n")
# 
#   # Intensive SCC estimation (code provided for reference)
#   SCCcomp <- ImageSCC::scc.image(
#     Ya = SCC_AD_expanded,
#     Yb = SCC_CN,
#     Z = contours[[1]],
#     d.est = 5,
#     d.band = 2,
#     r = 1,
#     V.est.a = as.matrix(contours[[1]]),
#     Tr.est.a = as.matrix(contours[[1]]),
#     V.band.a = as.matrix(contours[[1]]),
#     Tr.band.a = as.matrix(contours[[1]]),
#     penalty = TRUE,
#     lambda = 10^{seq(-6, 3, 0.5)},
#     alpha.grid = c(0.10, 0.05, 0.01),
#     adjust.sigma = TRUE
#   )
# 
#   save(SCCcomp, file = result_file)
# }

## ----eval=TRUE----------------------------------------------------------------
# Extract significant points
significantPoints <- getPoints(SCCcomp)

# Load example true ROI data from the package
roi_path <- system.file("extdata", "ROIsample_Region2_18.nii.gz", package = "neuroSCC")
trueROI <- processROIs(roi_path, region = "Region2", number = "18", save = FALSE)

# Get dimensions for total coordinates
dimensions <- getDimensions(roi_path)
totalCoords <- expand.grid(x = 1:dimensions$xDim, y = 1:dimensions$yDim)

# Calculate performance metrics
metrics <- calculateMetrics(
  detectedPoints = significantPoints$positivePoints,
  truePoints = trueROI,
  totalCoords = dimensions,
  regionName = "SinglePatient_vs_Group"
)

# Display metrics
print(metrics)

