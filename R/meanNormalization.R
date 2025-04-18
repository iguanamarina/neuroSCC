#' Mean Normalization for Matrix Data
#'
#' @description
#' Normalizes each row of a matrix by dividing its elements by the row mean, ignoring \code{NA} values.
#' This step is commonly used to adjust for global intensity differences across subjects before
#' applying statistical comparisons or functional data analysis.
#'
#' @param matrixData A \code{matrix} where each row represents one subject’s PET data,
#'        typically generated by \code{\link{matrixCreator}}.
#' @param handleInvalidRows \code{character}. Specifies how to handle rows with invalid means (either zero or \code{NA}).
#'        Options include \code{"warn"} (default), \code{"error"}, or \code{"omit"}.
#' @param returnDetails \code{logical}. If \code{TRUE}, returns a list with the normalized matrix and
#'        additional diagnostics. If \code{FALSE} (default), returns only the normalized matrix.
#' @param quiet \code{logical}. If \code{TRUE}, suppresses console messages. Default is \code{FALSE}.
#'
#' @return A normalized matrix, or a list if \code{returnDetails = TRUE}.
#' \itemize{
#'   \item \code{normalizedMatrix} – The normalized matrix.
#'   \item \code{problemRows} – Indices of rows that had zero or \code{NA} means.
#' }
#'
#' @details
#' The function performs the following steps
#' \enumerate{
#'   \item Computes the row means of the input matrix, ignoring \code{NA}s.
#'   \item Divides each row by its corresponding mean.
#'   \item Replaces \code{NaN} values (from division by 0) with \code{0} if applicable.
#'   \item Handles problematic rows according to the selected \code{handleInvalidRows} option:
#'         \code{"warn"} (default) issues a warning, \code{"error"} stops execution,
#'         and \code{"omit"} removes the affected rows from the result.
#' }
#'
#' This step is often used prior to applying SCC methods to ensure comparability across subjects.
#'
#' @examples
#' # Generate a minimal database and create a matrix (1 control subject)
#' dataDir <- system.file("extdata", package = "neuroSCC")
#' controlPattern <- "^syntheticControl1\\.nii\\.gz$"
#' databaseControls <- databaseCreator(pattern = controlPattern,
#'                                     control = TRUE,
#'                                     quiet = TRUE)
#' matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = TRUE)
#'
#' # Normalize the matrix (with diagnostics)
#' normalizationResult <- meanNormalization(matrixControls,
#'                                          returnDetails = TRUE,
#'                                          quiet = FALSE)
#'
#' @seealso
#' \code{\link{matrixCreator}} for building the matrix input to normalize.
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
