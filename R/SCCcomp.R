#' Example SCC Computation Result
#'
#' @description
#' A precomputed example of a Simultaneous Confidence Corridor (SCC) analysis
#' comparing a group of Pathological subjects against Controls, using the
#' \code{\link[ImageSCC]{scc.image}} function.
#'
#' This dataset serves as a compact and realistic representation of the kind of SCC
#' object generated in neuroimaging comparisons, and is used internally in
#' \code{\link{getPoints}} and \code{\link{calculateMetrics}} examples.
#'
#' @format A list of class \code{"image"} containing:
#' \describe{
#'   \item{scc}{3D array of SCC confidence bands, shape \code{[n, 2, α]}}
#'   \item{Z.band}{Matrix of grid coordinates corresponding to evaluation points}
#'   \item{ind.inside.cover}{Integer vector of indices identifying the SCC band region}
#'   \item{V.est.a, V.est.b}{Vertex matrices for the domain triangulation (control and pathological)}
#'   \item{Tr.est.a, Tr.est.b}{Triangle index matrices for the domain triangulation}
#'   \item{alpha}{Vector of confidence levels used (e.g. 0.1, 0.05, 0.01)}
#'   \item{d.est}{Spline degree used for mean estimation}
#'   \item{r}{Smoothing parameter}
#' }
#'
#' @usage data("SCCcomp")
#'
#' @seealso \code{\link{getPoints}}, \code{\link{calculateMetrics}}, \code{\link[ImageSCC]{scc.image}}
#'
#' @source Simulated PET neuroimaging analysis for SCC evaluation.
#'
#' @keywords datasets
"SCCcomp"
