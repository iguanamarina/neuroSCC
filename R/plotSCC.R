#' Visualize SCC Results
#'
#' @description
#' This function visualizes Simultaneous Confidence Corridor (SCC) results as a heatmap,
#' with the option to overlay significant points where detected differences exceed the confidence bands.
#'
#' @param SCC_Result A list containing SCC computation results from \code{ImageSCC::scc.image()}.
#' @param title A character string specifying the title of the plot. Default is `"SCC Visualization"`.
#' @param colorPalette A character string specifying the color scheme. Options: `"viridis"`, `"magma"`, `"turbo"`. Default is `"viridis"`.
#' @param showPoints A logical indicating whether to overlay significant SCC points. Default is \code{TRUE}.
#' @param alphaLevel A numeric value specifying the confidence level threshold for SCC detection. Default is \code{0.05}.
#' @param xlab A character string specifying the x-axis label. Defaults to `"Longitudinal (1-X)"`, where `X` is extracted from SCC dimensions.
#' @param ylab A character string specifying the y-axis label. Defaults to `"Transversal (1-Y)"`, where `Y` is extracted from SCC dimensions.
#'
#' @return A heatmap plot displaying SCC values with optional overlays of significant points.
#'
#' @details
#' - Extracts SCC matrix values and formats them for visualization.
#' - Uses \code{getPoints()} to identify significant regions exceeding SCC thresholds.
#' - Differentiates **positive** and **negative** SCC points using distinct markers.
#'
#' @examples
#' \dontrun{
#'   # Load SCC results
#'   load("SCC_COMP.RData")
#'
#'   # Basic SCC visualization
#'   plotSCC(SCC_COMP)
#'
#'   # SCC plot with specific confidence threshold and custom color palette
#'   plotSCC(SCC_COMP, alphaLevel = 0.01, colorPalette = "magma", title = "SCC Analysis (alpha = 0.01)")
#' }
#'
#' @export
plotSCC <- function(SCC_Result,
                    title = "SCC Visualization",
                    colorPalette = "viridis",
                    showPoints = TRUE,
                    alphaLevel = 0.05,
                    xlab = NULL,
                    ylab = NULL) {

  # 1. Validate Inputs
  # ---------------------------
  if (!is.list(SCC_Result) || !"scc" %in% names(SCC_Result) || !"Z.band" %in% names(SCC_Result)) {
    stop("'SCC_Result' must be a valid SCC object from ImageSCC::scc.image().")
  }

  if (!is.numeric(alphaLevel) || alphaLevel <= 0 || alphaLevel > 1) {
    stop("'alphaLevel' must be a numeric value between 0 and 1.")
  }

  if (!is.character(colorPalette) || !(colorPalette %in% c("viridis", "magma", "turbo"))) {
    stop("'colorPalette' must be one of: 'viridis', 'magma', 'turbo'.")
  }

  # 2. Extract SCC Matrix and Dimensions
  # ---------------------------
  SCC_Matrix <- SCC_Result$scc[, , 2]  # Extract estimated SCC values
  gridCoords <- as.data.frame(SCC_Result$Z.band)  # Extract grid points

  xMax <- max(gridCoords$V1)  # Extract max X dimension
  yMax <- max(gridCoords$V2)  # Extract max Y dimension

  # Set default axis labels if not provided
  if (is.null(xlab)) xlab <- paste0("Longitudinal (1-", xMax, ")")
  if (is.null(ylab)) ylab <- paste0("Transversal (1-", yMax, ")")

  # 3. Generate Heatmap
  # ---------------------------
  library(ggplot2)
  library(viridisLite)

  SCC_df <- data.frame(
    x = rep(1:nrow(SCC_Matrix), each = ncol(SCC_Matrix)),
    y = rep(1:ncol(SCC_Matrix), nrow(SCC_Matrix)),
    sccValue = as.vector(SCC_Matrix)
  )

  heatmapPlot <- ggplot(SCC_df, aes(x = x, y = y, fill = sccValue)) +
    geom_tile() +
    scale_fill_viridis_c(option = colorPalette) +
    labs(title = title, x = xlab, y = ylab, fill = "SCC Value") +
    theme_minimal()

  # 4. Overlay Significant SCC Points
  # ---------------------------
  if (showPoints) {
    pointsList <- getPoints(SCC_Result)  # Extract significant SCC points

    if (nrow(pointsList$positivePoints) > 0) {
      heatmapPlot <- heatmapPlot +
        geom_point(data = pointsList$positivePoints, aes(x = x, y = y),
                   color = "blue", shape = 15, size = 2, alpha = 0.8)
    }

    if (nrow(pointsList$negativePoints) > 0) {
      heatmapPlot <- heatmapPlot +
        geom_point(data = pointsList$negativePoints, aes(x = x, y = y),
                   color = "red", shape = 16, size = 2, alpha = 0.8)
    }
  }

  # 5. Return Plot
  # ---------------------------
  return(heatmapPlot)
}
