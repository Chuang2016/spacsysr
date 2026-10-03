\name{ppfd_hourly}
\alias{ppfd_hourly}
\title{Hourly photosynthetic photon flux density}
\description{PPFD_i = 2.07e6*SR*sin(h_i)/sum(sin(h_i)) (manual p. 25).}
\usage{ppfd_hourly(sr_mj, lat, doy)}
\arguments{\item{sr_mj}{Daily shortwave solar irradiation (MJ m-2 d-1).}
\item{lat}{Latitude in degrees.}
\item{doy}{Day of year.}
}
\value{Named numeric vector of hourly PPFD (umol m-2 s-1), hours 0-23.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{plot(ppfd_hourly(20, 32, 180), type = "l")}
