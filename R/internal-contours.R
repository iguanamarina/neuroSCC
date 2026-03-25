# Internal helpers for contour extraction from non-zero image support

#' Internal helper: polygon area
#' @keywords internal
.poly_area_xy <- function(x, y) {
  if (!(x[1] == x[length(x)] && y[1] == y[length(y)])) {
    x <- c(x, x[1])
    y <- c(y, y[1])
  }

  abs(sum(x[-1] * y[-length(y)] - x[-length(x)] * y[-1])) / 2
}

#' Internal helper: extract contours from non-zero image support
#' @keywords internal
.extract_mask_contours <- function(dat, contour_level = 0.1) {
  if (!is.data.frame(dat) || !all(c("x", "y", "value") %in% names(dat))) {
    stop("'dat' must be a data.frame with columns 'x', 'y', and 'value'")
  }

  xMax <- max(dat$x)
  yMax <- max(dat$y)

  mask_num <- matrix(0, nrow = xMax, ncol = yMax)
  mask_num[cbind(dat$x, dat$y)] <- as.numeric(dat$value != 0)

  cl <- grDevices::contourLines(
    x = 1:xMax,
    y = 1:yMax,
    z = mask_num,
    levels = contour_level
  )

  if (length(cl) == 0) {
    return(list())
  }

  areas <- vapply(
    cl,
    function(one) .poly_area_xy(one$x, one$y),
    numeric(1)
  )

  ord <- order(areas, decreasing = TRUE)

  lapply(cl[ord], function(one) {
    data.frame(
      x = one$x,
      y = one$y
    )
  })
}
