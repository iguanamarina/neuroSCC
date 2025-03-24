pkgname <- "neuroSCC"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
base::assign(".ExTimings", "neuroSCC-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('neuroSCC')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("calculateMetrics")
### * calculateMetrics

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: calculateMetrics
### Title: Evaluate SCC or SPM Detection Performance
### Aliases: calculateMetrics

### ** Examples

# Extract detected SCC points
detectedSCC <- getPoints(SCCcomp)$positivePoints

# Extract detected SPM points
spmFile <- system.file("extdata", "binary.nii.gz", package = "neuroSCC")
detectedSPM <- getSPMbinary(spmFile, paramZ = 35)

# Extract true ROI points
roiFile <- system.file("extdata", "ROIsample_Region2_18.nii.gz", package = "neuroSCC")
trueROI <- processROIs(roiFile, region = "Region2", number = "18", save = FALSE)

# Generate totalCoords from getDimensions()
totalCoords <- getDimensions(roiFile)

# Compute SCC detection performance
metricsSCC <- calculateMetrics(detectedSCC, trueROI, totalCoords, "Region2_SCC")

# Compute SPM detection performance
metricsSPM <- calculateMetrics(detectedSPM, trueROI, totalCoords, "Region2_SPM")

# Print both results
print(metricsSCC)
print(metricsSPM)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("calculateMetrics", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("databaseCreator")
### * databaseCreator

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: databaseCreator
### Title: Create a database of processed PET image data
### Aliases: databaseCreator

### ** Examples

# Get the file path for sample data
dataDir <- system.file("extdata", package = "neuroSCC")

# Example 1: Create database for Controls
controlPattern <- "^syntheticControl.*\\.nii.gz$"
databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = TRUE)
head(databaseControls); tail(databaseControls)
nrow(databaseControls)  # Total number of rows
unique(databaseControls$CN_number)  # Show unique subjects

# Example 2: Create database for Pathological group
pathologicalPattern <- "^syntheticPathological.*\\.nii.gz$"
databasePathological <- databaseCreator(pattern = pathologicalPattern,
                                        control = FALSE,
                                        quiet = TRUE)
head(databasePathological); tail(databasePathological)
nrow(databasePathological)  # Total number of rows
unique(databasePathological$AD_number)  # Show unique subjects




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("databaseCreator", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("generatePoissonClones")
### * generatePoissonClones

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: generatePoissonClones
### Title: Generate Synthetic Poisson Clones for PET Data
### Aliases: generatePoissonClones

### ** Examples

# Get a single patient's PET data matrix
dataDir <- system.file("extdata", package = "neuroSCC")
pathologicalPattern <- "^syntheticPathological.*\\.nii.gz$"
databasePathological <- databaseCreator(pattern = pathologicalPattern,
                                        control = FALSE,
                                        quiet = TRUE)
matrixPathological <- matrixCreator(databasePathological, paramZ = 35, quiet = TRUE)
patientMatrix <- matrixPathological[1, , drop = FALSE]  # Select a single patient

# Select 10 random columns for visualization
set.seed(123)
sampledCols <- sample(ncol(patientMatrix), 10)

# Show voxel intensity values before cloning
patientMatrix[, sampledCols]

# Generate 5 synthetic clones with Poisson noise
clones <- generatePoissonClones(patientMatrix, numClones = 5, lambdaFactor = 0.25)

# Show voxel intensity values after cloning
clones[, sampledCols]




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("generatePoissonClones", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("getDimensions")
### * getDimensions

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: getDimensions
### Title: Get Dimensions from a Neuroimaging File
### Aliases: getDimensions

### ** Examples

# Get the file path for a sample NIfTI file
niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")

# Extract dimensions from the NIfTI file
dimensions <- getDimensions(niftiFile)

# Display the extracted dimensions
print(dimensions)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("getDimensions", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("getPoints")
### * getPoints

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: getPoints
### Title: Extract significant SCC points from an SCC comparison object
### Aliases: getPoints

### ** Examples

# Load precomputed SCC example
data("SCCcomp", package = "neuroSCC")

# Extract significant SCC points
significantPoints <- getPoints(SCCcomp)

# Show first extracted points (interpretation depends on SCC computation, see description)
head(significantPoints$positivePoints)  # Regions where Pathological is hypoactive vs. Control
head(significantPoints$negativePoints)  # Regions where Pathological is hyperactive vs. Control




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("getPoints", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("getSPMbinary")
### * getSPMbinary

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: getSPMbinary
### Title: Extract SPM-detected significant points from a binary NIfTI file
### Aliases: getSPMbinary

### ** Examples

# Load a sample binary NIfTI file (SPM result)
niftiFile <- system.file("extdata", "binary.nii.gz", package = "neuroSCC")
detectedSPM <- getSPMbinary(niftiFile, paramZ = 35)

# Show detected points
head(detectedSPM)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("getSPMbinary", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("matrixCreator")
### * matrixCreator

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: matrixCreator
### Title: Convert database from PET image data to a functional data matrix
###   format
### Aliases: matrixCreator

### ** Examples

# Generate a database using databaseCreator
dataDir <- system.file("extdata", package = "neuroSCC")
controlPattern <- "^syntheticControl.*\\.nii.gz$"
databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = FALSE)

# Convert the database into a matrix format
matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = FALSE)
dim(matrixControls)  # Show matrix dimensions




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("matrixCreator", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("meanNormalization")
### * meanNormalization

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: meanNormalization
### Title: Mean Average Normalization for Matrix Data
### Aliases: meanNormalization

### ** Examples

# Generate a database and create a matrix
dataDir <- system.file("extdata", package = "neuroSCC")
controlPattern <- "^syntheticControl.*\\.nii.gz$"
databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = TRUE)
matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = TRUE)

# Normalize the matrix with detailed output
normalizationResult <- meanNormalization(matrixControls, returnDetails = TRUE, quiet = FALSE)
# Show problematic rows if any
if (length(normalizationResult$problemRows) == 0) {
  cat("No problematic rows detected.\n")
} else {
  print(normalizationResult$problemRows)
}




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("meanNormalization", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("neuroCleaner")
### * neuroCleaner

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: neuroCleaner
### Title: Clean and load data from NIFTI neuroimaging files
### Aliases: neuroCleaner

### ** Examples

# Get the file path for sample Control NIfTI file
niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")

# Example 1: Without demographic data
petData <- neuroCleaner(niftiFile)
petData[sample(nrow(petData), 10), ] # Show 10 random voxels

# Example 2: With demographic data
demoFile <- system.file("extdata", "Demographics.csv", package = "neuroSCC")
demoData <- read.csv(demoFile, stringsAsFactors = FALSE, sep = ";")
petDataWithDemo <- neuroCleaner(niftiFile, demo = demoData)
petDataWithDemo[sample(nrow(petDataWithDemo), 10), ] # Show 10 random voxels




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("neuroCleaner", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("neuroContour")
### * neuroContour

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: neuroContour
### Title: Obtain and save neuroimaging contours from a NIFTI file
### Aliases: neuroContour

### ** Examples

# Get the file path for a sample NIfTI file
niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")

# Extract contours at level 0
contours <- neuroContour(niftiFile, paramZ = 35, levels = 0, plotResult = TRUE)

# Display the extracted contour coordinates
if (length(contours) > 0) {
  head(contours[[1]])  # Show first few points of the main contour
}




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("neuroContour", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("processROIs")
### * processROIs

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: processROIs
### Title: Process ROIs from a NIfTI file
### Aliases: processROIs

### ** Examples

# Process an ROI NIfTI file (show results in console)
roiFile <- system.file("extdata", "ROIsample_Region2_18.nii.gz", package = "neuroSCC")
processedROI <- processROIs(roiFile, region = "Region2", number = "18", save = FALSE)
head(processedROI)  # Display first few rows




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("processROIs", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
