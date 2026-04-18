#' Plot SCC bands and mean estimate for a single group
#'
#' @description
#' This function visualizes the lower band, mean estimate, and upper band
#' from a single-group Simultaneous Confidence Corridor (SCC) result.
#' It returns a three-panel plot showing the estimated mean function and
#' its confidence bands over the neuroimaging domain.
#'
#' @param scc A list-like SCC result object, typically returned by
#'   \code{ImageSCC::scc.image()}, containing at least the components
#'   \code{Z}, \code{ind.inside.cover}, \code{scc}, and \code{Yhat}.
#' @param title \code{character}, title shown above the panel. If \code{NULL},
#'   the default title is \code{"SCC FOR GROUP 1"}.
#' @param zlim Either \code{"auto"} to compute color limits from the plotted values,
#'   or a numeric vector of length 2 specifying the lower and upper limits of the
#'   fill scale.
#' @param palette \code{character}, color palette used in the heatmaps.
#'   Supported values are \code{"nih"}, \code{"viridis"}, and \code{"gray"}.
#'
#' @return A patchwork/ggplot object containing three aligned panels:
#' \itemize{
#'   \item lower SCC band,
#'   \item mean estimate,
#'   \item upper SCC band.
#' }
#'
#' @details
#' The three panels are displayed using a shared color scale so that the lower band,
#' mean estimate, and upper band can be compared directly.
#'
#' The function assumes that the second slice of \code{scc$scc[, , 2]} corresponds
#' to the SCC bands for the default significance level used in the package workflow.
#'
#' @examples
#' data("sccOneGroup", package = "neuroSCC")
#' plotSCCpanel(sccOneGroup, title = "SCC FOR CONTROL GROUP")
#'
#' @seealso
#' \code{\link{sccOneGroup}} for the example single-group SCC object used in the examples. \cr
#' \code{\link{SCCcomp}} for a two-group SCC example object. \cr
#' \code{\link{plotSCCcomparisonPanel}} for two-group SCC visualization. \cr
#' \code{\link{plotValidationPanel}} for SCC versus SPM performance visualization.
#'
#' @export
plotSCCpanel <- function(scc, title = NULL, zlim = "auto", palette = "nih") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required.")
  }
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Package 'patchwork' is required.")
  }
  if (!requireNamespace("fields", quietly = TRUE)) {
    stop("Package 'fields' is required.")
  }
  if (!requireNamespace("viridis", quietly = TRUE)) {
    stop("Package 'viridis' is required.")
  }
  if (!requireNamespace("scales", quietly = TRUE)) {
    stop("Package 'scales' is required.")
  }

  if (!is.list(scc)) {
    stop("'scc' must be a list-like SCC object.")
  }
  if (is.null(scc$Z) || is.null(scc$ind.inside.cover) || is.null(scc$scc) || is.null(scc$Yhat)) {
    stop("'scc' must contain 'Z', 'ind.inside.cover', 'scc', and 'Yhat'.")
  }

  Z <- scc$Z[scc$ind.inside.cover, , drop = FALSE]
  lower <- scc$scc[, 1, 2]
  upper <- scc$scc[, 2, 2]
  mean_est <- scc$Yhat[1, ]

  if (ncol(Z) < 2) {
    stop("'scc$Z' must contain at least two coordinate columns.")
  }
  if (length(lower) != nrow(Z) || length(upper) != nrow(Z) || length(mean_est) != nrow(Z)) {
    stop("Mismatch between SCC values and coordinates.")
  }

  if (is.null(title)) {
    title <- "SCC FOR GROUP 1"
  }

  x_dim <- max(Z[, 1], na.rm = TRUE)
  y_dim <- max(Z[, 2], na.rm = TRUE)
  x_lab <- paste0("Horizontal (0-", x_dim, ")")
  y_lab <- paste0("Longitudinal (0-", y_dim, ")")

  all_values <- c(lower, mean_est, upper)
  if (identical(zlim, "auto")) {
    zlim <- range(all_values, na.rm = TRUE)
  }

  palette_colors <- switch(
    palette,
    "nih" = fields::tim.colors(64),
    "viridis" = viridis::viridis(64),
    "gray" = grDevices::gray.colors(64),
    stop("Invalid palette. Choose one of: 'nih', 'viridis', 'gray'.")
  )

  fill_scale <- ggplot2::scale_fill_gradientn(
    colors = palette_colors,
    limits = zlim,
    oob = scales::squish,
    name = "value"
  )

  build_tile <- function(vals, label, title_x = NULL, title_y = NULL, show_legend = FALSE) {
    df <- data.frame(
      x = Z[, 1],
      y = Z[, 2],
      value = vals
    )

    ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = value)) +
      ggplot2::geom_tile(show.legend = show_legend) +
      fill_scale +
      ggplot2::coord_fixed() +
      ggplot2::labs(title = label, x = title_x, y = title_y) +
      ggplot2::theme_minimal(base_family = "serif") +
      ggplot2::theme(
        axis.title.x = if (!is.null(title_x)) {
          ggplot2::element_text(size = 12, margin = ggplot2::margin(t = 10))
        } else {
          ggplot2::element_blank()
        },
        axis.title.y = if (!is.null(title_y)) {
          ggplot2::element_text(size = 12, margin = ggplot2::margin(r = 10))
        } else {
          ggplot2::element_blank()
        },
        axis.text.x = ggplot2::element_text(size = 9),
        axis.text.y = ggplot2::element_text(size = 9),
        axis.ticks = ggplot2::element_line(linewidth = 0.2),
        plot.title = ggplot2::element_text(
          hjust = 0.5,
          size = 12,
          margin = ggplot2::margin(b = 5)
        )
      )
  }

  p1 <- build_tile(lower, "Lower Band", title_y = y_lab, show_legend = FALSE)
  p2 <- build_tile(mean_est, "Mean Estimate", title_x = x_lab, show_legend = TRUE)
  p3 <- build_tile(upper, "Upper Band", show_legend = FALSE)

  patchwork::wrap_plots(p1, p2, p3, nrow = 1, guides = "collect") +
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
