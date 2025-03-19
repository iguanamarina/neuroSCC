#' Example SCC Computation Result
#'
#' @description
#' A precomputed example of SCC analysis comparing Pathological and Control groups.
#' The result was obtained using \code{\link[ImageSCC]{scc.image}}.
#'
#' The structure of this object is complex, but it must contain at least:
#' \itemize{
#'   \item \code{Z.band}: Matrix specifying grid positions.
#'   \item \code{ind.inside.cover}: Indices of grid points inside the confidence band.
#'   \item \code{scc}: 3D array containing computed SCC values.
#' }
#'
#' @format A list containing multiple elements, including SCC values, boundary definitions,
#'         and metadata related to the SCC computation process.
#'
#' @usage data("SCCcomp")
#'
#' @keywords datasets
"SCCcomp"
