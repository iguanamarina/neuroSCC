#' Plot ROI, SCC detections, and SPM detections for validation
#'
#' @description
#' This function visualizes the ground-truth ROI, SCC-detected points,
#' and SPM-detected points as a three-panel comparison over a shared
#' neuroimaging background.
#'
#' @param template \code{character}, path to a NIfTI file used to obtain the
#'   grid dimensions of the imaging domain.
#' @param backgroundMatrix A numeric matrix used to generate the grayscale
#'   background image.
#' @param roiPoints A \code{data.frame} with columns \code{x} and \code{y}
#'   containing the ground-truth ROI points.
#' @param sccPoints A list containing \code{positivePoints} and
#'   \code{negativePoints}, each as a \code{data.frame} with columns
#'   \code{x} and \code{y}.
#' @param spmPoints A \code{data.frame} with columns \code{x} and \code{y}
#'   containing the SPM-detected points.
#' @param title \code{character}, title shown above the panel.
#' @param label1 \code{character}, title of the ground-truth ROI panel.
#' @param label2 \code{character}, title of the SCC-detected panel.
#' @param label3 \code{character}, title of the SPM-detected panel.
#'
#' @return A patchwork/ggplot object containing three aligned panels:
#' \itemize{
#'   \item ground-truth ROI,
#'   \item SCC-detected points,
#'   \item SPM-detected points.
#' }
#'
#' @details
#' The three panels share the same grayscale background to facilitate visual
#' comparison between the true ROI and the points detected by SCC and SPM.
#'
#' In the examples, SCC detections are restricted to positive points only
#' to keep the visualization simple. With real analysis outputs,
#' \code{sccPoints} would typically be supplied directly as
#' \code{getPoints(<SCC object>)}.
#'
#' @examples
#' \donttest{
#' paramZ <- 35
#'
#' controlPattern <- "^syntheticControl.*\\.nii\\.gz$"
#' databaseCN <- databaseCreator(pattern = controlPattern, control = TRUE, quiet = TRUE)
#' matrixCN <- matrixCreator(database = databaseCN, paramZ = paramZ, quiet = TRUE)
#' matrixCN <- meanNormalization(matrixCN)
#'
#' roiFile <- system.file("extdata", "ROIsample_Region2_18.nii.gz", package = "neuroSCC")
#' truePoints <- processROIs(roiFile, region = "Region2", number = "18", save = FALSE)
#' roiPoints <- subset(truePoints, z == paramZ & pet == 1, select = c("x", "y"))
#'
#' spmFile <- system.file("extdata", "binary.nii.gz", package = "neuroSCC")
#' spmPoints <- getSPMbinary(spmFile, paramZ = paramZ)
#'
#' data("SCCcomp", package = "neuroSCC")
#'
#' plotValidationPanel(
#'   template = roiFile,
#'   backgroundMatrix = matrixCN,
#'   roiPoints = roiPoints,
#'   sccPoints = list(
#'     positivePoints = getPoints(SCCcomp)$positivePoints,
#'     negativePoints = data.frame(x = numeric(0), y = numeric(0))
#'   ),
#'   spmPoints = spmPoints,
#'   title = "Performance Validation Panel",
#'   label1 = "Ground Truth (ROI)",
#'   label2 = "SCC Detected",
#'   label3 = "SPM Detected"
#' )
#' }
#'
#' @seealso
#' \code{\link{SCCcomp}} for the example SCC object used in the examples. \cr
#' \code{\link{getPoints}} for extraction of SCC-detected significant points. \cr
#' \code{\link{getSPMbinary}} for extraction of SPM-detected significant points. \cr
#' \code{\link{processROIs}} for extraction of ground-truth ROI points.
#'
#' @export
plotValidationPanel <- function(template,
                                backgroundMatrix,
                                roiPoints,
                                sccPoints,
                                spmPoints,
                                title = "COMPARISON PANEL",
                                label1 = "True ROI",
                                label2 = "SCC Detected",
                                label3 = "SPM Detected") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required.")
  }
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Package 'patchwork' is required.")
  }

  if (!is.character(template) || length(template) != 1) {
    stop("'template' must be a single character string with the path to a NIfTI file.")
  }
  if (!file.exists(template)) {
    stop("File not found: ", template)
  }
  if (!is.matrix(backgroundMatrix)) {
    stop("'backgroundMatrix' must be a matrix.")
  }
  if (!is.data.frame(roiPoints) || !all(c("x", "y") %in% names(roiPoints))) {
    stop("'roiPoints' must be a data.frame with columns 'x' and 'y'.")
  }
  if (!is.list(sccPoints) ||
      is.null(sccPoints$positivePoints) ||
      is.null(sccPoints$negativePoints)) {
    stop("'sccPoints' must be a list containing 'positivePoints' and 'negativePoints'.")
  }
  if (!is.data.frame(spmPoints) || !all(c("x", "y") %in% names(spmPoints))) {
    stop("'spmPoints' must be a data.frame with columns 'x' and 'y'.")
  }

  dims <- getDimensions(template)
  Z <- as.matrix(expand.grid(y = 1:dims$yDim, x = 1:dims$xDim)[, c(2, 1)])

  if (ncol(backgroundMatrix) != nrow(Z)) {
    stop("Mismatch between 'backgroundMatrix' and template dimensions.")
  }

  df_base <- data.frame(
    x = Z[, 1],
    y = Z[, 2],
    value = colMeans(backgroundMatrix)
  )

  x_lab <- paste0("Horizontal (0-", dims$xDim, ")")
  y_lab <- paste0("Longitudinal (0-", dims$yDim, ")")

  fill_scale <- ggplot2::scale_fill_gradient(
    low = "black",
    high = "white",
    name = NULL
  )

  base_theme <- ggplot2::theme_minimal(base_family = "serif") +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = 8, family = "serif"),
      axis.ticks = ggplot2::element_line(linewidth = 0.2),
      plot.title = ggplot2::element_text(
        hjust = 0.5,
        size = 11,
        face = "plain",
        family = "serif"
      ),
      legend.position = "none"
    )

  p1 <- ggplot2::ggplot(df_base, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_tile() +
    fill_scale +
    ggplot2::geom_point(
      data = roiPoints,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "green",
      size = 1.2,
      shape = 15
    ) +
    ggplot2::coord_fixed() +
    ggplot2::labs(title = label1, x = NULL, y = y_lab) +
    base_theme +
    ggplot2::theme(
      axis.title.y = ggplot2::element_text(size = 11, margin = ggplot2::margin(r = 10))
    )

  p2 <- ggplot2::ggplot(df_base, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_tile() +
    fill_scale +
    ggplot2::coord_fixed() +
    ggplot2::labs(title = label2, x = x_lab, y = NULL) +
    base_theme +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(size = 11, margin = ggplot2::margin(t = 10))
    )

  if (nrow(sccPoints$positivePoints) > 0) {
    p2 <- p2 + ggplot2::geom_point(
      data = sccPoints$positivePoints,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "blue",
      size = 1.2,
      shape = 15
    )
  }

  if (nrow(sccPoints$negativePoints) > 0) {
    p2 <- p2 + ggplot2::geom_point(
      data = sccPoints$negativePoints,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "red",
      size = 1.2,
      shape = 17
    )
  }

  p3 <- ggplot2::ggplot(df_base, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_tile() +
    fill_scale +
    ggplot2::geom_point(
      data = spmPoints,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "blue",
      size = 1.2,
      shape = 15
    ) +
    ggplot2::coord_fixed() +
    ggplot2::labs(title = label3, x = NULL, y = NULL) +
    base_theme

  patchwork::wrap_plots(p1, p2, p3, nrow = 1) +
    patchwork::plot_annotation(
      title = toupper(title),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(
          family = "serif",
          face = "bold",
          size = 16,
          hjust = 0.5,
          margin = ggplot2::margin(b = 12)
        )
      )
    )
}
