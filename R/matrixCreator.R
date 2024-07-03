#' Convert PET image data to a functional data matrix format
#'
#' @description
#' This function transforms PET image data, previously processed into a database format by `databaseCreator`, into a matrix format suitable for functional data analysis. Each row of the matrix represents a function, corresponding to data from one patient or control subject. The function recognizes whether the matrix is for Control or Alzheimer's group.
#'
#' @param database A data frame containing the PET image data with columns for 'CN_number', 'z', 'x', 'y', and 'pet' values, created by `databaseCreator`.
#' @param pattern The regular expression pattern to match filenames in the database. This pattern should correspond to the naming conventions of the PET image files you want to process.
#' @param param.z The specific z-coordinate slice to analyze. This parameter should be defined prior to running this function if not included in the script that calls it.
#' @param xy The total number of data points per z-slice, calculated as the product of the dimensions x and y of the image slice. If not predefined, it must be calculated by the user based on the image dimensions.
#'
#' @return A matrix where each row represents the PET data from one control subject, formatted as a continuous line of data points to simulate a function.
#'
#' @details
#' `matrixCreator` follows `databaseCreator` in the data processing workflow. It reads the data for each file specified by the matched pattern and extracts only the data for the specified z-slice. The function ensures that each row in the resulting matrix corresponds to one patient or control subject, transforming each subset of data into a format suitable for functional data analysis.
#'
#' @examples
#' # Assuming 'database_CN', 'pattern', 'param.z', and 'xy' are already defined
#' SCC_CN <- matrixCreator(database_CN, pattern, param.z, xy)
#'
#' @seealso \link[databaseCreator]{databaseCreator} and \link[neuroCleaner]{neuroCleaner} for initial data processing and image cleaning.
#'
#' @export
#'

matrixCreator <- function(database, pattern, param.z, xy) {
  # Get the list of files matching the pattern
  files <- list.files(pattern = pattern, full.names = TRUE)

  # Determine if the database is for controls (CN) or pathological (AD)
  if ("CN_number" %in% colnames(database)) {
    group_label <- "CN_number"
    label <- "Control Nº"
  } else if ("AD_number" %in% colnames(database)) {
    group_label <- "AD_number"
    label <- "Pathological Nº"
  } else {
    stop("Error: Database must contain either 'CN_number' or 'AD_number' column.")
  }

  # Preallocate the matrix with appropriate dimensions
  SCC_matrix <- matrix(nrow = length(files), ncol = xy)

  # Loop through the files to process each one
  for (i in seq_along(files)) {
    # Extract the number from the filename using the adjusted pattern
    number <- sub("masked_swwwC(\\d+)_.*", "\\1", basename(files[i]))
    print(paste("Converting", label, number))

    # Subset the database for the current number and z coordinate
    subset_data <- database[database[[group_label]] == number & database$z == param.z, ]

    # Extract the 'pet' values, assuming they are ordered to fill one row in the matrix
    Y <- subset_data[1:xy, "pet"]
    # Convert to matrix and transpose, replacing NaN values with 0
    Y <- t(as.matrix(Y))
    Y[is.nan(Y)] <- 0

    # Assign the processed data to the matrix row
    SCC_matrix[i, ] <- Y
  }

  # Return the matrix
  return(SCC_matrix)
}


