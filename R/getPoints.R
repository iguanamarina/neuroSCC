#' Extract standalone significant SCC points from a SCC comparison object
#'
#' @description
#' This function processes an SCC comparison object to identify and extract coordinates of points
#' where significant differences are detected by the SCC analysis. It returns the coordinates
#' of positive and negative differences separately, which can be used for further analysis or
#' visualization on neuroimages.
#'
#' @param aa A list containing SCC comparison results, expected to have elements like `Z.band`,
#'           `ind.inside.cover`, and `scc` matrices.
#' @return A list with two elements: coordinates of points with positive differences and coordinates
#'         of points with negative differences. Each element is a matrix where rows are points and
#'         columns represent coordinates.
#'
#' @examples
#' points <- getPoints(SCC_COMP_1)
#'
#' @export

getPoints <- function(aa) {
  Z.band <- matrix(aa$Z.band, ncol = 2) # Positions
  z1 <- unique(Z.band[, 1]); z2 <- unique(Z.band[, 2]) # Separated positions
  n1 <- length(z1); n2 <- length(z2) # Lengths of those positions
  scc <- matrix(NA, n1 * n2, 2) # Matrix with value of that SCC in that position
  ind.inside.band <- aa$ind.inside.cover # Keep only regions inside triangulation
  scc[ind.inside.band, ] <- aa$scc[, , 2] # Assign SCC to those areas (IMPORTANT: 1,2,3 FOR DIFFERENT ALPHAS)
  scc.limit <- c(min(scc[, 1], na.rm = TRUE), max(scc[, 2], na.rm = TRUE)) # Limits: minimum of inferior, maximum of superior
  scc.l.mtx <- matrix(scc[, 1], nrow = n2, ncol = n1) # Lower SCC for each location
  scc.u.mtx <- matrix(scc[, 2], nrow = n2, ncol = n1) # Upper SCC for each location
  scc.l.mtx[scc.l.mtx < 0] <- NA # Replace non-positive lower SCCs with NA
  scc.u.mtx[scc.u.mtx > 0] <- NA # Replace non-negative upper SCCs with NA
  points.P <- which(scc.l.mtx > 0, arr.ind = TRUE) # Points where mean difference is positive (first image is stronger)
  points.N <- which(scc.u.mtx < 0, arr.ind = TRUE) # Points where mean difference is negative (second image is stronger)
  pointers <- list(points.P, points.N)
  print(pointers)
}

