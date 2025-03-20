#' Process ROIs from a NIfTI file
#'
#' @description
#' This function processes Regions of Interest (ROIs) from a binary NIfTI file.
#' It extracts voxel coordinates from the image and preserves the original structure,
#' marking which voxels are part of the ROI.
#'
#' This function is typically used in SCC evaluation, where detected SCC regions
#' are compared with predefined ROIs in \code{\link{calculateMetrics}}.
#'
#' @param roiFile \code{character}, the path to the NIfTI file containing the ROI data.
#' @param region \code{character}, the name of the ROI region (e.g., \code{"roi4"}).
#' @param number \code{character}, the subject or group identifier (e.g., \code{"18"}).
#' @param save \code{logical}, if \code{TRUE}, saves the processed ROIs as `.RDS` files.
#'        If \code{FALSE}, prints a preview in the console. Default is \code{TRUE}.
#' @param outputDir \code{character}, directory where processed ROI tables will be saved.
#' @param verbose \code{logical}, if \code{TRUE}, prints progress messages. Default is \code{TRUE}.
#'
#' @return A data frame containing voxel-level ROI information, with columns:
#' \itemize{
#'   \item \code{group}: ROI identifier, composed of \code{region + number}.
#'   \item \code{z}, \code{x}, \code{y}: Voxel coordinates.
#'   \item \code{pet}: Binary indicator (\code{1} for ROI, \code{0} for non-ROI).
#' }
#'
#' @details
#' The function reads the provided NIfTI file and extracts voxel data.
#' It keeps all voxels, indicating whether each belongs to a ROI (\code{pet = 1}) or not (\code{pet = 0}).
#'
#' @examples
#' # Process an ROI NIfTI file (show results in console)
#' roiFile <- system.file("extdata", "ROIsample_Region2_18.nii", package = "neuroSCC")
#' processedROI <- processROIs(roiFile, region = "Region2", number = "18", save = FALSE)
#' head(processedROI)  # Display first few rows
#'
#' @seealso
#' \code{\link{calculateMetrics}} for evaluating SCC detection performance.
#' ROIs must be processed first to compare detected SCC voxels with predefined regions.
#'
#' @export
processROIs <- function(roiFile, region, number, save = TRUE, outputDir = "results/ROIs", verbose = TRUE) {

  # 1. Validate Inputs
  # ---------------------------
  if (!file.exists(roiFile)) stop("ROI file not found: ", roiFile)
  if (!is.character(region) || nchar(region) == 0) stop("'region' must be a non-empty string.")
  if (!is.character(number) || nchar(number) == 0) stop("'number' must be a non-empty string.")
  if (!is.logical(save) || length(save) != 1) stop("'save' must be TRUE or FALSE.")
  if (!is.logical(verbose) || length(verbose) != 1) stop("'verbose' must be TRUE or FALSE.")

  # 2. Load NIfTI File Using neuroCleaner
  # ---------------------------
  if (verbose) message("Loading NIfTI file...")
  voxelData <- neuroCleaner(roiFile)

  # 3. Assign ROI Group Identifier
  # ---------------------------
  voxelData$group <- paste0(region, "_number", number)

  # 4. Reorder Columns to Ensure 'group' is First
  # ---------------------------
  columnOrder <- c("group", "z", "x", "y", "pet")
  voxelData <- voxelData[, columnOrder]

  # 5. Save or Print Results
  # ---------------------------
  if (save) {
    if (!dir.exists(outputDir)) dir.create(outputDir, recursive = TRUE)
    outputFile <- file.path(outputDir, paste0("ROItable_", region, "_", number, ".RDS"))
    saveRDS(voxelData, outputFile)
    if (verbose) message("ROI table saved to: ", outputFile)
  } else {
    return(voxelData)
  }
}
