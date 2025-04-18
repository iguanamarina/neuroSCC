% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/processROIs.R
\name{processROIs}
\alias{processROIs}
\title{Process ROI Voxel Data from a NIfTI File}
\usage{
processROIs(
  roiFile,
  region,
  number,
  save = TRUE,
  outputDir = tempdir(),
  verbose = TRUE
)
}
\arguments{
\item{roiFile}{\code{character}. Path to the binary NIfTI file containing ROI data.}

\item{region}{\code{character}. Name of the ROI region (e.g., \code{"Region2"}).}

\item{number}{\code{character}. Identifier for the subject or group (e.g., \code{"18"}).}

\item{save}{\code{logical}. If \code{TRUE}, saves the result as an \code{.RDS} file. If \code{FALSE},
returns a data frame in the console. Default is \code{TRUE}.}

\item{outputDir}{\code{character}. Directory where the ROI table will be saved if \code{save = TRUE}.
Default is a temporary file: \code{tempdir()}.}

\item{verbose}{\code{logical}. If \code{TRUE}, displays progress messages. Default is \code{TRUE}.}
}
\value{
A data frame with voxel-level ROI information.
\itemize{
  \item \code{group} – Combined identifier built from \code{region} and \code{number}.
  \item \code{z}, \code{x}, \code{y} – Voxel coordinates.
  \item \code{pet} – Binary value indicating ROI membership (\code{1} = ROI, \code{0} = non-ROI).
}
If \code{save = TRUE}, the data frame is saved as an \code{.RDS} file and not returned to the console.
}
\description{
Processes Regions of Interest (ROIs) from a binary NIfTI file by extracting voxel-level
coordinates and labeling each voxel as part of the ROI or not. The function preserves the
spatial structure and is typically used to prepare ground truth ROIs for comparison with
SCC-detected regions via \code{\link{calculateMetrics}}.
}
\details{
The function uses \code{\link{neuroCleaner}} to load and flatten the NIfTI file into a structured
data frame. All voxels are retained, with the \code{pet} column indicating which ones are part
of the ROI (\code{1}) versus background (\code{0}). An ROI label is added in the \code{group} column.

This output is used as ground truth for evaluating detection performance in SCC analyses.
}
\examples{
# Load and process a sample ROI NIfTI file (console output)

}
\seealso{
\code{\link{calculateMetrics}} for evaluating SCC detection performance. \cr
\code{\link{neuroCleaner}} for reading and structuring voxel data.
}
