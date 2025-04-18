% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generatePoissonClonesExample.R
\docType{data}
\name{generatePoissonClonesExample}
\alias{generatePoissonClonesExample}
\title{Example Input for Poisson Clone Generation}
\format{
A numeric matrix named \code{generatePoissonClonesExample}, with 1 row and all voxel columns.
}
\source{
Simulated PET neuroimaging dataset included with \code{neuroSCC}.
}
\usage{
data("generatePoissonClonesExample")
}
\description{
A full single-subject PET matrix used to demonstrate \code{\link{generatePoissonClones}}.
This matrix was extracted from simulated neuroimaging data included in the \code{neuroSCC} package.

The example avoids long runtime by generating only one synthetic clone.
}
\seealso{
\code{\link{generatePoissonClones}}
}
\keyword{datasets}
