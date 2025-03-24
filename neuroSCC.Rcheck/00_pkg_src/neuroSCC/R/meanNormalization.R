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
#'
#' @return A matrix where each row has been normalized by its mean value.
#'
#' @details
#' The function iterates over each row of the input matrix, calculates the mean of the row,
#' and then divides each element of the row by the calculated mean. This process adjusts
#' for global intensity differences between rows in the matrix.
#'
#' @examples
#' # Generate a database and create a matrix
#' dataDir <- system.file("extdata", package = "neuroSCC")
#' controlPattern <- "^syntheticControl.*\\.nii.gz$"
#' databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = TRUE)
#' matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = TRUE)
#'
#' # Normalize the matrix with detailed output
#' normalizationResult <- meanNormalization(matrixControls, returnDetails = TRUE, quiet = FALSE)
#' # Show problematic rows if any
#' if (length(normalizationResult$problemRows) == 0) {
#'   cat("No problematic rows detected.\n")
#' } else {
#'   print(normalizationResult$problemRows)
#' }
#'
#' @seealso
#' \code{\link{matrixCreator}} for creating the data matrix to be normalized.
#'
#' @export
meanNormalization <- function(matrixData,
                              handleInvalidRows = c("warn", "error", "omit"),
                              returnDetails = FALSE,
                              quiet = FALSE) {
  # 1. Input validation
  if (!is.matrix(matrixData)) {
    stop("'matrixData' must be a matrix")
  }

  if (nrow(matrixData) == 0) {
    warning("Empty matrix provided. Returning unchanged.")
    return(matrixData)
  }

  handleInvalidRows <- match.arg(handleInvalidRows)

  # 2. Calculate row means, ignoring NA values
  rowMeansBefore <- rowMeans(matrixData, na.rm = TRUE)
  overallMeanBefore <- mean(rowMeansBefore, na.rm = TRUE)

  if (!quiet) {
    cat(sprintf("\n Mean before normalization: %.6f\n", overallMeanBefore))
  }

  # Identify problem rows (zero mean or NA mean)
  problemRows <- which(is.na(rowMeansBefore) | rowMeansBefore == 0)

  if (length(problemRows) > 0) {
    if (handleInvalidRows == "error") {
      stop("Some rows have an invalid mean (zero or NA). Processing halted.")
    } else if (handleInvalidRows == "warn") {
      warning("Some rows have an invalid mean and were left unnormalized.")
    }
  }

  # Normalize the matrix, handling problematic rows
  normalizedMatrix <- matrixData / rowMeansBefore

  if (handleInvalidRows == "omit") {
    normalizedMatrix <- normalizedMatrix[-problemRows, , drop = FALSE]
  }

  # 3. Calculate new mean after normalization
  rowMeansAfter <- rowMeans(normalizedMatrix, na.rm = TRUE)
  overallMeanAfter <- mean(rowMeansAfter, na.rm = TRUE)

  if (!quiet) {
    cat(sprintf("\n Normalization completed."))
  }

  # 4. Return results
  if (returnDetails) {
    return(list(
      normalizedMatrix = normalizedMatrix,
      problemRows = problemRows
    ))
  } else {
    return(normalizedMatrix)
  }
}
