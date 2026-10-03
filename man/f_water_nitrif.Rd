\name{f_water_nitrif}
\alias{f_water_nitrif}
\title{Moisture response of autotrophic nitrification}
\description{Manual eq. 189.}
\usage{f_water_nitrif(wfps)}
\arguments{\item{wfps}{Water-filled pore space, fraction.}
}
\value{Response factor (>= 0.6).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_water_nitrif(seq(0.3, 1, by = 0.1))}
