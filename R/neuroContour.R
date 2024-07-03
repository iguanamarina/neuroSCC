#' Obtain and save neuroimaging contours
#'
#' @description
#' This function extracts contours from neuroimaging data where values change according to specified levels.
#' It uses the `contoureR::getContourLines` function to obtain the contours and stores the coordinates in a list.
#'
#' @param data `data.frame`, a data frame containing the neuroimaging data to process.
#' @param levels `numeric`, a vector of levels at which to draw the contours. Default is `c(0)`.
#' @return A `list` of data frames, where each data frame contains the x and y coordinates of a contour.
#' @details The function filters the contours by their `GID` and stores the coordinates of each contour in a list.
#' It ensures that the `contoureR` package is loaded before attempting to use its functions.
#'
#' @examples
#' # Example usage:
#' # Load sample data
#' data <- some_neuroimaging_data
#'
#' # Get contours at level 0
#' contours <- neuroContour(data, levels = c(0))
#'
#' # Plot the first contour
#' plot(contours[[1]])
#' if (length(contours) > 1) {
#'   for (j in 2:length(contours)) {
#'     points(contours[[j]]) # Holes or internal contours
#'   }
#' }
#'
#' @export
#' @seealso \link[contoureR]{getContourLines} for the underlying contour extraction.
#'
neuroContour <- function(data, levels = c(0)) {
  # Ensure the contoureR package is available
  if (!requireNamespace("contoureR", quietly = TRUE)) {
    stop("Package 'contoureR' is required but not installed. Please install it first.")
  }

  # Obtain contours from the data
  contour <- contoureR::getContourLines(data, levels = levels)

  # Create a list to store the coordinates of each contour
  coord <- list()

  # Loop to obtain and store the coordinates of each contour
  for (i in unique(contour$GID)) {
    aa <- contour[contour$GID == i,] # Filter by GID
    a <- aa[, c("x", "y")] # Keep only the x and y coordinates
    coord[[i + 1]] <- a # Store the coordinates in the list
  }

  return(coord)
}
