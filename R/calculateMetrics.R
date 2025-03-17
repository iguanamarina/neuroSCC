#' Evaluate SCC Detection Performance
#'
#' @description
#' Computes Sensitivity, Specificity, Positive Predictive Value (PPV), and Negative Predictive Value (NPV)
#' for SCC-detected points compared to ground truth ROI points. This function is essential for evaluating
#' the accuracy of SCC methods in detecting true regions of difference in neuroimaging analysis.
#'
#' @param detectedPoints A data frame of SCC-detected significant points with columns \code{x} and \code{y}.
#' @param truePoints A data frame of true region-of-interest (ROI) points with columns \code{x} and \code{y}.
#' @param totalCoords A data frame containing the full set of image coordinates (\code{x}, \code{y}).
#' @param regionName A character string specifying the name of the region being evaluated.
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
#' - **True Positives (TP):** SCC-detected points that match true ROI points.
#' - **False Positives (FP):** SCC-detected points that are not in the true ROI.
#' - **False Negatives (FN):** True ROI points that SCC failed to detect.
#' - **True Negatives (TN):** Points in \code{totalCoords} that were neither detected nor part of the ROI.
#' - Handles **division by zero** cases to prevent errors in metric calculations.
#'
#' @examples
#' \dontrun{
#' detected <- data.frame(x = c(1, 2, 3), y = c(2, 3, 4))  # SCC-detected points
#' trueROI <- data.frame(x = c(2, 3), y = c(3, 4))  # True positive regions
#' totalGrid <- expand.grid(x = 1:5, y = 1:5)  # Full coordinate grid
#'
#' results <- calculateMetrics(detected, trueROI, totalGrid, "ExampleRegion")
#' print(results)
#' }
#'
#' @export
calculateMetrics <- function(detectedPoints, truePoints, totalCoords, regionName) {

  # 1. Input validation
  # ---------------------------
  if (!is.data.frame(detectedPoints) || !all(c("x", "y") %in% colnames(detectedPoints))) {
    stop("'detectedPoints' must be a data frame with columns 'x' and 'y'.")
  }
  if (!is.data.frame(truePoints) || !all(c("x", "y") %in% colnames(truePoints))) {
    stop("'truePoints' must be a data frame with columns 'x' and 'y'.")
  }
  if (!is.data.frame(totalCoords) || !all(c("x", "y") %in% colnames(totalCoords))) {
    stop("'totalCoords' must be a data frame with columns 'x' and 'y'.")
  }
  if (!is.character(regionName) || length(regionName) != 1) {
    stop("'regionName' must be a single character string.")
  }

  # 2. Compute true positives (TP)
  # ---------------------------
  TP <- nrow(dplyr::inner_join(detectedPoints, truePoints, by = c("x", "y")))

  # 3. Compute false positives (FP)
  # ---------------------------
  FP <- nrow(dplyr::setdiff(detectedPoints, truePoints))

  # 4. Compute false negatives (FN)
  # ---------------------------
  FN <- nrow(dplyr::setdiff(truePoints, detectedPoints))

  # 5. Compute true negatives (TN)
  # ---------------------------
  trueNegatives <- dplyr::setdiff(totalCoords, truePoints)  # All non-ROI points
  detectedNegatives <- dplyr::setdiff(totalCoords, detectedPoints)  # Non-detected points
  TN <- nrow(dplyr::inner_join(trueNegatives, detectedNegatives, by = c("x", "y")))

  # 6. Compute Sensitivity, Specificity, PPV, and NPV
  # ---------------------------
  sensitivity <- if ((TP + FN) > 0) (TP / (TP + FN)) * 100 else NA
  specificity <- if ((TN + FP) > 0) (TN / (TN + FP)) * 100 else NA
  PPV <- if ((TP + FP) > 0) (TP / (TP + FP)) * 100 else NA
  NPV <- if ((TN + FN) > 0) (TN / (TN + FN)) * 100 else NA

  # 7. Return results as a structured data frame
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
