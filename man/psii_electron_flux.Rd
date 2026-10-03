\name{psii_electron_flux}
\alias{psii_electron_flux}
\title{PSII electron flux from absorbed PPFD}
\description{Manual p. 21; the printed denominator was garbled and is restored from context.}
\usage{psii_electron_flux(i0, phi2ll = 0.85, sp = 0, r2_1 = 0)}
\arguments{\item{i0}{Photon flux density absorbed by leaf pigments (umol m-2 s-1).}
\item{phi2ll}{Quantum efficiency of PSII electron transport at low light.}
\item{sp}{Spectral imbalance parameter.}
\item{r2_1}{Leaf reflectance coefficient.}
}
\value{I2 (umol m-2 s-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{psii_electron_flux(1000)}
