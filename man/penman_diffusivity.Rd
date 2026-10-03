\name{penman_diffusivity}
\alias{penman_diffusivity}
\title{Soil gas diffusivity (Penman equation)}
\description{Manual eq. 203 (Penman, 1940; Moldrup et al., 2004). The manual does not print an explicit form for f(T); this implementation uses ((T+273.15)/293.15)^1.75.}
\usage{penman_diffusivity(air_porosity, temp_c = 20, alpha = 0.66, d0 = 2.6e-5)}
\arguments{\item{air_porosity}{Air-filled porosity (-).}
\item{temp_c}{Soil temperature (degrees C).}
\item{alpha}{Adjustment parameter.}
\item{d0}{Gas diffusion coefficient in free air (m2 s-1).}
}
\value{Soil gas diffusivity (m2 s-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{penman_diffusivity(0.2, 20)}
