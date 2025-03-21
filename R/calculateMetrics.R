#' Evaluate SCC or SPM Detection Performance
#'
#' @description
#' Computes Sensitivity, Specificity, Positive Predictive Value (PPV), and Negative Predictive Value (NPV)
#' for detected points compared to ground truth ROI points. This function is used to evaluate
#' SCC-based and SPM-based detection accuracy in neuroimaging analysis.
#'
#' @param detectedPoints A data frame containing SCC- or SPM-detected points (\code{x}, \code{y}).
#' \itemize{
#'   \item SCC-detected points should come from \code{\link{getPoints}}.
#'   \item SPM-detected points should come from \code{\link{getSPMbinary}}.
#' }
#' @param truePoints A data frame containing ground truth ROI points (\code{x}, \code{y}),
#'        obtained using \code{\link{processROIs}}.
#' @param totalCoords A data frame containing all possible voxel coordinates (\code{x}, \code{y}),
#'        obtained using \code{\link{getDimensions}}.
#' @param regionName A character string used for labeling the results.
#'
#' @return A data frame with the following evaluation metrics:
#' \itemize{
#'   \item \code{region}: The analyzed region.
#'   \item \code{sensitivity}: True positive rate (TP / (TP + FN) * 100).
#'   \item \code{specificity}: True negative rate (TN / (TN + FP) * 100).
#'   \item \code{PPV}: Positive Predictive Value (TP / (TP + FP) * 100).
#'   \item \code{NPV}: Negative Predictive Value (TN / (TN + FN) * 100).
#' }
#'
#' @details
#' The user must precompute the following objects before calling this function:
#' \itemize{
#'   \item \code{detectedPoints}: Extracted using \code{\link{getPoints}} (for SCC) or \code{\link{getSPMbinary}} (for SPM).
#'   \item \code{truePoints}: Extracted using \code{\link{processROIs}}, representing ground truth ROIs.
#'   \item \code{totalCoords}: Generated using \code{\link{getDimensions}}, providing the full voxel grid.
#' }
#'
#' @examples
#' # Extract detected SCC points
#' detectedSCC <- getPoints(SCCcomp)$positivePoints
#'
#' # Extract detected SPM points
#' spmFile <- system.file("extdata", "binary.nii", package = "neuroSCC")
#' detectedSPM <- getSPMbinary(spmFile, paramZ = 35)
#'
#' # Extract true ROI points
#' roiFile <- system.file("extdata", "ROIsample_Region2_18.nii", package = "neuroSCC")
#' trueROI <- processROIs(roiFile, region = "Region2", number = "18", save = FALSE)
#'
#' # Generate totalCoords from getDimensions()
#' totalCoords <- getDimensions(roiFile)
#'
#' # Compute SCC detection performance
#' metricsSCC <- calculateMetrics(detectedSCC, trueROI, totalCoords, "Region2_SCC")
#'
#' # Compute SPM detection performance
#' metricsSPM <- calculateMetrics(detectedSPM, trueROI, totalCoords, "Region2_SPM")
#'
#' # Print both results
#' print(metricsSCC)
#' print(metricsSPM)
#'
#' @seealso
#' \code{\link{getPoints}} for SCC-based detection points.
#' \code{\link{getSPMbinary}} for extracting SPM-detected points.
#' \code{\link{processROIs}} for ground truth ROI extraction.
#' \code{\link{getDimensions}} for obtaining the full coordinate grid.
#'
#' @export
#' @importFrom stats rpois
calculateMetrics <- function(detectedPoints, truePoints, totalCoords, regionName) {

  # 1. Validate Inputs
  # ---------------------------
  if (!is.character(regionName) || length(regionName) != 1) {
    stop("'regionName' must be a single character string.")
  }

  if (!all(c("x", "y") %in% colnames(detectedPoints))) {
    stop("'detectedPoints' must be a data frame with 'x' and 'y' columns.")
  }

  if (!all(c("x", "y", "pet") %in% colnames(truePoints))) {
    stop("'truePoints' must be a data frame containing 'x', 'y', and 'pet' columns.")
  }

  if (!all(c("xDim", "yDim") %in% names(totalCoords))) {
    stop("'totalCoords' must be a list containing 'xDim' and 'yDim'.")
  }

  # 2. Process Inputs
  # ---------------------------
  # Extract only voxels marked as ROI (pet = 1)
  truePoints <- subset(truePoints, pet == 1, select = c("x", "y"))

  # Generate total coordinate grid from getDimensions() output
  totalCoords <- expand.grid(x = 1:totalCoords$xDim, y = 1:totalCoords$yDim)

  # Merge x and y into a single identifier
  detectedPoints <- tidyr::unite(detectedPoints, "x_y", x, y, sep = "_", remove = FALSE)
  truePoints <- tidyr::unite(truePoints, "x_y", x, y, sep = "_", remove = FALSE)
  totalCoords <- tidyr::unite(totalCoords, "x_y", x, y, sep = "_", remove = FALSE)

  # 3. Compute True Positives, False Positives, False Negatives, and True Negatives
  # ---------------------------
  TP <- nrow(dplyr::inner_join(detectedPoints, truePoints, by = "x_y"))
  FP <- nrow(dplyr::setdiff(detectedPoints, truePoints))
  FN <- nrow(dplyr::setdiff(truePoints, detectedPoints))

  trueNegatives <- dplyr::setdiff(totalCoords, truePoints)
  detectedNegatives <- dplyr::setdiff(totalCoords, detectedPoints)
  TN <- nrow(dplyr::inner_join(trueNegatives, detectedNegatives, by = "x_y"))

  # 4. Compute Sensitivity, Specificity, PPV, and NPV
  # ---------------------------
  sensitivity <- if ((TP + FN) > 0) (TP / (TP + FN)) * 100 else NA
  specificity <- if ((TN + FP) > 0) (TN / (TN + FP)) * 100 else NA
  PPV <- if ((TP + FP) > 0) (TP / (TP + FP)) * 100 else NA
  NPV <- if ((TN + FN) > 0) (TN / (TN + FN)) * 100 else NA

  # 5. Return Results
  # ---------------------------
  result <- data.frame(
    region = regionName,
    sensitivity = sensitivity,
    specificity = specificity,
    PPV = PPV,
    NPV = NPV
  )

  return(result)
}
