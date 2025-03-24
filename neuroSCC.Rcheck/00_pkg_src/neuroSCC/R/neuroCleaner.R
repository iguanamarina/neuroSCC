#' Clean and load data from NIFTI neuroimaging files
#'
#' @description
#' Loads a NIFTI-format neuroimaging file, converts it to a structured data frame,
#' and organizes the data for further analysis. This function serves as the first step
#' in the neuroimaging data processing pipeline, transforming raw PET data into a format
#' suitable for functional data analysis. The neuroSCC package prepares and organizes neuroimaging
#' data, while the actual Simultaneous Confidence Corridors (SCCs) are computed using
#' functions from the ImageSCC package such as \code{ImageSCC::scc1g.image} or \code{ImageSCC::scc2g.image}.
#'
#' @param name A character string specifying the path to the NIFTI file.
#' @param demo An optional data frame containing demographic information for the participants.
#'        If provided, it should contain columns that match (case-insensitive): 'PPT', 'Group', 'Sex', and 'Age'.
#'        The 'PPT' column can contain participant IDs that match the \code{name} parameter for automatic matching,
#'        but if no match is found, the row specified by \code{demoRow} will be used.
#'        Default is \code{NULL}.
#' @param demoRow An integer specifying which row of the demographic data to use when
#'        automatic matching fails or multiple matches are possible. Default is \code{1}.
#'
#' @return A data frame with the following columns:
#'   \itemize{
#'     \item If demographic data provided: \code{PPT}, \code{Group}, \code{Sex}, \code{Age}, \code{z}, \code{x}, \code{y}, \code{pet}
#'     \item If no demographic data: \code{z}, \code{x}, \code{y}, \code{pet}
#'   }
#'   Each row represents a voxel (3D pixel) from the image, with \code{pet} containing the
#'   intensity value at that location.
#'
#' @details
#' The function performs several key operations:
#'
#' \enumerate{
#'   \item Reads the NIFTI file using \code{oro.nifti} package functions.
#'   \item Converts the 3D image data to a structured data frame.
#'   \item Extracts the dimensional information (\code{z}, \code{x}, \code{y} coordinates).
#'   \item Organizes the PET intensity values.
#'   \item If demographic data is provided, merges it with the image data.
#' }
#'
#' The resulting data frame serves as input for subsequent analysis functions in the
#' \code{neuroSCC} pipeline, such as \code{databaseCreator} and \code{matrixCreator}, which prepare
#' the data for eventual analysis with the \code{ImageSCC} package functions.
#'
#' @examples
#' # Get the file path for sample Control NIfTI file
#' niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")
#'
#' # Example 1: Without demographic data
#' petData <- neuroCleaner(niftiFile)
#' petData[sample(nrow(petData), 10), ] # Show 10 random voxels
#'
#' # Example 2: With demographic data
#' demoFile <- system.file("extdata", "Demographics.csv", package = "neuroSCC")
#' demoData <- read.csv(demoFile, stringsAsFactors = FALSE, sep = ";")
#' petDataWithDemo <- neuroCleaner(niftiFile, demo = demoData)
#' petDataWithDemo[sample(nrow(petDataWithDemo), 10), ] # Show 10 random voxels
#'
#' @seealso
#' \code{\link{databaseCreator}} for creating databases from multiple NIFTI files.
#'
#' \code{\link[oro.nifti]{readNIfTI}} for the underlying function used to read NIFTI files.
#'
#' @export
neuroCleaner <- function(name, demo = NULL, demoRow = 1) {
  # 1. Input validation
  # ---------------------------
  # Check if name parameter is valid
  if (!is.character(name) || length(name) != 1) {
    stop("'name' must be a single character string specifying the file path")
  }

  # Check if the file exists
  if (!file.exists(name)) {
    stop("File not found: ", name)
  }

  # Check if demographic data is properly formatted (when provided)
  if (!is.null(demo)) {
    if (!is.data.frame(demo)) {
      stop("'demo' must be a data frame")
    }

    # Check for demographic columns case-insensitively
    demoCols <- tolower(names(demo))
    requiredCols <- c("ppt", "group", "sex", "age")

    if (!("ppt" %in% demoCols)) {
      warning("Demographic data doesn't contain 'PPT' column. Will use row ", demoRow, " instead.")
    }

    if (demoRow > nrow(demo)) {
      stop("'demoRow' (", demoRow, ") exceeds the number of rows in the demographic data (", nrow(demo), ")")
    }
  }

  # 2. Read NIFTI file
  # ---------------------------
  file <- tryCatch({
    oro.nifti::readNIfTI(
      fname = name,
      verbose = FALSE,
      warn = -1,
      reorient = TRUE,
      call = NULL,
      read_data = TRUE
    )
  }, error = function(e) {
    stop("Error reading NIFTI file: ", e$message)
  })

  # 3. Convert image data to data frame
  # ---------------------------
  n <- tryCatch({
    memisc::to.data.frame(oro.nifti::img_data(file))
  }, error = function(e) {
    stop("Error converting NIfTI data to data frame: ", e$message)
  })

  # 4. Extract dimensional information
  # ---------------------------
  dimensions <- neuroSCC::getDimensions(file)

  # Store file name without extension for demographic matching
  fileBaseName <- sub("\\.nii\\.gz$", "", basename(name))

  # Prepare empty data frame for storing the processed data
  dataframe <- data.frame(z = integer(), x = integer(), y = integer(), pet = numeric())

  # 5. Process each slice and organize data
  # ---------------------------
  for (i in seq_len(dimensions$xDim)) {
    nLim <- n[n$Var2 == i, ]
    nLim$Var1 <- NULL
    nLim$Var2 <- NULL

    z <- rep(i, length.out = dimensions$dim)
    x <- rep(1:dimensions$xDim, each = dimensions$yDim, length.out = dimensions$dim)
    y <- rep(1:dimensions$yDim, length.out = dimensions$dim)
    pet <- unlist(nLim)

    temp <- data.frame(z, x, y, pet)
    dataframe <- rbind(dataframe, temp)
  }

  # 6. Merge with demographic data (if provided)
  # ---------------------------
  if (!is.null(demo)) {
    # Helper function to retrieve column names case-insensitively
    getColumn <- function(colName) {
      idx <- which(tolower(names(demo)) == tolower(colName))
      if (length(idx) > 0) return(names(demo)[idx[1]])
      return(NULL)
    }

    pptColumn <- getColumn("ppt")

    # Ensure 'PPT' column is formatted correctly
    if (!is.null(pptColumn)) {
      demo[[pptColumn]] <- sub("\\.nii\\.gz$", "", demo[[pptColumn]])
    }

    # Try to match demographic data by PPT
    demographicData <- NULL
    if (!is.null(pptColumn)) {
      demographicData <- demo[demo[[pptColumn]] == fileBaseName, , drop = FALSE]
    }

    # If no match, fallback to demoRow selection
    if (is.null(demographicData) || nrow(demographicData) == 0) {
      if (!is.null(pptColumn)) {
        warning("No demographic data found for '", fileBaseName, "'. Using row ", demoRow, " instead.")
      }
      demographicData <- demo[demoRow, , drop = FALSE]
    }

    # Identify demographic columns
    groupColumn <- getColumn("group")
    sexColumn <- getColumn("sex")
    ageColumn <- getColumn("age")

    # Merge demographic data only if available
    if (nrow(demographicData) > 0) {
      demoData <- data.frame(
        PPT = rep(demographicData[[pptColumn]], each = nrow(dataframe)),
        Group = rep(demographicData[[groupColumn]], each = nrow(dataframe)),
        Sex = rep(demographicData[[sexColumn]], each = nrow(dataframe)),
        Age = rep(demographicData[[ageColumn]], each = nrow(dataframe))
      )
      dataframe <- cbind(demoData, dataframe)
    }
  }

  # 7. Reorder columns dynamically
  # ---------------------------
  columnOrder <- c("PPT", "Group", "Sex", "Age", "z", "x", "y", "pet")
  existingColumns <- intersect(columnOrder, names(dataframe))
  dataframe <- dataframe[, existingColumns]

  # 8. Return the processed data
  # ---------------------------
  return(dataframe)
}
