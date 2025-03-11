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
#' 1. Reads the NIFTI file using \code{oro.nifti} package functions
#' 2. Converts the 3D image data to a structured data frame
#' 3. Extracts the dimensional information (\code{z}, \code{x}, \code{y} coordinates)
#' 4. Organizes the PET intensity values
#' 5. If demographic data is provided, merges it with the image data
#'
#' The resulting data frame serves as input for subsequent analysis functions in the
#' neuroSCC pipeline, such as \code{databaseCreator} and \code{matrixCreator}, which prepare
#' the data for eventual analysis with the ImageSCC package functions.
#'
#' @examples
#' # Example 1: Using package sample data
#' \dontrun{
#' # Access sample files included with the package
#' data_dir <- system.file("extdata", package = "neuroSCC")
#' nifti_file <- file.path(data_dir, "sampleFile1.nii")
#'
#' # Basic usage with just a NIFTI file
#' pet_data <- neuroCleaner(nifti_file)
#'
#' # Display the first few rows of the result
#' head(pet_data)
#' #>   z x  y      pet
#' #>   1 1  1  0.00000
#' #>   1 1  2  0.00000
#' #>   1 1  3  0.78526
#' #>   ...
#'
#' # Example 2: With demographic data
#' # Load demographic data
#' demo_file <- file.path(data_dir, "Demographics.csv")
#' demo_data <- read.csv(demo_file)
#'
#' # Display the demographic data
#' print(demo_data)
#' #>         PPT Group Sex Age
#' #> 1 041_S_1391    AD   M  85
#' #> 2 036_S_1001    AD   M  69
#' #> 3 037_S_0627    AD   F  59
#'
#' # Process the first NIFTI file with demographic data
#' # This will attempt to match based on filename
#' pet_with_demo <- neuroCleaner(nifti_file, demo = demo_data)
#'
#' # Display the first few rows with demographic information
#' head(pet_with_demo)
#' #>         PPT Group Sex Age z x  y      pet
#' #>  041_S_1391    AD   M  85 1 1  1  0.00000
#' #>  041_S_1391    AD   M  85 1 1  2  0.00000
#' #>  041_S_1391    AD   M  85 1 1  3  0.78526
#' #>  ...
#'
#' # Example 3: Using a specific row from demographic data
#' # Process another NIFTI file and specify which demographic row to use
#' nifti_file2 <- file.path(data_dir, "sampleFile2.nii")
#' pet_with_specific_demo <- neuroCleaner(nifti_file2, demo = demo_data, demoRow = 3)
#'
#' # Display the first few rows (now with demographic info from row 3)
#' head(pet_with_specific_demo)
#' #>         PPT Group Sex Age z x  y      pet
#' #>  037_S_0627    AD   F  59 1 1  1  0.00000
#' #>  037_S_0627    AD   F  59 1 1  2  0.00000
#' #>  037_S_0627    AD   F  59 1 1  3  0.78526
#' #>  ...
#' }
#'
#' # Example 4: Creating synthetic data (fully reproducible)
#' # Create a simple 3D array as a synthetic NIFTI image
#' if (requireNamespace("oro.nifti", quietly = TRUE)) {
#'   # Temporary file path
#'   temp_nii <- tempfile(fileext = ".nii")
#'
#'   # Create a small synthetic NIFTI file (3x3x3)
#'   img_data <- array(1:27, dim = c(3, 3, 3))
#'   nii_obj <- oro.nifti::nifti(img_data)
#'   oro.nifti::writeNIfTI(nii_obj, filename = temp_nii, verbose = FALSE)
#'
#'   # Sample demographic data
#'   demo_data <- data.frame(
#'     PPT = c("sample001", "sample002", "sample003"),
#'     Group = c("Control", "Patient", "Patient"),
#'     Sex = c("M", "F", "M"),
#'     Age = c(65, 70, 75)
#'   )
#'
#'   # Process the synthetic NIFTI with demographic data (use row 2)
#'   # This will not run if oro.nifti is not installed
#'   pet_data <- neuroCleaner(temp_nii, demo = demo_data, demoRow = 2)
#'   head(pet_data)
#' }
#'
#' @seealso
#' \code{\link{databaseCreator}} for creating databases from multiple NIFTI files.
#'
#' \code{oro.nifti::readNIfTI} for the underlying function used to read NIFTI files.
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
    demo_cols <- tolower(names(demo))
    required_cols <- c("ppt", "group", "sex", "age")

    # We'll use what we have rather than requiring all columns
    # Just warn if important ones are missing
    if (!("ppt" %in% demo_cols)) {
      warning("Demographic data doesn't contain 'PPT' column. Will use row ", demoRow, " instead.")
    }

    # Validate that demoRow exists in the data frame
    if (demoRow > nrow(demo)) {
      stop("'demoRow' (", demoRow, ") exceeds the number of rows in the demographic data (", nrow(demo), ")")
    }
  }

  # 2. Read NIFTI file
  # ---------------------------
  # Using tryCatch to handle potential errors during file reading
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
  # Extract the image data into a data frame
  n <- tryCatch({
    memisc::to.data.frame(oro.nifti::img_data(file))
  }, error = function(e) {
    stop("Error converting NIFTI data to data frame: ", e$message)
  })

  # 4. Extract dimensional information
  # ---------------------------
  # Use the new getDimensions function to extract image dimensions
  dimensions <- neuroSCC::getDimensions(file)

  # Store file name for reference
  namex <- as.character(name)

  # Get dimensions from the extracted information
  xDim <- dimensions$xDim
  yDim <- dimensions$yDim
  dim <- dimensions$dim

  # Prepare empty data frame for storing the processed data
  dataframe <- data.frame(z = integer(), x = integer(), y = integer(), pet = numeric())

  # 5. Process each slice and organize data
  # ---------------------------
  for (i in seq(1:xDim)) {
    # Select one Z slice
    n_lim <- n[n$Var2 == i, ]
    n_lim$Var1 <- NULL
    n_lim$Var2 <- NULL

    # Create coordinate vectors
    z <- rep(i, length.out = dim)
    x <- rep(1:xDim, each = yDim, length.out = dim)
    y <- rep(1:yDim, length.out = dim)

    # Extract PET intensity values
    pet <- unlist(n_lim)

    # Combine coordinates and intensity values
    temp <- data.frame(z, x, y, pet)

    # Append to the main dataframe
    dataframe <- rbind(dataframe, temp)
  }

  # 6. Merge with demographic data (if provided)
  # ---------------------------
  if (!is.null(demo)) {
    # Find column names case-insensitively
    get_col <- function(col_name) {
      idx <- which(tolower(names(demo)) == tolower(col_name))
      if (length(idx) > 0) return(names(demo)[idx[1]])
      return(NULL)
    }

    ppt_col <- get_col("ppt")

    # Initialize demog to NULL to handle both pathways
    demog <- NULL

    # Try to match by PPT if the column exists
    if (!is.null(ppt_col)) {
      # Extract just the filename without path for matching
      file_basename <- basename(namex)

      # Extract demographic data for the current participant
      demog <- demo[demo[[ppt_col]] == file_basename, ]

      # If no direct match, try matching with the full path
      if (nrow(demog) == 0) {
        demog <- demo[demo[[ppt_col]] == namex, ]
      }

      # Check if multiple matching rows were found
      if (nrow(demog) > 1) {
        warning("Multiple demographic matches found for '", namex, "'. Using row ", demoRow, " of the matches.")
        demog <- demog[1, , drop = FALSE]  # Use the first matching row
      }
    }

    # If no match was found or PPT column doesn't exist, use the specified row
    if (is.null(demog) || nrow(demog) == 0) {
      if (!is.null(ppt_col)) {
        warning("No demographic data found for '", namex, "'. Using row ", demoRow, " instead.")
      }
      demog <- demo[demoRow, , drop = FALSE]
    }

    # Identify available demographic columns
    group_col <- get_col("group")
    sex_col <- get_col("sex")
    age_col <- get_col("age")

    # Create a data frame with available demographic data
    demo_data <- data.frame()

    # Add each available column
    if (!is.null(ppt_col)) {
      demo_data$PPT <- rep(demog[[ppt_col]], length.out = nrow(dataframe))
    }

    if (!is.null(group_col)) {
      demo_data$Group <- rep(demog[[group_col]], length.out = nrow(dataframe))
    }

    if (!is.null(sex_col)) {
      demo_data$Sex <- rep(demog[[sex_col]], length.out = nrow(dataframe))
    }

    if (!is.null(age_col)) {
      demo_data$Age <- rep(demog[[age_col]], length.out = nrow(dataframe))
    }

    # Combine demographic and image data
    if (ncol(demo_data) > 0) {
      dataframe <- cbind(demo_data, dataframe)
    }
  }

  # 7. Return the processed data
  # ---------------------------
  return(dataframe)
}
