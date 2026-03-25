#' Obtain neuroimaging contours from a NIFTI file
#'
#' @description
#' This function extracts contours from a neuroimaging NIFTI file by identifying
#' the boundary of the non-zero image support in a selected z-slice.
#' These contours serve as input for \code{Triangulation::TriMesh},
#' which is used in Simultaneous Confidence Corridors (SCCs) calculations.
#'
#' It is highly recommended that the input NIFTI file be pre-processed such that
#' zero values represent the background and non-zero values represent regions of interest.
#'
#' @param niftiFile \code{character}, the path to the NIFTI file containing neuroimaging data.
#'        Ideally, the file should be masked so that zero values represent the background.
#' @param paramZ \code{integer}, the specific z-slice to extract contours from. Default is \code{35}.
#' @param plotResult \code{logical}, if \code{TRUE}, plots the extracted contours. Default is \code{FALSE}.
#'
#' @return A \code{list} of data frames, where each data frame contains the x and y coordinates of a contour.
#' The first element typically represents the external boundary, while subsequent elements (if present)
#' represent internal contours or holes. Each data frame has two columns:
#' \itemize{
#'   \item \code{x} - x-coordinates of the contour points.
#'   \item \code{y} - y-coordinates of the contour points.
#' }
#'
#' @details
#' This function extracts contours from a \strong{NIFTI} file, typically a masked image where
#' background values are zero and regions of interest contain non-zero values.
#' Contours are computed from the boundary of the non-zero support of the selected slice.
#'
#' The extracted contours are typically used as input to \code{Triangulation::TriMesh}
#' to create a triangular mesh of the region, which is then used for
#' Simultaneous Confidence Corridors calculations.
#'
#' @examples
#' # Get the file path for a sample NIfTI file
#' niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")
#'
#' # Extract contours from the non-zero support
#' contours <- neuroContour(niftiFile, paramZ = 35, plotResult = TRUE)
#'
#' # Display the first few points of the main contour
#' head(contours[[1]])
#'
#' @seealso
#' \code{Triangulation::TriMesh} for the next step in the SCC calculation process.
#'
#' @export
#' @importFrom graphics points
neuroContour <- function(niftiFile, paramZ = 35, plotResult = FALSE) {
  # 1. Input validation
  # ---------------------------
  # Check if niftiFile is a valid file path
  if (!is.character(niftiFile) || length(niftiFile) != 1) {
    stop("'niftiFile' must be a single character string specifying the file path")
  }

  if (!file.exists(niftiFile)) {
    stop("File not found: ", niftiFile)
  }

  # Check if paramZ is an integer
  if (!is.numeric(paramZ) || length(paramZ) != 1 || paramZ <= 0) {
    stop("'paramZ' must be a positive integer specifying the slice number")
  }

  # Check if plotResult is logical
  if (!is.logical(plotResult) || length(plotResult) != 1) {
    stop("'plotResult' must be a single logical value (TRUE or FALSE)")
  }

  # 2. Process NIFTI file with neuroCleaner
  # ---------------------------
  template <- neuroSCC::neuroCleaner(niftiFile)

  # Extract specific z-slice
  template <- subset(template, template$z == paramZ)

  if (nrow(template) == 0) {
    stop("No data found for the specified z-slice: ", paramZ)
  }

  # Get image dimensions
  xMax <- max(template$x)
  yMax <- max(template$y)
  xyTotal <- xMax * yMax

  # Convert PET values to a matrix format
  templateValues <- t(as.matrix(template[, "pet"]))
  templateValues[is.nan(templateValues)] <- 0

  # Create coordinate grid
  xCoords <- rep(1:xMax, each = yMax, length.out = xyTotal)
  yCoords <- rep(1:yMax, length.out = xyTotal)
  coordinates <- cbind(as.matrix(xCoords), as.matrix(yCoords))

  # Combine into a formatted data frame
  dat <- as.data.frame(cbind(coordinates, t(templateValues)))
  names(dat) <- c("x", "y", "value")
  dat[is.na(dat)] <- 0
  rownames(dat) <- NULL

  # 3. Contour extraction
  # ---------------------------
  coord <- tryCatch({
    .extract_mask_contours(dat, contour_level = 0.1)
  }, error = function(e) {
    stop("Error extracting contours: ", e$message)
  })

  # Check if contours were found
  if (length(coord) == 0) {
    warning("No contours found. Returning empty list.")
    return(list())
  }

  # 5. Optional plotting
  # ---------------------------
  if (plotResult && length(coord) > 0) {
    plot(coord[[1]], type = "l", xlab = "x", ylab = "y", main = "Extracted Contours")

    # Add any internal contours (holes)
    if (length(coord) > 1) {
      for (j in 2:length(coord)) {
        points(coord[[j]])
      }
    }
  }

  # 6.   Ensure plotting works even when assigned to an object
  # ---------------------------
  if (plotResult) {
    return(invisible(coord))  # Prevents suppression of plots while allowing assignment
  }

  return(coord)
}
