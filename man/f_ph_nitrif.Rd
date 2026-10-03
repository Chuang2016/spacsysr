\name{f_ph_nitrif}
\alias{f_ph_nitrif}
\title{pH response of autotrophic nitrification}
\description{Exponential form adapted from the DenNit model (Reth et al., 2005); manual eq. 191.}
\usage{f_ph_nitrif(ph)}
\arguments{\item{ph}{Soil pH.}
}
\value{Response factor in (0, 1].}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_ph_nitrif(seq(4, 9, by = 0.5))}
