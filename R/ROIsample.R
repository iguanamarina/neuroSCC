#' Example ROI Data for SCC Analysis
#'
#' @description
#' A precomputed example of a Region of Interest (ROI) dataset used in SCC analysis.
#' This dataset contains voxel coordinates for manually defined hypoactive regions.
#' It can be used for testing \code{\link{processROIs}} and \code{\link{calculateMetrics}}.
#'
#' The structure of this object includes:
#' \itemize{
#'   \item \code{group}: Character vector identifying the PPT group.
#'   \item \code{z}: Integer vector with z-coordinates of ROI voxels.
#'   \item \code{x}: Integer vector with x-coordinates of ROI voxels.
#'   \item \code{y}: Integer vector with y-coordinates of ROI voxels.
#'   \item \code{pet}: Binary numeric vector (\code{0} or \code{1}).
#'         - \code{1} indicates a voxel where hypoactivity was simulated.
#'         - \code{0} indicates a voxel that was not marked as hypoactive.
#' }
#'
#' @format A data frame with voxel-level ROI information.
#'
#' @usage data("ROIsample")
#'
#' @keywords datasets
"ROIsample"
