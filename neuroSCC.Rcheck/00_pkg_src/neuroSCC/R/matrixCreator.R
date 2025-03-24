#' Convert database from PET image data to a functional data matrix format
#'
#' @description
#' This function transforms a database created by \code{\link{databaseCreator}} into
#' a matrix format suitable for functional data analysis. Each row of the matrix
#' represents a subject's PET data, formatted as a continuous line of data points.
#'
#' @param database A data frame created by \code{\link{databaseCreator}} containing
#'        PET image data with columns for subject number, z, x, y, and pet values.
#' @param paramZ The specific z-coordinate slice to analyze. Default is 35.
#' @param useSequentialNumbering If \code{TRUE}, assigns sequential numbers
#'        instead of extracting from filenames.
#' @param quiet If \code{TRUE}, suppresses progress messages.
#'
#' @return A matrix where each row represents the PET data from one subject,
#'         formatted as a continuous line of data points.
#'
#' @details
#' The function performs several operations:
#'
#' \enumerate{
#'   \item Verifies that the specified z-slice exists in the database.
#'   \item Automatically calculates matrix dimensions based on x and y coordinates.
#'   \item Extracts PET intensity values for each subject at the specified z-slice.
#'   \item Handles both control and pathological groups by recognizing subject identifiers.
#'   \item Replaces any NaN values with zero to ensure matrix compatibility.
#' }
#'
#' Typically follows \code{\link{databaseCreator}} and precedes
#' \code{\link{meanNormalization}} in the neuroSCC pipeline.
#'
#' @examples
#' # Generate a database using databaseCreator
#' dataDir <- system.file("extdata", package = "neuroSCC")
#' controlPattern <- "^syntheticControl.*\\.nii.gz$"
#' databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = FALSE)
#'
#' # Convert the database into a matrix format
#' matrixControls <- matrixCreator(databaseControls, paramZ = 35, quiet = FALSE)
#' dim(matrixControls)  # Show matrix dimensions
#'
#' @seealso
#' \code{\link{databaseCreator}} for creating the input database.
#' \code{\link{meanNormalization}} for normalizing PET intensity values.
#'
#' @export
matrixCreator <- function(database, paramZ = 35, useSequentialNumbering = FALSE, quiet = FALSE) {
  # 1. Input validation
  if (!is.data.frame(database)) {
    stop("'database' must be a data frame created by databaseCreator")
  }

  # Validate z-slice exists
  zValues <- unique(database$z)
  if (!(paramZ %in% zValues)) {
    stop(sprintf("Specified z-slice %d not found. Available z-slices: %s",
                 paramZ, paste(zValues, collapse = ", ")))
  }

  # 2. Determine group identification
  if ("CN_number" %in% colnames(database)) {
    groupCol <- "CN_number"
  } else if ("AD_number" %in% colnames(database)) {
    groupCol <- "AD_number"
  } else {
    stop("Database must contain either 'CN_number' or 'AD_number' column")
  }

  # 3. Calculate matrix dimensions
  zSliceData <- subset(database, z == paramZ)
  xMax <- max(zSliceData$x)
  yMax <- max(zSliceData$y)
  matrixDim <- xMax * yMax

  # 4. Get unique subject numbers
  subjectNumbers <- unique(database[[groupCol]])

  # 5. Preallocate the matrix
  matrixResult <- matrix(nrow = length(subjectNumbers), ncol = matrixDim)

  # 6. Process each subject
  for (i in seq_along(subjectNumbers)) {
    subjectID <- subjectNumbers[i]

    # Print progress if not quiet
    if (!quiet) {
      message(sprintf("Processing Subject %s", subjectID))
    }

    # Extract PET values for the subject at the specified z-slice
    subsetData <- database[database[[groupCol]] == subjectID & database$z == paramZ, ]
    Y <- ifelse(is.nan(subsetData$pet), 0, subsetData$pet)

    # Assign to matrix row
    matrixResult[i, ] <- as.numeric(Y)
  }

  return(matrixResult)
}
