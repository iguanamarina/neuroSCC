#' Process ROIs and Save Data Tables
#'
#' @description
#' This function processes regions of interest (ROIs) from PET image data and saves the resulting data tables. It checks if the ROI tables already exist and, if not, processes the data using `neuroSCC::neuroCleaner` to clean and structure the data.
#'
#' @param base_dir The base directory where the ROI files and tables are located.
#' @param regions A vector of region names to be processed.
#' @param numbers A vector of numbers corresponding to the patient or control subjects.
#'
#' @details
#' `processROIs` iterates over each combination of region and number, checking if the corresponding ROI table file already exists. If the file does not exist, the function processes the data using `neuroSCC::neuroCleaner`, adds necessary metadata, and saves the cleaned data as an RDS file. The function provides informative messages about the progress of processing and file saving.
#'
#' @return This function does not return a value. It performs data processing and saves the resulting tables to the specified directory.
#'
#' @examples
#' # Assuming 'base_dir', 'regions', and 'numbers' are already defined
#' processROIs(base_dir, regions, numbers)
#'
#' @export
#'
processROIs <- function(base_dir, regions, numbers) {
  for (region in regions) {
    for (number in numbers) {
      roi_table_path <- file.path(base_dir, "roisNormalizadas/tables", paste0("ROItable_", region, "_", number, ".RDS"))

      if (file.exists(roi_table_path)) {
        print(paste0("The table for region ", region, " and number C", number, " already exists."))
      } else {
        print(paste0("Processing ROI for region ", region, " and number C", number))
        roi_table <- data.frame(group = integer(), z = integer(), x = integer(), y = integer())

        # Set the working directory
        working_dir <- file.path(base_dir, "roisNormalizadas")
        setwd(working_dir)

        # Construct the file name
        name <- paste0("wwwx", region, "_redim_crop_squ_flipLR_newDim_", "C", number, ".nii")

        # Load and clean the data
        temporal <- neuroSCC::neuroCleaner(name)

        # Add group information
        group <- rep(paste0(as.character(region), "_number", "C", number), length.out = nrow(temporal))
        temporal <- cbind(group, temporal)

        # Replace NaN values in 'pet' column with 0
        temporal$pet[is.nan(temporal$pet)] <- 0

        # Append to the main data frame
        roi_table <- rbind(roi_table, temporal)

        # Save the resulting table
        saveRDS(roi_table, file = roi_table_path)
        print(paste0("Saved the file: ", roi_table_path))
      }
    }
  }
}
