\name{canopy_kext}
\alias{canopy_kext}
\title{Canopy extinction coefficient}
\description{Manual p. 26 (Norman, 1980).}
\usage{canopy_kext(theta, chi = 1)}
\arguments{\item{theta}{Solar zenith angle in radians.}
\item{chi}{Ellipsoid leaf-angle parameter (1 = spherical).}
}
\value{Extinction coefficient.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{canopy_kext(0.5)}
