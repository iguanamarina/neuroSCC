#' Example SCC Computation Result
#'
#' @description
#' A precomputed example of a Simultaneous Confidence Corridor (SCC) analysis
#' comparing a group of pathological subjects against controls. This object was generated
#' using the \code{ImageSCC::scc.image} function and represents a realistic output
#' from SCC-based neuroimaging group comparisons.
#'
#' This dataset is used in the examples of \code{\link{getPoints}} and \code{\link{calculateMetrics}},
#' allowing users to explore SCC outputs without needing to recompute them.
#'
#' @format A named list of class \code{"image"} with the following elements
#' \describe{
#'   \item{\code{scc}}{3D array of SCC confidence bands, dimensions \code{[n, 2, alpha]}.}
#'   \item{\code{Z.band}}{Matrix of grid coordinates corresponding to evaluated locations.}
#'   \item{\code{ind.inside.cover}}{Integer vector of indices for grid points inside the SCC band.}
#'   \item{\code{V.est.a}, \code{V.est.b}}{Vertex matrices for triangulated domains (pathological and control groups).}
#'   \item{\code{Tr.est.a}, \code{Tr.est.b}}{Triangle index matrices corresponding to the domain meshes.}
#'   \item{\code{alpha}}{Vector of confidence levels used (e.g., 0.1, 0.05, 0.01).}
#'   \item{\code{d.est}}{Spline degree used in mean function estimation.}
#'   \item{\code{r}}{Smoothing parameter used during fitting.}
#' }
#'
#' @usage data("SCCcomp")
#'
#' @seealso \code{\link{getPoints}}, \code{\link{calculateMetrics}}, \code{ImageSCC::scc.image}
#'
#' @source Simulated PET neuroimaging study for evaluating SCC methodology.
#'
#' @keywords datasets
"SCCcomp"
