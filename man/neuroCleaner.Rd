% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/neuroCleaner.R
\name{neuroCleaner}
\alias{neuroCleaner}
\title{Clean and Load Data from NIfTI Neuroimaging Files}
\usage{
neuroCleaner(name, demo = NULL, demoRow = 1)
}
\arguments{
\item{name}{\code{character}. The full path to the NIfTI file to process.}

\item{demo}{Optional \code{data.frame} containing demographic information.
If provided, it should include columns (case-insensitive): \code{PPT}, \code{Group}, \code{Sex}, and \code{Age}.
If automatic matching via the \code{PPT} column fails, the row specified by \code{demoRow} is used. Default is \code{NULL}.}

\item{demoRow}{\code{integer}. Row to use from the demographic table if automatic matching fails. Default is \code{1}.}
}
\value{
A data frame where each row represents a voxel (3D pixel).
\itemize{
  \item If demographics are provided: the columns include \code{PPT}, \code{Group}, \code{Sex}, \code{Age}, \code{z}, \code{x}, \code{y}, and \code{pet}.
  \item If demographics are not provided: the columns include \code{z}, \code{x}, \code{y}, and \code{pet}.
}
The \code{pet} column contains the PET intensity value at each voxel location.
}
\description{
Loads a NIfTI-format neuroimaging file and transforms it into a structured data frame,
organizing voxel-level information for downstream analysis. This function is the first step
in the neuroimaging processing pipeline in \code{neuroSCC}, converting raw PET data into
a format suitable for functional data analysis. SCCs are later computed using functions
from the \code{ImageSCC} package, such as \code{ImageSCC::scc.image()}.
}
\details{
The function performs the following steps
\enumerate{
  \item Loads the NIfTI file using \code{oro.nifti::readNIfTI()}.
  \item Converts the 3D image into a tidy data frame.
  \item Adds \code{z}, \code{x}, and \code{y} voxel coordinates.
  \item If demographic data is provided, attempts to match based on \code{PPT} (case-insensitive). If no match is found, \code{demoRow} is used.
}

The resulting data frame serves as input for \code{\link{databaseCreator}}, \code{\link{matrixCreator}},
and other core functions in the \code{neuroSCC} pipeline.
}
\examples{
# Load a sample Control NIfTI file
niftiFile <- system.file("extdata", "syntheticControl1.nii.gz", package = "neuroSCC")

# Example Without demographic data
petData <- neuroCleaner(niftiFile)
petData[sample(nrow(petData), 10), ]  # Show 10 random voxels

}
\seealso{
\code{\link{databaseCreator}} for batch image processing. \cr
\code{\link[oro.nifti]{readNIfTI}} for reading NIfTI-format files.
}
