#' Mean Average Normalization for Matrix Data
#'
#' @description
#' This function normalizes each row of the given matrix by its mean value.
#' It divides each element in a row by the mean of that row, ignoring NA values.
#' This normalization is a critical pre-processing step when comparing data
#' from multiple sources to account for global intensity differences.
#'
#' @param matrixData \code{matrix}, a matrix where each row represents data
#'        that needs to be normalized, typically the output from \code{\link{matrixCreator}}.
#' @param handleInvalidRows \code{character}, specifies how to handle rows with invalid means
#'        (zero or NA). Options are:
#'        \code{"warn"} (default) warns and leaves row unnormalized,
#'        \code{"error"} stops with an error, or
#'        \code{"omit"} removes problematic rows from the result.
#' @param returnDetails \code{logical}, if \code{TRUE}, returns a list containing the normalized
#'        matrix and additional diagnostic information. If \code{FALSE} (default), returns
#'        only the normalized matrix.
#' @param quiet \code{logical}, if \code{TRUE}, suppresses console messages. Default is \code{FALSE}.
#'-
#' @return If \code{returnDetails=FALSE} (default), returns a \code{matrix} where each row has
#'         been normalized by its mean value. If \code{returnDetails=TRUE}, returns a \code{list}
#'         containing:
#'         \itemize{
#'           \item \code{normalizedMatrix}: The normalized matrix
#'           \item \code{rowMeans}: Vector of all calculated row means
#'           \item \code{problemRows}: Indices of rows with invalid means
#'           \item \code{outlierRows}: Indices of statistical outliers (based on 1.5*IQR)
#'           \item \code{extremeOutlierRows}: Indices of extreme outliers (based on 3*IQR)
#'           \item \code{summary}: Count of normal vs. problematic rows and thresholds used
#'         }
#'
#' @details
#' The function iterates over each row of the input matrix, calculates the mean of the row,
#' and then divides each element of the row by the calculated mean. This process adjusts
#' for global intensity differences between rows in the matrix.
#'
#' In addition to normalization, the function performs statistical analysis on row means
#' to identify potential outliers that might indicate data quality issues. Outlier detection
#' uses the Interquartile Range (IQR) method with thresholds at 1.5xIQR and 3xIQR.
#'
#' This function is typically used after \code{\link{matrixCreator}} in the neuroSCC workflow.
#'
#' @examples
#' \dontrun{
#' # In a typical workflow:
#' # Assuming data matrices already created with matrixCreator
#' matrixCN <- matrixCreator(database_CN, pattern, paramZ = 35)
#' matrixAD <- matrixCreator(database_AD, pattern, paramZ = 35)
#'
#' # Basic usage - just normalize the matrices
#' matrixCN <- meanNormalization(matrixCN)
#' matrixAD <- meanNormalization(matrixAD)
#'
#' # Advanced usage - get detailed diagnostics
#' results <- meanNormalization(matrixCN, returnDetails = TRUE)
#' normalizedMatrix <- results$normalizedMatrix
#'
#' # Remove problematic rows automatically
#' cleanMatrix <- meanNormalization(matrixCN, handleInvalidRows = "omit")
#' }
#'
#' @seealso
#' \code{\link{matrixCreator}} for creating the data matrix to be normalized.
#'
#' \code{ImageSCC::scc2g.image} for computing Simultaneous Confidence Corridors
#' for the difference between groups using the normalized matrices of each group.
#'
#' @export
meanNormalization <- function(matrixData,
                              handleInvalidRows = c("warn", "error", "omit"),
                              returnDetails = FALSE,
                              quiet = FALSE) {
  # 1. Input validation
  # ---------------------------
  if (!is.matrix(matrixData)) {
    stop("'matrixData' must be a matrix")
  }

  if (nrow(matrixData) == 0) {
    warning("Empty matrix provided. Returning unchanged.")
    return(matrixData)
  }

  # Validate and standardize handleInvalidRows parameter
  handleInvalidRows <- match.arg(handleInvalidRows)

  # 2. Initialize variables for tracking
  # ---------------------------
  nRows <- nrow(matrixData)
  rowMeans <- numeric(nRows)
  problemRows <- integer(0)

  if (!quiet) {
    cat(sprintf("Starting mean normalization on %d rows...\n", nRows))
  }

  # Create a copy of the input matrix to avoid modifying the original
  result <- matrixData

  # 3. Normalize each row by its mean
  # ---------------------------
  for (k in 1:nRows) {
    # Extract the current row
    temp <- result[k, ]

    # Calculate mean, ignoring NA values
    meanVal <- mean(as.numeric(temp), na.rm = TRUE)
    rowMeans[k] <- meanVal

    # Check for invalid means
    if (is.na(meanVal) || meanVal == 0) {
      problemRows <- c(problemRows, k)

      # Handle based on user preference
      if (handleInvalidRows == "error") {
        stop(sprintf("Row %d has an invalid mean (%s). Processing halted.",
                     k, ifelse(is.na(meanVal), "NA", "0")))
      } else if (handleInvalidRows == "warn") {
        warning(sprintf("Row %d has an invalid mean (%s). Row left unnormalized.",
                        k, ifelse(is.na(meanVal), "NA", "0")))
        next
      }
      # For "omit", we'll handle it after the loop
    } else {
      # Normalize by dividing by the mean
      result[k, ] <- temp / meanVal
    }
  }

  # 4. Handle row omission if requested
  # ---------------------------
  if (handleInvalidRows == "omit" && length(problemRows) > 0) {
    if (!quiet) {
      cat(sprintf("Removing %d problematic rows...\n", length(problemRows)))
    }
    # Remove problem rows from result
    if (length(problemRows) < nRows) {
      result <- result[-problemRows, , drop = FALSE]
      rowMeans <- rowMeans[-problemRows]
    } else {
      warning("All rows have invalid means. Returning empty matrix.")
      result <- matrix(nrow = 0, ncol = ncol(matrixData))
      rowMeans <- numeric(0)
    }
  }

  # 5. Detect outliers in row means (excluding problem rows)
  # ---------------------------
  outlierRows <- integer(0)
  extremeOutlierRows <- integer(0)
  outlierThresholds <- list(lower = NA, upper = NA,
                            lowerExtreme = NA, upperExtreme = NA)

  # Only detect outliers if we have valid means
  validMeans <- rowMeans[!is.na(rowMeans) & rowMeans != 0]

  if (length(validMeans) >= 4) {  # Need at least a few values for IQR to be meaningful
    q <- quantile(validMeans, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- q[2] - q[1]

    # Calculate thresholds
    lowerThreshold <- q[1] - 1.5 * iqr
    upperThreshold <- q[2] + 1.5 * iqr
    lowerExtremeThreshold <- q[1] - 3 * iqr
    upperExtremeThreshold <- q[2] + 3 * iqr

    # Store thresholds
    outlierThresholds <- list(
      lower = lowerThreshold,
      upper = upperThreshold,
      lowerExtreme = lowerExtremeThreshold,
      upperExtreme = upperExtremeThreshold
    )

    # Find outliers and extreme outliers
    for (k in 1:length(rowMeans)) {
      if (is.na(rowMeans[k]) || rowMeans[k] == 0) next

      if (rowMeans[k] < lowerExtremeThreshold || rowMeans[k] > upperExtremeThreshold) {
        extremeOutlierRows <- c(extremeOutlierRows, k)
      } else if (rowMeans[k] < lowerThreshold || rowMeans[k] > upperThreshold) {
        outlierRows <- c(outlierRows, k)
      }
    }

    # Print warning messages for outliers
    if (!quiet) {
      if (length(outlierRows) > 0) {
        cat(sprintf("Warning: %d outlier row means detected (rows: %s)\n",
                    length(outlierRows), paste(outlierRows, collapse = ", ")))
      }

      if (length(extremeOutlierRows) > 0) {
        cat(sprintf("Warning: %d extreme outlier row means detected (rows: %s)\n",
                    length(extremeOutlierRows), paste(extremeOutlierRows, collapse = ", ")))
      }
    }
  }

  # Print completion message
  if (!quiet) {
    cat(sprintf("Normalization complete: %d rows processed, %d problematic rows identified\n",
                nRows, length(problemRows)))
  }

  # 6. Return appropriate output based on returnDetails
  # ---------------------------
  if (returnDetails) {
    # Summary information
    summary <- list(
      totalRows = nRows,
      validRows = nRows - length(problemRows),
      problemRows = length(problemRows),
      outlierRows = length(outlierRows),
      extremeOutlierRows = length(extremeOutlierRows),
      thresholds = outlierThresholds
    )

    # Return detailed list
    return(list(
      normalizedMatrix = result,
      rowMeans = rowMeans,
      problemRows = problemRows,
      outlierRows = outlierRows,
      extremeOutlierRows = extremeOutlierRows,
      summary = summary
    ))
  } else {
    # Return just the normalized matrix (original behavior)
    return(result)
  }
}
