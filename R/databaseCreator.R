#' Create a database of processed PET image data with the appropiate format
#'
#' @description
#' This function automates the processing of PET images based on a specified file name pattern within a working directory.
#' It reads each file matching the pattern, processes it using `neuroSCC::neuroCleaner`, and compiles the results into a comprehensive data frame.
#'
#' @param pattern `character`, a regular expression pattern that specifies which files to process.
#' @return A `data.frame` that aggregates processed data from each image. Each row represents data from one image, including subject numbers and image data.
#' @details The function first checks if there are files matching the pattern in the working directory.
#' If no files are found, it throws an error. Otherwise, it processes each file individually, extracts necessary data,
#' and appends it to a growing database. The function leverages `neuroSCC::neuroCleaner` for data processing.
#' Each file's subject number is extracted from its name using regular expressions.
#'
#' @examples
#' # Set the working directory where your PET images are stored
#' setwd("~/GitHub/PhD-2023-Neuroimage-article-SCC-vs-SPM/PETimg_masked for simulations")
#'
#' # Define the pattern for file names to process
#' pattern <- "^masked_swwwC\\d+_tripleNormEsp_w00_rrec_OSEM3D_32_it1.nii"
#'
#' # Create the database
#' database_CN <- databaseCreator(pattern)
#'
#' @export
#' @seealso \link[neuroSCC]{neuroCleaner} for the underlying image processing.
#'

databaseCreator <- function(pattern) {
  # Get the list of files matching the pattern
  files <- list.files(pattern = pattern, full.names = TRUE)

  # Check if files list is empty
  if (length(files) == 0) {
    stop("Error: No files with this pattern in this working directory.")
  }

  # Initialize the database for Control group images
  database_CN <- data.frame(CN_number = integer(), z = integer(), x = integer(), y = integer(), pet = numeric())

  # Process each file and append to the database
  for(file in files) {
    # Use neuroSCC::neuroCleaner to process the file
    temporal <- neuroSCC::neuroCleaner(file)
    # Extract the number from the file name using a regular expression
    CN_number <- sub("masked_swwwC(\\d+)_.*", "\\1", basename(file))
    # Print the current control number being processed
    print(paste("Processing Control Nº", CN_number))
    # Repeat the number for each row in the temporal data frame
    temporal$CN_number <- rep(CN_number, nrow(temporal))
    # Append the processed data to the main database
    database_CN <- rbind(database_CN, temporal)
  }

  # Return the complete database
  return(database_CN)
}
