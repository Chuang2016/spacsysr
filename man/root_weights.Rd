\name{root_weights}
\alias{root_weights}
\title{Root-zone weighting for N uptake}
\description{Exponential root distribution weights per layer, normalised over layers within the current rooting depth.}
\usage{root_weights(zmid_mm, root_depth_mm)}
\arguments{\item{zmid_mm}{Layer mid-point depths (mm).}
\item{root_depth_mm}{Current rooting depth (mm).}
}
\value{Normalised weights summing to 1 (0 for layers below roots).}
\examples{root_weights(c(100, 350, 750), 500)}
