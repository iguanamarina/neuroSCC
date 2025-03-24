#' Get Dimensions from a Neuroimaging File
#'
#' @description
#' Extracts dimensional information from NIFTI or similar neuroimaging files.
#' This function is designed to work together with \code{neuroCleaner()}
#' but can also be used independently for informative purposes.
#'
#' @param file A NIFTI file object or filename to extract dimensions from.
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{xDim}: Number of voxels in the X dimension
#'   \item \code{yDim}: Number of voxels in the Y dimension
#'   \item \code{zDim}: Number of slices in the Z dimension
#'   \item \code{dim}: Total number of voxels (xDim * yDim)
#' }
#'
#' @details
#' The function can handle both NIFTI file paths and pre-loaded oro.nifti file objects.
#' It provides a consistent way to extract dimensional information across the package.
#'
#' @examples
#' # Get the file path for a sample NIfTI file
#' niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")
#'
#' # Extract dimensions from the NIfTI file
#' dimensions <- getDimensions(niftiFile)
#'
#' # Display the extracted dimensions
#' print(dimensions)
#'
#' @export
getDimensions <- function(file) {
  # Input validation
  if (missing(file)) {
    stop("A NIFTI file or file path must be provided")
  }

  # Handle different input types
  if (is.character(file)) {
    # If a file path is provided, read the NIFTI file
    tryCatch({
      file <- oro.nifti::readNIfTI(fname = file, verbose = FALSE, warn = -1)
    }, error = function(e) {
      stop("Unable to read the NIFTI file: ", e$message)
    })
  }

  # Validate that the input is a NIFTI object
  if (!inherits(file, "nifti")) {
    stop("Input must be a NIFTI file path or a nifti object")
  }

  # Extract dimensions
  xDim <- file@dim_[2]
  yDim <- file@dim_[3]
  zDim <- file@dim_[4]
  dim <- xDim * yDim

  # Return dimensions
  list(
    xDim = xDim,
    yDim = yDim,
    zDim = zDim,
    dim = dim
  )
}
