#' Create a database of processed PET image data with the appropriate format
#'
#' @description
#' This function automates the processing of PET images based on a specified file name pattern within a working directory.
#' It reads each file matching the pattern, processes it using `neuroSCC::neuroCleaner`, and compiles the results into a comprehensive data frame.
#' The function can handle both control and pathological data based on the `control` parameter.
#'
#' @param pattern `character`, a regular expression pattern that specifies which files to process.
#' @param control `logical`, if `TRUE`, the function processes control group images and if `FALSE`, it processes pathological group images. Default is `TRUE`.
#' @return A `data.frame` that aggregates processed data from each image. Each row represents data from one image, including subject numbers and image data.
#' @details The function first checks if there are files matching the pattern in the working directory.
#' If no files are found, it throws an error. Otherwise, it processes each file individually, extracts necessary data,
#' and appends it to a growing database. The function leverages `neuroSCC::neuroCleaner` for data processing.
#' Each file's subject number is extracted from its name using regular expressions. Depending on the `control` parameter,
#' the database will have either a `CN_number` column for control data or an `AD_number` column for pathological data.
#'
#' @examples
#' # Set the working directory where your PET images are stored
#' setwd("~/GitHub/PhD-2023-Neuroimage-article-SCC-vs-SPM/PETimg_masked for simulations")
#'
#' # Define the pattern for file names to process
#' pattern <- "^masked_swwwC\\d+_tripleNormEsp_w00_rrec_OSEM3D_32_it1.nii"
#'
#' # Create the database for control group images
#' database_CN <- databaseCreator(pattern, control = TRUE)
#'
#' # Create the database for pathological group images
#' database_AD <- databaseCreator(pattern, control = FALSE)
#'
#' @export
#' @seealso \link[neuroSCC]{neuroCleaner} for the underlying image processing.
#'

databaseCreator <- function(pattern, control = TRUE) {
  # Get the list of files matching the pattern
  files <- list.files(pattern = pattern, full.names = TRUE)

  # Check if files list is empty
  if (length(files) == 0) {
    stop("Error: No files with this pattern in this working directory.")
  }

  # Initialize the database for Control or Pathological group images
  if (control) {
    database <- data.frame(CN_number = integer(), z = integer(), x = integer(), y = integer(), pet = numeric())
    group_label <- "Control"
    number_label <- "CN_number"
  } else {
    database <- data.frame(AD_number = integer(), z = integer(), x = integer(), y = integer(), pet = numeric())
    group_label <- "Pathological"
    number_label <- "AD_number"
  }

  # Process each file and append to the database
  for(file in files) {
    # Use neuroSCC::neuroCleaner to process the file
    temporal <- neuroSCC::neuroCleaner(file)
    # Extract the number from the file name using a regular expression
    number <- sub("masked_swwwC(\\d+)_.*", "\\1", basename(file))
    # Print the current control or pathological number being processed
    print(paste("Processing", group_label, "Nº", number))
    # Repeat the number for each row in the temporal data frame
    temporal[[number_label]] <- rep(number, nrow(temporal))
    # Append the processed data to the main database
    database <- rbind(database, temporal)
  }

  # Return the complete database
  return(database)
}
