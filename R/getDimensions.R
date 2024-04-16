#' Get Dimensions from a DICOM File
#'
#' @description
#' This function loads a DICOM image file using the `oro.nifti` package and extracts its dimensions.
#' It provides the X and Y dimensions as well as the total number of elements ('dim') in the image data.
#'
#' @param filename `character`, optional; the name of the DICOM file to read.
#' If not provided, the function will search for the first `.img` file in the current working directory.
#' @return A list containing `xDim`, `yDim`, and `dim`, representing the dimensions of the image in the X and Y axes,
#' and the total number of elements in the image, respectively.
#' @details If no filename is provided, the function searches the current directory for the first file with a `.img` extension.
#' It stops with an error message if no such files are found. It is important to ensure that the specified file or files in the directory are in the DICOM format.
#' @examples
#' # If 'filename' is not provided, it will get the first image in the current working directory:
#' dimensions <- getDimensions()
#'
#' # Providing a specific filename:
#' dimensions <- getDimensions("003_S_1059.img")
#' @export
#'
#' @seealso \link[oro.nifti]{readNIfTI} for the function used to read the DICOM files.
#'


# Function to obtain dimensions from a DICOM file
getDimensions <- function(filename = NULL) {
  # If no filename is provided, find the first .img file in the current working directory
  if (is.null(filename)) {
    files <- list.files(path = getwd(), pattern = "\\.img$", full.names = TRUE, recursive = FALSE)
    if (length(files) == 0) {
      stop("No .img files found in the directory.")
    }
    filename <- files[1]  # Use the first file found
  }

  # Load the data using oro.nifti
  file <- oro.nifti::readNIfTI(fname = filename, verbose = FALSE, warn = -1, reorient = TRUE)

  # Get dimensions X and Y, and calculate 'dim'
  xDim <- file@dim_[2]
  yDim <- file@dim_[3]
  dim <- xDim * yDim

  # Return a list with X, Y, and 'dim' dimensions
  return(list(xDim = xDim, yDim = yDim, dim = dim))
}
