#' Generate Synthetic Poisson Clones for PET Data
#'
#' @description
#' This function generates synthetic clones of a PET data matrix by adding Poisson-distributed
#' noise to each non-zero voxel. This is necessary to circumvent the limitations of functional
#' data analysis (FDA) in **single patient vs. group (1 vs. Group) setups**, where a single subject
#' does not provide enough variability to estimate Simultaneous Confidence Corridors (SCCs) reliably.
#'
#' @param originalMatrix A numeric matrix where each row represents a flattened PET image.
#' @param numClones An integer specifying the number of synthetic clones to generate.
#' @param lambdaFactor A positive numeric value controlling the magnitude of Poisson noise.
#'
#' @return A numeric matrix with `numClones` rows, each containing a modified version of `originalMatrix`
#'         with added Poisson noise.
#'
#' @details
#' - Values of `0` remain unchanged to preserve background regions.
#' - `NA` values are replaced with `0` before adding noise.
#' - Poisson noise is applied only to positive values, scaled by `lambdaFactor`.
#' - This approach allows **SCC methods to operate in 1 vs. Group analyses**, ensuring statistical
#'   validity when a single observation is not sufficient.
#'
#' @examples
#' \dontrun{
#'   # Simulated PET matrix (3 subjects, 4 pixels each)
#'   petMatrix <- matrix(c(5, 10, 15, 0,
#'                         3, 8, 12, 0,
#'                         7, 14, 21, 0), nrow = 3, byrow = TRUE)
#'
#'   # Generate 5 synthetic clones
#'   clones <- generatePoissonClones(petMatrix, numClones = 5, lambdaFactor = 0.01)
#'
#'   # Check the cloned dataset
#'   print(clones)
#' }
#'
#' @export
generatePoissonClones <- function(originalMatrix, numClones, lambdaFactor) {

  # 1. Input validation
  # ---------------------------
  if (!is.matrix(originalMatrix)) {
    stop("'originalMatrix' must be a numeric matrix.")
  }
  if (!is.numeric(originalMatrix)) {
    stop("'originalMatrix' must contain only numeric values.")
  }
  if (!is.integer(numClones) && numClones != as.integer(numClones) || numClones <= 0) {
    stop("'numClones' must be a positive integer.")
  }
  if (!is.numeric(lambdaFactor) || lambdaFactor <= 0) {
    stop("'lambdaFactor' must be a positive numeric value.")
  }

  # 2. Prepare output matrix
  # ---------------------------
  numPixels <- ncol(originalMatrix)  # Number of PET pixels (columns)
  cloneMatrix <- matrix(NA, nrow = numClones, ncol = numPixels)  # Preallocate

  # 3. Clone generation
  # ---------------------------
  for (i in seq_len(numClones)) {
    # Apply Poisson noise only to non-zero values
    noise <- ifelse(originalMatrix > 0,
                    rpois(length(originalMatrix), lambda = originalMatrix * lambdaFactor),
                    0)

    # Generate a new synthetic row
    cloneMatrix[i, ] <- originalMatrix + noise
  }

  # 4. Return cloned matrix
  # ---------------------------
  return(cloneMatrix)
}
