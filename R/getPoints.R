#' Extract significant SCC points from an SCC comparison object
#'
#' @description
#' This function identifies and extracts coordinates where significant differences
#' fall outside the simultaneous confidence corridors (SCCs).
#' It processes the results from \code{ImageSCC::scc.image}, returning the extracted coordinates
#' where the differences are statistically significant.
#'
#' @param sccResult A list containing SCC computation results from \code{ImageSCC::scc.image}.
#'        The list should include at least:
#' \itemize{
#'   \item \code{Z.band}: Matrix specifying grid positions.
#'   \item \code{ind.inside.cover}: Indices of grid points inside the confidence band.
#'   \item \code{scc}: 3D array containing computed SCC values.
#' }
#'
#' @return A named list:
#' \itemize{
#'   \item \code{positivePoints}: Data frame with coordinates where the first group
#'         shows significantly higher values than the second.
#'   \item \code{negativePoints}: Data frame with coordinates where the second group
#'         shows significantly higher values than the first.
#' }
#'
#' @details
#' - Positive points indicate where the first group (e.g., Control) is significantly stronger.
#' - Negative points indicate where the second group (e.g., Pathological) is significantly stronger.
#' - This function must be used **after** running \code{ImageSCC::scc.image}.
#'
#' @examples
#' \dontrun{
#' # Load SCC results (previously computed)
#' load("SCC_COMP.RData")
#'
#' # Extract significant SCC points
#' significantPoints <- getPoints(SCC_COMP)
#'
#' # Display extracted coordinates
#' head(significantPoints$positivePoints)  # External significant points
#' head(significantPoints$negativePoints)  # Internal significant points (if any)
#' }
#'
#' @seealso
#' \code{ImageSCC::scc.image} for SCC computation.
#'
#' @export
getPoints <- function(sccResult) {
  # 1. Validate Input
  # ---------------------------
  if (!is.list(sccResult)) {
    stop("'sccResult' must be a list containing SCC comparison results.")
  }

  required_elements <- c("Z.band", "ind.inside.cover", "scc")
  missing_elements <- setdiff(required_elements, names(sccResult))
  if (length(missing_elements) > 0) {
    stop("Missing required elements in SCC object: ", paste(missing_elements, collapse = ", "))
  }

  # Extract required components
  Z.band <- matrix(sccResult$Z.band, ncol = 2)  # Grid positions
  insideCover <- sccResult$ind.inside.cover     # Indices inside the SCC region
  sccValues <- sccResult$scc                    # SCC values (3D array)

  # 2. Ensure SCC Data is Valid
  # ---------------------------
  if (is.null(sccValues) || all(is.na(sccValues))) {
    warning("SCC values are empty or contain only NA values. Returning empty results.")
    return(list(positivePoints = data.frame(x = numeric(), y = numeric()),
                negativePoints = data.frame(x = numeric(), y = numeric())))
  }

  # Get unique grid positions
  z1 <- unique(Z.band[, 1])
  z2 <- unique(Z.band[, 2])
  n1 <- length(z1)
  n2 <- length(z2)

  # 3. Create SCC Matrices
  # ---------------------------
  # Initialize SCC matrices
  scc <- matrix(NA, n1 * n2, 2)

  # Ensure proper alignment when assigning SCC values
  if (length(insideCover) != nrow(sccValues)) {
    stop("Mismatch: 'ind.inside.cover' length does not match SCC matrix size.")
  }

  scc[insideCover, ] <- sccValues[, , 2]  # Assign SCC confidence band values

  # Define SCC thresholds
  sccLower <- matrix(scc[, 1], nrow = n2, ncol = n1)  # Lower bound
  sccUpper <- matrix(scc[, 2], nrow = n2, ncol = n1)  # Upper bound

  # Remove invalid values
  sccLower[sccLower < 0] <- NA  # Negative lower bound values are not significant
  sccUpper[sccUpper > 0] <- NA  # Positive upper bound values are not significant

  # 4. Identify Significant SCC Points
  # ---------------------------
  posPoints <- which(sccLower > 0, arr.ind = TRUE)  # First group stronger
  negPoints <- which(sccUpper < 0, arr.ind = TRUE)  # Second group stronger

  # 5. Convert Indexes to Coordinates
  # ---------------------------
  positiveCoords <- if (nrow(posPoints) > 0) {
    data.frame(x = z1[posPoints[, 2]], y = z2[posPoints[, 1]])
  } else {
    data.frame(x = numeric(), y = numeric())
  }

  negativeCoords <- if (nrow(negPoints) > 0) {
    data.frame(x = z1[negPoints[, 2]], y = z2[negPoints[, 1]])
  } else {
    data.frame(x = numeric(), y = numeric())
  }

  # Return structured results
  return(list(positivePoints = positiveCoords, negativePoints = negativeCoords))
}
