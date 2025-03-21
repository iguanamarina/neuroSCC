#' Extract SPM-detected significant points from a binary NIfTI file
#'
#' @description
#' This function extracts voxel coordinates where \code{pet = 1} (significant points)
#' from a binary NIfTI file generated in an external SPM analysis.
#' It filters data to retain only points in a given brain slice (\code{z = paramZ}).
#'
#' The result is a data frame with detected points, structured identically to the output of \code{\link{getPoints}}.
#' This allows direct comparison between SCC- and SPM-detected regions in \code{\link{calculateMetrics}}.
#'
#' @param niftiFile \code{character}, the path to the binary NIfTI file.
#' @param paramZ \code{integer}, the specific z-slice to extract. Default is 35.
#'
#' @return A data frame containing:
#' \itemize{
#'   \item \code{x}, \code{y}: Coordinates of detected points.
#' }
#'
#' @details
#' - This function processes externally generated SPM results into a compatible format for SCC analysis.
#' - \code{\link{getDimensions}} can be used to verify the full coordinate grid.
#'
#' @examples
#' # Load a sample binary NIfTI file (SPM result)
#' niftiFile <- system.file("extdata", "binary.nii", package = "neuroSCC")
#' detectedSPM <- getSPMbinary(niftiFile, paramZ = 35)
#'
#' # Show detected points
#' head(detectedSPM)
#'
#' @seealso
#' \code{\link{getPoints}} for SCC-based detection points.
#' \code{\link{getDimensions}} for extracting voxel grid coordinates.
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
