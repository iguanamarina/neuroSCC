#' Generate Synthetic Poisson Clones for PET Data
#'
#' @description
#' Generates synthetic clones of a PET data matrix by adding Poisson-distributed
#' noise to each non-zero voxel. This approach helps address the limitations of functional
#' data analysis (FDA) in **single patient vs. group (1 vs. Group) setups**, where a single subject
#' lacks sufficient variability to reliably estimate Simultaneous Confidence Corridors (SCCs).
#'
#' @param originalMatrix A numeric matrix where each row represents a flattened PET image.
#' @param numClones An integer specifying the number of synthetic clones to generate.
#' @param lambdaFactor A positive numeric value that scales the magnitude of Poisson noise.
#'
#' @return A numeric matrix with \code{numClones} rows, each representing a noisy version
#'         of \code{originalMatrix} with Poisson noise added.
#'
#' @details
#' \itemize{
#'   \item Values equal to \code{0} remain unchanged to preserve background regions.
#'   \item \code{NA} values are replaced with \code{0} before adding noise.
#'   \item Poisson noise is applied only to positive values, scaled by \code{lambdaFactor}.
#'   \item Enables valid SCC estimation in single-subject settings by artificially increasing sample size.
#' }
#'
#' @examples
#' # Get a single patient's PET data matrix
#' dataDir <- system.file("extdata", package = "neuroSCC")
#' pathologicalPattern <- "^syntheticPathological.*\\.nii.gz$"
#' databasePathological <- databaseCreator(pattern = pathologicalPattern,
#'                                         control = FALSE,
#'                                         quiet = TRUE)
#' matrixPathological <- matrixCreator(databasePathological, paramZ = 35, quiet = TRUE)
#' patientMatrix <- matrixPathological[1, , drop = FALSE]  # Select a single patient
#'
#' # Select 10 random columns for visualization
#' set.seed(123)
#' sampledCols <- sample(ncol(patientMatrix), 10)
#'
#' # Show voxel intensity values before cloning
#' patientMatrix[, sampledCols]
#'
#' # Generate 5 synthetic clones with Poisson noise
#' clones <- generatePoissonClones(patientMatrix, numClones = 5, lambdaFactor = 0.25)
#'
#' # Show voxel intensity values after cloning
#' clones[, sampledCols]
#'
#' @export
#' @importFrom stats rpois
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
