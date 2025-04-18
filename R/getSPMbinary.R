#' Extract SPM-Detected Significant Points from a Binary NIfTI File
#'
#' @description
#' Extracts voxel coordinates where \code{pet = 1} (i.e., statistically significant points)
#' from a binary NIfTI file produced by an external SPM analysis.
#' Only voxels from a specific brain slice (\code{z = paramZ}) are retained.
#'
#' The output data frame is structured identically to that of \code{\link{getPoints}},
#' allowing direct comparison between SCC- and SPM-detected regions via \code{\link{calculateMetrics}}.
#'
#' @param niftiFile \code{character}. The path to the binary NIfTI file generated by SPM.
#' @param paramZ \code{integer}. The specific z-slice to extract. Default is \code{35}.
#'
#' @return A data frame with the following columns:
#' \itemize{
#'   \item \code{x}, \code{y} – Coordinates of significant voxels at the specified slice.
#' }
#'
#' @details
#' This function converts externally generated SPM results into a format compatible
#' with SCC analysis tools in \code{neuroSCC}.
#' Use \code{\link{getDimensions}} to inspect the full coordinate space if needed.
#'
#' @examples
#' # Load a sample binary NIfTI file (SPM result)
#' niftiFile <- system.file("extdata", "binary.nii.gz", package = "neuroSCC")
#' detectedSPM <- getSPMbinary(niftiFile, paramZ = 35)
#'
#' # Show detected points
#' head(detectedSPM)
#'
#' @seealso
#' \code{\link{getPoints}} for SCC-based detection. \cr
#' \code{\link{getDimensions}} for obtaining full coordinate grids. \cr
#' \code{\link{calculateMetrics}} for evaluating SCC vs. SPM detection performance.
#'
#' @export
#' @importFrom utils globalVariables
getSPMbinary <- function(niftiFile, paramZ = 35) {

  # 1. Validate Inputs
  # ---------------------------
  if (!file.exists(niftiFile)) stop("NIfTI file not found: ", niftiFile)
  if (!is.numeric(paramZ) || length(paramZ) != 1) stop("'paramZ' must be a single integer.")

  # 2. Load and Process NIfTI File
  # ---------------------------
  voxelData <- neuroCleaner(niftiFile)

  # 3. Filter for Selected Slice and Detected Points
  # ---------------------------
  filteredData <- subset(voxelData, z == paramZ & pet == 1, select = c("x", "y"))

  return(filteredData)
}
