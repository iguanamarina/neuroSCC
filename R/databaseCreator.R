#' Create a database of processed PET image data
#'
#' @description
#' This function processes PET images based on a specified file name pattern.
#' It reads each file matching the pattern, processes it using \code{\link{neuroCleaner}},
#' and compiles the results into a structured data frame.
#' The function is a key step in the neuroSCC workflow, bridging individual
#' image processing and preparation for functional data analysis with Simultaneous Confidence Corridors (SCCs).
#'
#' @param pattern \code{character}, a regular expression pattern specifying which files to process.
#'        The function extracts the subject number directly from the filename based on this pattern.
#' @param control \code{logical}, if \code{TRUE}, the function processes control group images;
#'        if \code{FALSE}, it processes pathological group images. Default is \code{TRUE}.
#' @param useSequentialNumbering \code{logical}, if \code{TRUE}, assigns sequential numbers (1,2,3,...)
#'        to files instead of extracting from filenames. Default is \code{FALSE}.
#' @param demo \code{data.frame}, optional demographic data. If provided, this information will be
#'        included in the output database for each file. Default is \code{NULL}.
#' @param quiet \code{logical}, if \code{TRUE}, suppresses progress messages. Default is \code{FALSE}.
#'
#' @return A \code{data.frame} that aggregates processed data from all matched images.
#'         Each row represents data from one voxel (3D pixel), including:
#'         \itemize{
#'           \item For control group (\code{control=TRUE}): \code{CN_number}, \code{z}, \code{x}, \code{y}, \code{pet}
#'           \item For pathological group (\code{control=FALSE}): \code{AD_number}, \code{z}, \code{x}, \code{y}, \code{pet}
#'           \item If demographic data is provided: Additional columns like \code{PPT}, \code{Group}, \code{Sex}, \code{Age}
#'         }
#'         The \code{CN_number} or \code{AD_number} column contains the subject identifier extracted from
#'         the filename or assigned sequentially. The \code{pet} column contains intensity values.
#'
#' @details
#' The function performs the following operations:
#'
#' \enumerate{
#'   \item Identifies files in the working directory that match the specified pattern.
#'   \item For each file:
#'   \itemize{
#'     \item Extracts the subject number from the filename (or assigns a sequential number if \code{useSequentialNumbering=TRUE}).
#'     \item Processes the file using \code{\link{neuroCleaner}}, integrating demographic data if provided.
#'     \item Adds subject identifier information to each row.
#'     \item Merges all processed data into a structured database.
#'   }
#' }
#'
#' This function is typically followed by \code{\link{matrixCreator}} in the analysis pipeline,
#' which transforms the database into a format suitable for SCC computation.
#'
#' @examples
#' # Get the file path for sample data
#' dataDir <- system.file("extdata", package = "neuroSCC")
#'
#' # Example 1: Create database for Controls
#' controlPattern <- "^syntheticControl.*\\.nii.gz$"
#' databaseControls <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = TRUE)
#' head(databaseControls); tail(databaseControls)
#' nrow(databaseControls)  # Total number of rows
#' unique(databaseControls$CN_number)  # Show unique subjects
#'
#' # Example 2: Create database for Pathological group
#' pathologicalPattern <- "^syntheticPathological.*\\.nii.gz$"
#' databasePathological <- databaseCreator(pattern = pathologicalPattern,
#'                                         control = FALSE,
#'                                         quiet = TRUE)
#' head(databasePathological); tail(databasePathological)
#' nrow(databasePathological)  # Total number of rows
#' unique(databasePathological$AD_number)  # Show unique subjects
#'
#' @seealso
#' \code{\link{neuroCleaner}} for the underlying image processing function.
#'
#' \code{\link{matrixCreator}} for the next step in the workflow that converts
#' the database to a matrix format for SCC analysis.
#'
#' @export
databaseCreator <- function(pattern, control = TRUE, useSequentialNumbering = FALSE, demo = NULL, quiet = FALSE) {
  # 1. Input validation
  # ---------------------------
  if (!is.character(pattern) || length(pattern) != 1) {
    stop("'pattern' must be a single character string specifying a regular expression")
  }

  if (!is.logical(control) || length(control) != 1) {
    stop("'control' must be a single logical value (TRUE or FALSE)")
  }

  if (!is.logical(useSequentialNumbering) || length(useSequentialNumbering) != 1) {
    stop("'useSequentialNumbering' must be a single logical value (TRUE or FALSE)")
  }

  if (!is.logical(quiet) || length(quiet) != 1) {
    stop("'quiet' must be a single logical value (TRUE or FALSE)")
  }

  if (!is.null(demo) && !is.data.frame(demo)) {
    stop("'demo' must be a data frame or NULL")
  }

  # 2. Get the list of files matching the pattern
  # ---------------------------
  searchPath <- getwd()
  packagePath <- system.file("extdata", package = "neuroSCC")

  if (length(list.files(packagePath, pattern = pattern)) > 0) {
    searchPath <- packagePath
  }

  files <- list.files(path = searchPath, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    stop("Error: No files with this pattern found in: ", searchPath)
  }

  # 3. Initialize storage list for data
  # ---------------------------
  dataList <- list()
  numberLabel <- if (control) "CN_number" else "AD_number"

  # 4. Process each file
  # ---------------------------
  for (i in seq_along(files)) {
    file <- files[i]
    baseName <- basename(file)

    # Extract the number directly from the file name
    number <- sub("^.*?(\\d+)\\.nii\\.gz$", "\\1", baseName)

    if (number == baseName) {
      warning("Could not extract number from: ", baseName, ". Using file index instead.")
      number <- as.character(i)
    }

    # Print progress message if not quiet
    if (!quiet) {
      message("Processing ", numberLabel, " ", number, " - File ", i, " of ", length(files))
    }

    # Process file using neuroCleaner
    tryCatch({
      if (is.null(demo)) {
        tempData <- neuroSCC::neuroCleaner(file)
      } else {
        fileBaseName <- sub("\\.nii\\.gz$", "", baseName)
        demoRow <- demo[demo$PPT == fileBaseName, , drop = FALSE]

        if (nrow(demoRow) == 0) {
          warning("No matching demographic data for ", fileBaseName, ". Using first row instead.")
          demoRow <- demo[1, , drop = FALSE]
        }

        tempData <- neuroSCC::neuroCleaner(file, demo = demoRow)
      }

      # Add subject number to each row
      tempData[[numberLabel]] <- number

      # Store processed data in list
      dataList[[i]] <- tempData

    }, error = function(e) {
      warning("Error processing file: ", baseName, " - ", e$message)
    })
  }

  # 5. Combine all processed data
  # ---------------------------
  if (length(dataList) == 0) {
    warning("No data was successfully processed. Returning empty data frame.")
    return(data.frame())
  }

  database <- do.call(rbind, dataList)

  # 6. Reorder columns
  # ---------------------------
  columnOrder <- c(numberLabel, "PPT", "Group", "Sex", "Age", "z", "x", "y", "pet")
  existingColumns <- intersect(columnOrder, names(database))
  database <- database[, existingColumns]

  return(database)
}
