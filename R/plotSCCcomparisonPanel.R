#' Plot group means and SCC comparison overlay
#'
#' @description
#' This function visualizes a two-group Simultaneous Confidence Corridor (SCC)
#' result as a three-panel figure showing the mean estimate for each group and
#' an overlay panel with SCC-detected differences.
#'
#' @param scc A list-like SCC result object, typically returned by
#'   \code{ImageSCC::scc.image()}, containing the components required for
#'   plotting group means and SCC-derived significant points.
#' @param title \code{character}, title shown above the panel. If \code{NULL},
#'   the default title is \code{"SCC COMPARISON PANEL"}.
#' @param zlim Either \code{"auto"} to compute color limits from the plotted values,
#'   or a numeric vector of length 2 specifying the lower and upper limits of the
#'   fill scale.
#' @param palette \code{character}, color palette used in the mean heatmaps.
#'   Supported values are \code{"nih"}, \code{"viridis"}, and \code{"gray"}.
#' @param label1 \code{character}, title of the first group panel.
#' @param label2 \code{character}, title of the second group panel.
#' @param label3 \code{character}, title of the SCC overlay panel.
#' @param overlay \code{character}, which SCC-detected points to overlay in the
#'   third panel. Supported values are \code{"positive"}, \code{"negative"},
#'   \code{"both"}, and \code{"none"}.
#' @param useRawMeans \code{logical}, if \code{TRUE}, the group means are computed
#'   directly from \code{scc$Ya} and \code{scc$Yb}. If \code{FALSE}, the function
#'   uses \code{scc$Yhat}.
#'
#' @return A patchwork/ggplot object containing three aligned panels:
#' \itemize{
#'   \item mean estimate for group 1,
#'   \item mean estimate for group 2,
#'   \item SCC overlay panel with detected positive and/or negative points.
#' }
#'
#' @details
#' The first two panels use a shared continuous color scale to facilitate direct
#' comparison between group mean estimates. The third panel uses a grayscale
#' background and overlays SCC-detected significant points.
#'
#' Positive and negative SCC detections are obtained internally using
#' \code{\link{getPoints}}.
#'
#' @examples
#' data("SCCcomp", package = "neuroSCC")
#' plotSCCcomparisonPanel(SCCcomp, title = "SCC COMPARISON PANEL")
#'
#' @seealso
#' \code{\link{SCCcomp}} for the example two-group SCC object used in the examples. \cr
#' \code{\link{getPoints}} for extraction of SCC-detected significant points. \cr
#' \code{\link{plotSCCpanel}} for single-group SCC visualization. \cr
#' \code{\link{plotValidationPanel}} for SCC versus SPM performance visualization.
#'
#' @export
plotSCCcomparisonPanel <- function(scc,
                                   title = NULL,
                                   zlim = "auto",
                                   palette = "nih",
                                   label1 = "Group 1 Mean",
                                   label2 = "Group 2 Mean",
                                   label3 = "SCC Overlay",
                                   overlay = c("positive", "negative", "both", "none"),
                                   useRawMeans = FALSE) {
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

  overlay <- match.arg(overlay)

  if (!is.list(scc)) {
    stop("'scc' must be a list-like SCC object.")
  }

  if (!is.null(scc$Yhat) && !useRawMeans) {
    if (is.null(scc$Z) || is.null(scc$ind.inside.cover)) {
      stop("'scc' must contain 'Z' and 'ind.inside.cover'.")
    }
    Z <- scc$Z[scc$ind.inside.cover, , drop = FALSE]
    mean1_vals <- scc$Yhat[1, ]
    mean2_vals <- scc$Yhat[2, ]
  } else {
    if (is.null(scc$Z.band) || is.null(scc$Ya) || is.null(scc$Yb)) {
      stop("'scc' must contain 'Z.band', 'Ya', and 'Yb' when 'useRawMeans = TRUE'.")
    }
    Z <- scc$Z.band
    mean1_vals <- colMeans(scc$Ya)
    mean2_vals <- colMeans(scc$Yb)
  }

  if (ncol(Z) < 2) {
    stop("'scc' coordinates must contain at least two columns.")
  }
  if (length(mean1_vals) != nrow(Z) || length(mean2_vals) != nrow(Z)) {
    stop("Mismatch between SCC values and coordinates.")
  }

  df1 <- data.frame(x = Z[, 1], y = Z[, 2], value = mean1_vals)
  df2 <- data.frame(x = Z[, 1], y = Z[, 2], value = mean2_vals)
  df3 <- df2

  overlay_pts <- getPoints(scc)
  pos_pts <- overlay_pts$positivePoints
  neg_pts <- overlay_pts$negativePoints

  x_dim <- max(Z[, 1], na.rm = TRUE)
  y_dim <- max(Z[, 2], na.rm = TRUE)
  x_lab <- paste0("Horizontal (0-", x_dim, ")")
  y_lab <- paste0("Longitudinal (0-", y_dim, ")")

  if (is.null(title)) {
    title <- "SCC COMPARISON PANEL"
  }

  palette_colors <- switch(
    palette,
    "nih" = fields::tim.colors(64),
    "viridis" = viridis::viridis(64),
    "gray" = grDevices::gray.colors(64),
    stop("Invalid palette. Choose one of: 'nih', 'viridis', 'gray'.")
  )

  all_values <- c(df1$value, df2$value)
  if (identical(zlim, "auto")) {
    zlim <- range(all_values, na.rm = TRUE)
  }

  fill_scale <- ggplot2::scale_fill_gradientn(
    colors = palette_colors,
    limits = zlim,
    oob = scales::squish,
    name = "value"
  )

  build_tile <- function(df, label, title_x = NULL, title_y = NULL,
                         show_legend = FALSE, scale = fill_scale) {
    ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = value)) +
      ggplot2::geom_tile(show.legend = show_legend) +
      scale +
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

  p1 <- build_tile(df1, label1, title_y = y_lab, show_legend = FALSE)
  p2 <- build_tile(df2, label2, title_x = x_lab, show_legend = TRUE)

  gray_scale <- ggplot2::scale_fill_gradient(low = "black", high = "white", name = NULL)
  p3 <- build_tile(df3, label3, show_legend = FALSE, scale = gray_scale)

  if (overlay %in% c("positive", "both") && nrow(pos_pts) > 0) {
    p3 <- p3 + ggplot2::geom_point(
      data = pos_pts,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "blue",
      size = 1.2,
      shape = 15
    )
  }

  if (overlay %in% c("negative", "both") && nrow(neg_pts) > 0) {
    p3 <- p3 + ggplot2::geom_point(
      data = neg_pts,
      ggplot2::aes(x = x, y = y),
      inherit.aes = FALSE,
      color = "red",
      size = 1.2,
      shape = 17
    )
  }

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
