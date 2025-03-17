#' Process ROIs and Save Data Tables
#'
#' @description
#' This function processes **Regions of Interest (ROIs)** from binary NIfTI files containing
#' manually defined hypoactive regions. It extracts voxel coordinates where `pet = 1` (indicating
#' hypoactivity) and formats them into structured `.RDS` tables.
#'
#' The function is originally designed for the **Ph.D. thesis**:
#' *"Development of statistical methods for the analysis of neuroimage data towards early diagnosis of neurodegenerative diseases"*
#' conducted at the **University of Santiago de Compostela** by *Juan A. Arias Lopez, Prof. Pablo Aguiar-Fernández,
#' Prof. Andrew H. Kemp, & Prof. Carmen Cadarso-Suárez*.
#' However, options are provided for **other users and setups**.
#'
#' @param roiDir \code{character}, the base directory where the ROI NIfTI files are stored.
#'        Default: `"~/GitHub/PhD-2024-SCC-vs-SPM-SinglePatient-vs-Group/roisNormalizadas"`.
#' @param outputDir \code{character}, the directory where processed `ROItable_*` files will be saved.
#'        Default: `"~/GitHub/PhD-2024-SCC-vs-SPM-SinglePatient-vs-Group/roisNormalizadas/tables"`.
#' @param regions \code{character} vector, specifying the ROI region names (e.g., `c("w32", "w79")`).
#' @param numbers \code{integer} vector, specifying the patient/control numbers (e.g., `1:16`).
#' @param filePattern \code{character}, a template for the expected NIfTI filenames.
#'        Should include \verb{{region}} and \verb{{number}} placeholders.
#'        Default: \code{"wwwx\{region\}_redim_crop_squ_flipLR_newDim_C\{number\}.nii"}.
#' @param verbose \code{logical}, if \code{TRUE}, prints progress messages. Default: \code{FALSE}.
#'
#' @return This function does not return a value. It **processes and saves `.RDS` files** in `outputDir`.
#'
#' @details
#' - This function **extracts voxel coordinates** (`x, y, z`) where `pet = 1` (indicating hypoactivity).
#' - The **default filename structure** is based on the research thesis setup but can be adjusted.
#' - Processed tables are saved as **`ROItable_*`** `.RDS` files for later use in **SCC vs. SPM comparisons**.
#'
#' @examples
#' \dontrun{
#' # Process ROIs using the thesis default setup
#' processROIs()
#'
#' # Custom example for a different dataset
#' processROIs(
#'   roiDir = "/custom/path/rois",
#'   outputDir = "/custom/path/tables",
#'   regions = c("region1", "region2"),
#'   numbers = 1:10,
#'   filePattern = "custom_prefix_{region}_sub_{number}.nii",
#'   verbose = TRUE
#' )
#' }
#'
#' @export
processROIs <- function(
    roiDir = "~/GitHub/PhD-2024-SCC-vs-SPM-SinglePatient-vs-Group/roisNormalizadas",
    outputDir = "~/GitHub/PhD-2024-SCC-vs-SPM-SinglePatient-vs-Group/roisNormalizadas/tables",
    regions,
    numbers,
    filePattern = "wwwx{region}_redim_crop_squ_flipLR_newDim_C{number}.nii",
    verbose = FALSE
) {
  # 1. Validate Inputs
  # ---------------------------
  if (!dir.exists(roiDir)) stop("ROI directory not found: ", roiDir)
  if (!dir.exists(outputDir)) dir.create(outputDir, recursive = TRUE)

  if (missing(regions) || missing(numbers)) {
    stop("Both 'regions' and 'numbers' must be specified.")
  }

  # 2. Process Each Region and Patient
  # ---------------------------
  for (region in regions) {
    for (number in numbers) {
      # Construct file paths dynamically
      niftiFilename <- gsub("\\{region\\}", region, gsub("\\{number\\}", number, filePattern))
      niftiPath <- file.path(roiDir, niftiFilename)
      rdsPath <- file.path(outputDir, paste0("ROItable_", region, "_", number, ".RDS"))

      # Check if the RDS file already exists
      if (file.exists(rdsPath)) {
        message("The table for region ", region, " and number C", number, " already exists.")
        next  # Skip processing
      }

      # Check if the NIfTI file exists
      if (!file.exists(niftiPath)) {
        if (verbose) message("Skipping: File not found: ", niftiPath)
        next
      }

      # Load NIfTI file and extract data
      if (verbose) message("Processing ROI for: ", region, " | Subject C", number)

      roiData <- tryCatch({
        neuroSCC::neuroCleaner(niftiPath)
      }, error = function(e) {
        message("Error loading: ", niftiPath, " - ", e$message)
        return(NULL)
      })

      if (is.null(roiData)) next  # Skip if loading failed

      # 3. Extract Relevant Voxels (Where pet == 1)
      # ---------------------------
      roiData <- subset(roiData, pet == 1)  # Keep only active voxels
      if (nrow(roiData) == 0) {
        if (verbose) message("No significant voxels in: ", niftiPath)
        next
      }

      # Add group identifier
      roiData$group <- paste0(region, "_numberC", number)
      roiData <- roiData[, c("group", "z", "x", "y", "pet")]  # Reorder columns

      # 4. Save Processed Table
      # ---------------------------
      saveRDS(roiData, rdsPath)
      if (verbose) message("Saved: ", rdsPath)
    }
  }
}
