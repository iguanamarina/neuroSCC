#' Mean Average Normalization for SCC Data
#'
#' @description
#' This function normalizes each row of the given SCC data by its mean value.
#' It divides each element in a row by the mean of that row, ignoring NA values.
#'
#' @param SCC_data `matrix`, a matrix where each row represents SCC data to be normalized.
#' @return A `matrix` where each row has been normalized by its mean value.
#' @details The function iterates over each row of the SCC data matrix, calculates the mean of the row,
#' and then divides each element of the row by the calculated mean.
#'
#' @examples
#' # Assume SCC_data is a matrix of SCC values
#' normalized_SCC_data <- neuroSCC::meanNormalization(SCC_data)
#'
#' @export
meanNormalization <- function(SCC_data) {
  for (k in 1:nrow(SCC_data)) {
    temp <- SCC_data[k, ]
    mean_val <- mean(as.numeric(temp), na.rm = TRUE)
    SCC_data[k, ] <- temp / mean_val
  }
  return(SCC_data)
}
