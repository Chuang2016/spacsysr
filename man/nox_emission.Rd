\name{nox_emission}
\alias{nox_emission}
\title{Diffusion-driven nitrogenous gas emission}
\description{Manual eq. 202.}
\usage{nox_emission(diffusivity, conc)}
\arguments{\item{diffusivity}{Soil gas diffusivity (m2 s-1).}
\item{conc}{Gas concentration in soil air (consistent units).}
}
\value{Emission rate in consistent units.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nox_emission(penman_diffusivity(0.2), 3)}
