## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
library(neuroSCC)

## -----------------------------------------------------------------------------

# Recreate necessary data from sample files
cat("Creating sample data for 2-group comparison...\n")

# Create databases for Control and Pathological groups
databaseControls <- databaseCreator(pattern = "^syntheticControl[12]\\.nii\\.gz$", control = TRUE, quiet = TRUE)
databasePathological <- databaseCreator(pattern = "^syntheticPathological[12]\\.nii\\.gz$", control = FALSE, quiet = TRUE)

# Create matrices suitable for SCC
matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = TRUE)
matrixPathological <- matrixCreator(databasePathological, paramZ = 35, quiet = TRUE)

# Normalize matrices
normalizedControls <- meanNormalization(matrixControls)
normalizedPathological <- meanNormalization(matrixPathological)

# Extract contours from a control subject for SCC triangulation
niftiPath <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")
contours <- neuroContour(niftiPath, paramZ = 35, levels = c(0), plotResult = FALSE)

cat("Data preparation completed successfully.\n")


## ----eval=FALSE, echo=TRUE----------------------------------------------------
# result_file <- "SCCcomp.RData"
# scccomp_path <- system.file("data", result_file, package = "neuroSCC")
# 
# if (file.exists(scccomp_path)) {
#   cat("Precomputed SCC group comparison found. Loading data...\n")
#   load(scccomp_path)
# } else {
#   cat("Precomputed SCC data not found. Actual computation is skipped due to computational complexity.\n")
# 
#   # The following code shows how to perform the SCC computation (skipped by default)
#   SCCcomp <- ImageSCC::scc.image(
#     Ya = normalizedPathological,
#     Yb = normalizedControls,
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
# Extract significant points from SCC results
significantPoints <- getPoints(SCCcomp)

# Load true ROI data provided within the package
roi_path <- system.file("extdata", "ROIsample_Region2_18.nii.gz", package = "neuroSCC")
trueROI <- processROIs(roi_path, region = "Region2", number = "18", save = FALSE)

# Get total coordinate dimensions
dimensions <- getDimensions(roi_path)
totalCoords <- expand.grid(x = 1:dimensions$xDim, y = 1:dimensions$yDim)

# Calculate metrics to evaluate detection performance
metrics <- calculateMetrics(
  detectedPoints = significantPoints$positivePoints,
  truePoints = trueROI,
  totalCoords = dimensions,
  regionName = "Group_vs_Group"
)

# Display calculated metrics
print(metrics)

