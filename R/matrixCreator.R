#' Convert database from PET image data to a functional data matrix format
#'
#' @description
#' This function transforms a database created by \code{\link{databaseCreator}} into
#' a matrix format suitable for functional data analysis. Each row of the matrix
#' represents a subject's (patient or control) PET data, formatted as a continuous
#' line of data points to simulate a functional representation.
#'
#' @param database A data frame created by \code{\link{databaseCreator}} containing
#'        PET image data with columns for group number, z, x, y, and pet values.
#' @param pattern The regular expression pattern used to match filenames in the
#'        database. This should correspond to the naming conventions of the PET
#'        image files processed by \code{databaseCreator}.
#' @param paramZ The specific z-coordinate slice to analyze. Default is 35.
#' @param extractPattern Optional custom regular expression to extract subject
#'        numbers from filenames. Should contain a capture group for numerical ID.
#' @param useSequentialNumbering If \code{TRUE}, assigns sequential numbers
#'        instead of extracting from filenames.
#' @param quiet If \code{TRUE}, suppresses progress messages.
#'
#' @return A matrix where each row represents the PET data from one subject,
#'         formatted as a continuous line of data points.
#'
#' @details
#' This function is a critical step in the neuroSCC workflow for preparing data
#' for Simultaneous Confidence Corridors (SCC) analysis. It performs several
#' key operations:
#'
#' 1. Verifies the existence of the specified z-slice in the input database
#' 2. Automatically calculates matrix dimensions based on the x and y coordinates
#'    of the specified z-slice
#' 3. Extracts PET intensity values for each subject at the specified z-slice
#' 4. Handles different group types (control or pathological) by recognizing
#'    appropriate identification columns
#' 5. Provides flexible subject number extraction:
#'    - Uses a provided custom pattern
#'    - Falls back to sequential numbering
#'    - Supports default filename-based number extraction
#' 6. Replaces any NaN values with zero to ensure matrix compatibility
#'
#' The resulting matrix transforms multidimensional PET image data into a
#' format suitable for functional data analysis techniques, particularly
#' Simultaneous Confidence Corridors computation.
#'
#' Typically follows \code{\link{databaseCreator}} and precedes
#' \code{\link{meanNormalization}} in the neuroSCC analysis pipeline.
#'
#' @examples
#' # Assuming 'database_CN', 'pattern', and 'paramZ' are defined
#' SCC_CN <- matrixCreator(database_CN, pattern, paramZ = 35)
#'
#' @seealso
#' \code{\link{databaseCreator}} for creating the input database
#' \code{\link{meanNormalization}} for subsequent data normalization
#'
#' @export
matrixCreator <- function(database,
                          pattern = NULL,
                          paramZ = 35,
                          extractPattern = NULL,
                          useSequentialNumbering = FALSE,
                          quiet = FALSE) {
  # 1. Input validation
  # ---------------------------
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
  # ---------------------------
  if ("CN_number" %in% colnames(database)) {
    groupCol <- "CN_number"
    groupLabel <- "Control"
  } else if ("AD_number" %in% colnames(database)) {
    groupCol <- "AD_number"
    groupLabel <- "Pathological"
  } else {
    stop("Database must contain either 'CN_number' or 'AD_number' column")
  }

  # 3. Calculate matrix dimensions
  # ---------------------------
  zSliceData <- subset(database, z == paramZ)
  xMax <- max(zSliceData$x)
  yMax <- max(zSliceData$y)
  matrixDim <- xMax * yMax

  # 4. Prepare for file processing
  # ---------------------------
  # Get the list of files matching the pattern
  if (!is.null(pattern)) {
    files <- list.files(pattern = pattern, full.names = TRUE)
  } else {
    files <- unique(database$file)  # Assuming a 'file' column exists
  }

  # 5. Preallocate the matrix
  # ---------------------------
  matrixResult <- matrix(nrow = length(files), ncol = matrixDim)

  # 6. Process each file
  # ---------------------------
  for (i in seq_along(files)) {
    # Extract the number from the filename
    if (useSequentialNumbering) {
      number <- as.character(i)
    } else if (!is.null(extractPattern)) {
      number <- sub(extractPattern, "\\1", basename(files[i]))
    } else {
      # Default extraction pattern
      number <- sub("masked_swwwC(\\d+)_.*", "\\1", basename(files[i]))
    }

    # Print progress message if not quiet
    if (!quiet) {
      message(sprintf("Converting %s Number %s", groupLabel, number))
    }

    # Subset the database for the current number and z coordinate
    subsetData <- database[database[[groupCol]] == number & database$z == paramZ, ]

    # Extract the 'pet' values
    Y <- subsetData[1:matrixDim, "pet"]

    # Replace NaN values with 0
    Y[is.nan(Y)] <- 0

    # Assign to matrix row
    matrixResult[i, ] <- as.numeric(Y)
  }

  # Return the matrix
  return(matrixResult)
}
