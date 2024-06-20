#' Cleans and loads data from NIFTI files
#'
#' @description
#' This function reads a NIFTI image, transforms it into a dataframe, preserves the cross-section specified by the Z axis,
#' and organizes the data into a structured table that other functions work on subsequently.
#'
#' @param name `character`, the name of the NIFTI file to read.
#' @param demo `data.frame`, a dataframe containing demographic data formatted according to the \link[neuroSCC]{demoCleaner} function.
#' @return A `data.frame` that combines the NIFTI image data with the demographic data in the appropriate format. Each row represents a pixel, and the columns include demographic data and pixel intensity.
#' @details The function first reads the NIFTI file using the `oro.nifti::readNIfTI` function from the package.
#' Then, it converts the image data to a dataframe and selects only the cross-section of interest.
#' Afterward, it checks if the demographic dataframe contains the necessary columns and extracts the data for the specified participant.
#' Finally, it combines these data with the image data and returns the resulting dataframe for that patient.
#' @export
#'
#' @author Juan A. Arias (http://juan-arias.xyz)
#' @seealso \link[neuroSCC]{demoCleaner} and `oro.nifti::readNIfTI()`.
#'

neuroCleaner <- function(name, demo) {
    # Load data into a dataframe
    file <- oro.nifti::readNIfTI(fname = name, verbose = FALSE, warn = -1, reorient = TRUE, call = NULL, read_data = TRUE)
    n <- memisc::to.data.frame(img_data(file))

    # Get File Name
    namex <- as.character(name)

    # Get Dimensions of File
    xDim <- file@dim_[2]
    yDim <- file@dim_[3]
    dim <- xDim * yDim

    # Prepare base data.frame where data from the loop will be integrated
    dataframe <- data.frame(z = integer(), x = integer(), y = integer(), pet = integer())

      # Loop for every slice in that Z; then attach to dataframe
      for (i in seq(1:xDim)) {
        n_lim <- n[n$Var2 == i, ] # Select just one Z slice
        n_lim$Var1 <- NULL
        n_lim$Var2 <- NULL

        z <- rep(i, length.out = dim)
        x <- rep(1:xDim, each = yDim, length.out = dim)
        y <- rep(1:yDim, length.out = dim)

        pet <- unlist(n_lim) # Convert n_lim to a vector and avoid using attach

        temp <- data.frame(z, x, y, pet) # Temporal dataframe
        dataframe <- rbind(dataframe, temp) # Sum new data with previous data
      }

    # Check if demographic data contains required columns
    requiredColumns <- c("PPT", "Group", "Sex", "Age")
    if (!all(requiredColumns %in% names(demo))) {
      stop("Demographic data must contain columns: PPT, Group, Sex, and Age")
    }

    # Extract demographic data
    demog <- demo[demo$PPT == namex, ]
    if (nrow(demog) == 0) {
      stop("No demographic data found for the given participant.")
    }

      # Replicate demographic data for each pixel
      PPT <- rep(demog$PPT, length.out = dim)
      group <- rep(demog$Group, length.out = dim)
      sex <- rep(demog$Sex, length.out = dim)
      age <- rep(demog$Age, length.out = dim)

      temp2 <- data.frame(PPT, group, sex, age)
      dataframe <- cbind(temp2, dataframe)

    return(dataframe) # Return the dataframe
  }
